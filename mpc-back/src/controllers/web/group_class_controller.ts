import { Request, Response } from 'express';
import fs from 'fs';
import path from 'path';

import resend from '../../config/resend';
import stripe from '../../config/stripe';
import GroupClass from '../../models/GroupClass';

// Price for group class booking in cents (€10 = 1000 cents)
const GROUP_CLASS_PRICE_CENTS = 1000;

export default class GroupClassController {
  public async getGroupClasses(req: Request, res: Response): Promise<void> {
    try {
      const groupClasses = await GroupClass.find();
      res.status(200).json(groupClasses);
    } catch (error) {
      console.error('Error fetching group classes:', error);
      res.status(500).json({ error: 'Failed to fetch group classes' });
    }
  }

  public async bookGroupClass(req: Request, res: Response): Promise<void> {
    try {
      //[Log] Booking data:

      // classId: "6964d593e636d7b1bb25cfd6"

      // date: "2026-01-11T23:00:00.000Z"

      // email: "kamryydev@gmail.com"

      // firstName: "IGor"

      // lastName: "Kamrowski"

      // timeSlot: "09:30 AM"

      const { classId, date, email, firstName, lastName, timeSlot } = req.body;
      const occurrenceDate: string =
        req.body.occurrenceDate || new Date(date).toISOString().split('T')[0];

      const groupClass = await GroupClass.findById(classId);
      if (!groupClass) {
        res.status(404).json({ error: 'Group class not found' });
        return;
      }

      const timeSlotObj = groupClass.timeSlots.find(
        (slot) => slot.time === timeSlot
      );

      // Bookings for this week's occurrence only — each week is its own pool
      const spotsThisWeek =
        timeSlotObj?.spots.filter(
          (booking) => booking.occurrenceDate === occurrenceDate
        ) ?? [];

      // check by mail for this occurrence
      const bookingExists = spotsThisWeek.some(
        (booking) => booking.email === email
      );
      if (bookingExists) {
        res.status(400).json({ error: 'You have already booked this class' });
        return;
      }

      if (spotsThisWeek.length >= groupClass.spotsAvailable) {
        res.status(400).json({ error: 'This time slot is fully booked' });
        return;
      }

      // add booking
      timeSlotObj?.spots.push({
        email,
        firstName,
        lastName,
        bookedAt: new Date(date),
        occurrenceDate,
      });
      await groupClass.save();

      // Send confirmation email
      try {
        await this.sendBookingConfirmationEmail(
          email,
          firstName,
          lastName,
          groupClass.title,
          date,
          timeSlot,
          groupClass.durationMinutes
        );
        console.log('✅ Booking confirmation email sent to:', email);
      } catch (emailError) {
        console.error('Error sending confirmation email:', emailError);
        // Don't fail the booking if email fails
      }

      res.status(200).json({ message: 'Group class booked successfully' });
    } catch (error) {
      console.error('Error booking group class:', error);
      res.status(500).json({ error: 'Failed to book group class' });
    }
  }

  private async sendBookingConfirmationEmail(
    email: string,
    firstName: string,
    lastName: string,
    className: string,
    classDate: string,
    classTime: string,
    duration: number
  ): Promise<void> {
    const template_path = path.join(
      __dirname,
      '../../../',
      'templates',
      'group_class_booking.html'
    );

    const templateSource = fs.readFileSync(template_path, 'utf8');

    // Format the date nicely
    const formattedDate = new Date(classDate).toLocaleDateString('en-US', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });

    // Replace template variables
    let html = templateSource.replace('{{className}}', className);
    html = html.replace('{{classDate}}', formattedDate);
    html = html.replace('{{classTime}}', classTime);
    html = html.replace('{{duration}}', duration.toString());
    html = html.replace('{{firstName}}', firstName);
    html = html.replace('{{lastName}}', lastName);

    const { data, error } = await resend.emails.send({
      from: 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>',
      to: [email],
      subject: `Booking Confirmed: ${className}`,
      html: html,
    });

    if (error) {
      console.error('Error sending email:', error);
      throw error;
    }

    console.log('Email sent successfully:', data);
  }

  // Create Stripe checkout session for group class booking
  public async createCheckoutSession(
    req: Request,
    res: Response
  ): Promise<void> {
    try {
      const { classId, timeSlot, firstName, lastName, email, date } = req.body;
      // occurrenceDate ("YYYY-MM-DD") identifies which week's pool this booking
      // belongs to. Fall back to the date's day for older clients.
      const occurrenceDate: string =
        req.body.occurrenceDate || new Date(date).toISOString().split('T')[0];

      if (!classId || !timeSlot || !firstName || !email || !date) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
      }

      const groupClass = await GroupClass.findById(classId);
      if (!groupClass) {
        res.status(404).json({ error: 'Group class not found' });
        return;
      }

      // Check if slot is available
      const timeSlotObj = groupClass.timeSlots.find(
        (slot) => slot.time === timeSlot
      );
      if (!timeSlotObj) {
        res.status(400).json({ error: 'Time slot not found' });
        return;
      }

      // Only count bookings for this week's occurrence — each week is its own pool
      const spotsThisWeek = timeSlotObj.spots.filter(
        (booking) => booking.occurrenceDate === occurrenceDate
      );

      if (spotsThisWeek.length >= groupClass.spotsAvailable) {
        res.status(400).json({ error: 'This time slot is fully booked' });
        return;
      }

      // Check if email already booked this same occurrence
      const bookingExists = spotsThisWeek.some(
        (booking) => booking.email === email
      );
      if (bookingExists) {
        res.status(400).json({ error: 'You have already booked this class' });
        return;
      }

      // Format the date for display
      const formattedDate = new Date(date).toLocaleDateString('en-US', {
        weekday: 'short',
        month: 'short',
        day: 'numeric',
      });

      // Create Stripe checkout session
      const session = await stripe.checkout.sessions.create({
        payment_method_types: ['card'],
        mode: 'payment',
        line_items: [
          {
            price_data: {
              currency: 'eur',
              product_data: {
                name: `${groupClass.title} - Group Class`,
                description: `${formattedDate} at ${timeSlot} (${groupClass.durationMinutes} min)`,
              },
              unit_amount: GROUP_CLASS_PRICE_CENTS,
            },
            quantity: 1,
          },
        ],
        customer_email: email,
        metadata: {
          classId,
          timeSlot,
          firstName,
          lastName,
          email,
          date,
          occurrenceDate,
          className: groupClass.title,
          durationMinutes: groupClass.durationMinutes.toString(),
        },
        success_url:
          process.env.NODE_ENV === 'development'
            ? `http://localhost:3000/group-classes/success?session_id={CHECKOUT_SESSION_ID}`
            : `https://midlandsperformanceclub.ie/group-classes/success?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url:
          process.env.NODE_ENV === 'development'
            ? `http://localhost:3000/group-classes`
            : `https://midlandsperformanceclub.ie/group-classes`,
      });

      console.log('Checkout session created:', session.id);
      res.status(200).json({ url: session.url, sessionId: session.id });
    } catch (error) {
      console.error('Error creating checkout session:', error);
      res.status(500).json({ error: 'Failed to create checkout session' });
    }
  }

  // Handle successful payment - called by webhook
  public async confirmBookingAfterPayment(
    classId: string,
    timeSlot: string,
    firstName: string,
    lastName: string,
    email: string,
    date: string,
    className: string,
    durationMinutes: number,
    occurrenceDate?: string
  ): Promise<void> {
    const groupClass = await GroupClass.findById(classId);
    if (!groupClass) {
      throw new Error('Group class not found');
    }

    const timeSlotObj = groupClass.timeSlots.find(
      (slot) => slot.time === timeSlot
    );
    if (!timeSlotObj) {
      throw new Error('Time slot not found');
    }

    const occurrence =
      occurrenceDate || new Date(date).toISOString().split('T')[0];

    // Bookings for this week's occurrence only — each week is its own pool
    const spotsThisWeek = timeSlotObj.spots.filter(
      (booking) => booking.occurrenceDate === occurrence
    );

    // Double-check booking doesn't already exist for this occurrence
    const bookingExists = spotsThisWeek.some(
      (booking) => booking.email === email
    );
    if (bookingExists) {
      console.log('Booking already exists for:', email);
      return;
    }

    // Guard against overbooking this week's pool
    if (spotsThisWeek.length >= groupClass.spotsAvailable) {
      console.error(
        `Pool full for ${className} ${occurrence} ${timeSlot}; cannot confirm ${email}`
      );
      throw new Error('This time slot is fully booked');
    }

    // Add the booking
    timeSlotObj.spots.push({
      email,
      firstName,
      lastName,
      bookedAt: new Date(date),
      occurrenceDate: occurrence,
    });
    await groupClass.save();

    console.log('✅ Booking confirmed after payment:', email);

    // Send confirmation email
    await this.sendBookingConfirmationEmail(
      email,
      firstName,
      lastName,
      className,
      date,
      timeSlot,
      durationMinutes
    );
  }
}
