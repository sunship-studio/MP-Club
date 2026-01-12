import { Request, Response } from 'express';
import fs from 'fs';
import path from 'path';

import resend from '../../config/resend';
import GroupClass from '../../models/GroupClass';

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

      const groupClass = await GroupClass.findById(classId);
      if (!groupClass) {
        res.status(404).json({ error: 'Group class not found' });
        return;
      }

      // check by mail
      const timeSlotObj = groupClass.timeSlots.find(
        (slot) => slot.time === timeSlot
      );
      const bookingExists = timeSlotObj?.spots.some(
        (booking) => booking.email === email
      );
      if (bookingExists) {
        res.status(400).json({ error: 'You have already booked this class' });
        return;
      }

      // add booking
      timeSlotObj?.spots.push({
        email,
        firstName,
        lastName,
        bookedAt: new Date(date),
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
}
