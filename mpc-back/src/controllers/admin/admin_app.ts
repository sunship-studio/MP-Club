import console from 'console';
import { Request, Response } from 'express';
import fs from 'fs';
import path from 'path';
import {
  uploadExcelToCloudinary,
  uploadToCloudinary,
  uploadVideoToCloudinary,
} from '../../config/cloudinary';
import resend from '../../config/resend';
import stripe from '../../config/stripe';
import AdminSettings from '../../models/AdminSettings';
import ClassPass from '../../models/ClassPass';
import ClassPassProduct from '../../models/ClassPassProduct';
import Exercise from '../../models/Exercise';
import GroupClass from '../../models/GroupClass';
import { PlanForSale } from '../../models/PlanForSale';
import { activatePass, findActivePassForEmail, venueToday } from '../../services/class_pass';
import { sendPassLinkEmail } from '../../services/class_pass_email';
import { toLocalDateString } from '../../services/group_class_booking';
import User from '../../models/User';
import { WaitingListEntry } from '../../models/WaitingListEntry';
import excelService from '../../services/excel';
export default class AdminAppController {
  /**
   * Who holds a pass and when it runs out.
   *
   * Tokens are deliberately absent: they are bearer credentials, and an admin
   * list is a screen that gets screenshotted and shared. Shane gets a holder
   * back onto their pass with `resendClassPassLink` instead (D8).
   */
  public async listClassPasses(req: Request, res: Response): Promise<Response> {
    try {
      const search =
        typeof req.query.search === 'string' ? req.query.search.trim() : '';

      const filter = search
        ? { email: { $regex: search.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), $options: 'i' } }
        : {};

      const passes = await ClassPass.find(filter).sort({ purchasedAt: -1 }).lean();
      const today = venueToday();

      const products = await ClassPassProduct.find().lean();
      const productName = new Map(products.map((p) => [String(p._id), p.name]));

      return res.status(200).json(
        passes.map((pass) => ({
          _id: pass._id,
          firstName: pass.firstName,
          lastName: pass.lastName,
          email: pass.email,
          productName: productName.get(String(pass.productId)) ?? `${pass.months} Month Pass`,
          months: pass.months,
          pricePaidCents: pass.pricePaidCents,
          validFromDate: pass.validFromDate,
          validUntilDate: pass.validUntilDate,
          purchasedAt: pass.purchasedAt,
          grantedByAdmin: pass.grantedByAdmin,
          // Renewal state, so an admin can see what is still being charged
          // (D19). The subscription id itself stays server-side — the admin
          // app has no use for it and it is a Stripe handle.
          recurring: Boolean(pass.stripeSubscriptionId),
          autoRenew: Boolean(pass.autoRenew),
          subscriptionStatus: pass.subscriptionStatus,
          nextChargeDate: pass.nextChargeDate,
          status: pass.revoked
            ? 'revoked'
            : pass.validUntilDate < today
              ? 'expired'
              : 'active',
        }))
      );
    } catch (error) {
      console.error('Error listing class passes:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  /** The products a grant can be made against. */
  public async getPassProductsForAdmin(req: Request, res: Response): Promise<Response> {
    try {
      const products = await ClassPassProduct.find({ active: true }).lean();
      return res.status(200).json(products);
    } catch (error) {
      console.error('Error listing class pass products:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  /**
   * Grant a pass by hand. The failure this exists for: Stripe took the money,
   * the webhook didn't land, and a customer who turned up has no pass (D12).
   */
  public async grantClassPass(req: Request, res: Response): Promise<Response> {
    try {
      const { productId, firstName, lastName } = req.body;
      const email: string | undefined = req.body.email?.trim().toLowerCase();

      if (!productId || !email || !firstName) {
        return res.status(400).json({ message: 'Missing required fields' });
      }

      const product = await ClassPassProduct.findById(productId);
      if (!product) {
        return res.status(404).json({ message: 'Class pass product not found' });
      }

      // Same one-at-a-time rule as a purchase (D7), which is also what stops a
      // double tap on the grant button minting two passes.
      const held = await findActivePassForEmail(email);
      if (held) {
        return res.status(409).json({
          error: `${email} already has a pass, valid until ${held.validUntilDate}.`,
          validUntilDate: held.validUntilDate,
        });
      }

      const pass = await activatePass({
        productId: String(product._id),
        email,
        firstName,
        lastName,
        purchaseDate: venueToday(),
        grantedByAdmin: true,
      });

      // The grant is the point; the email is a courtesy. Shane fixing a
      // customer in front of him must not fail because Resend is down — he can
      // resend from the list once it is back.
      let emailSent = true;
      try {
        await sendPassLinkEmail(pass);
      } catch (error) {
        emailSent = false;
        console.error('Granted pass but failed to email the link:', error);
      }

      return res.status(201).json({
        _id: pass._id,
        email: pass.email,
        validFromDate: pass.validFromDate,
        validUntilDate: pass.validUntilDate,
        emailSent,
      });
    } catch (error) {
      console.error('Error granting class pass:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  /**
   * Revoke or un-revoke a pass.
   *
   * Revoking blocks new bookings and moves no spots: classes already booked
   * stand, and Shane removes an attendee deliberately in the editor if he wants
   * them gone. A misclick is fixed by un-revoking, not by reconstructing
   * somebody's calendar (D9).
   */
  public async setClassPassRevoked(req: Request, res: Response): Promise<Response> {
    try {
      const revoked = req.body?.revoked !== false;

      const pass = await ClassPass.findByIdAndUpdate(
        req.params.id,
        { $set: { revoked } },
        { new: true }
      );
      if (!pass) {
        return res.status(404).json({ message: 'Class pass not found' });
      }

      // Revoking has to stop the money as well as the entitlement: a revoked
      // pass that keeps billing monthly is a bug with a bank statement
      // attached (D19). Cancelled outright, not at period end — there is no
      // term left to honour once the pass is withdrawn.
      let subscriptionCancelFailed = false;
      const stillCharging =
        revoked &&
        pass.stripeSubscriptionId &&
        pass.subscriptionStatus !== 'canceled';

      if (stillCharging) {
        try {
          await stripe.subscriptions.cancel(pass.stripeSubscriptionId!);
        } catch (error) {
          // The entitlement is ours to withdraw and has been. Billing is a
          // best effort, and a failure here must be visible rather than leave
          // the pass live.
          console.error('Failed to cancel subscription for revoked pass:', error);
          subscriptionCancelFailed = true;
        }

        pass.autoRenew = false;
        pass.subscriptionStatus = 'canceled';
        pass.nextChargeDate = undefined;
        await pass.save();
      }

      return res.status(200).json({
        _id: pass._id,
        revoked: pass.revoked,
        // Un-revoking restores the pass but never the subscription: resuming a
        // cancelled one would need a card, and we hold none.
        subscriptionEnded: pass.subscriptionStatus === 'canceled',
        ...(subscriptionCancelFailed ? { subscriptionCancelFailed: true } : {}),
      });
    } catch (error) {
      console.error('Error updating class pass:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  /** Resend a holder their current pass link, so a lost email is self-service. */
  public async resendClassPassLink(req: Request, res: Response): Promise<Response> {
    try {
      const pass = await ClassPass.findById(req.params.id);
      if (!pass) {
        return res.status(404).json({ message: 'Class pass not found' });
      }

      await sendPassLinkEmail(pass);
      return res.status(200).json({ sent: true, email: pass.email });
    } catch (error) {
      console.error('Error resending class pass link:', error);
      return res.status(500).json({ message: 'Failed to send the pass email' });
    }
  }

  public async getAllExercises(req: Request, res: Response): Promise<Response> {
    try {
      const exercises = await Exercise.find();
      return res.status(200).json(exercises);
    } catch (error) {
      console.error('Error fetching exercises:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async getWaitingList(req: Request, res: Response): Promise<Response> {
    try {
      const waitingList = await WaitingListEntry.find();
      if (!waitingList || waitingList.length === 0) {
        return res.status(404).json({ message: 'No entries found' });
      }
      // Sort the waiting list by createdAt in descending order
      waitingList.sort((a, b) => {
        return b.dateApplied.getTime() - a.dateApplied.getTime();
      });

      return res.status(200).json(waitingList);
    } catch (error) {
      console.error('Error fetching waiting list:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async saveTrainingPlan(
    req: Request,
    res: Response
  ): Promise<Response | void> {
    try {
      const { userId, trainingPlan } = req.body;
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      console.log('Training Plan to be saved:', trainingPlan.days[0].exercises);
      for (const day of trainingPlan.days) {
        for (const exercise of day.exercises) {
          console.log('Exercise in plan:', exercise);
          const matchedExercise = await Exercise.findById(exercise.exerciseId);
          console.log('Matched Exercise:', matchedExercise);

          if (matchedExercise && matchedExercise.videoUrl) {
            exercise.videoUrl = matchedExercise.videoUrl;
          }
          console.log('Final Exercise to be saved:', exercise);
        }
      }
      user.trainingPlan = trainingPlan;
      user.trainingPlan.lastUpdated = new Date();
      await user.save();
      return res.status(200).json({ message: 'Training plan saved' });
    } catch (error) {
      console.error('Error saving training plan:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async getUsers(req: Request, res: Response): Promise<Response> {
    try {
      const subscriptions = await User.find();
      console.log('Subscriptions:', subscriptions);
      return res.status(200).json(subscriptions);
    } catch (error) {
      console.error('Error fetching online subscriptions:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async getOnlineCoachingUsers(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const users = await User.find({ type: 'online_coaching' });
      return res.status(200).json(users);
    } catch (error) {
      console.error('Error fetching online coaching users:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async rejectWaitingList(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const { id } = req.body;
      const entry = await WaitingListEntry.findById(id);
      if (!entry) {
        return res.status(404).json({ message: 'Entry not found' });
      }
      entry.approvalStatus = 'rejected';
      await entry.save();
      return res.status(200).json({ message: 'Entry rejected' });
    } catch (error) {
      console.error('Error rejecting waiting list entry:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async acceptWaitingList(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const { id } = req.body;
      const entry = await WaitingListEntry.findById(id);
      if (!entry) {
        return res.status(404).json({ message: 'Entry not found' });
      }
      entry.approvalStatus = 'approved';
      entry.approvedDate = new Date();
      await entry.save();
      return res.status(200).json({ message: 'Entry approved' });
    } catch (error) {
      console.error('Error approving waiting list entry:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }
  public async saveUserCalories(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const { id, calories } = req.body;
      const user = await User.findById(id);
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
      user.caloriesPerDay = calories;
      await user.save();
      return res.status(200).json({ message: 'Calories updated' });
    } catch (error) {
      console.error('Error updating user calories:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async saveUserTargetWeight(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const { id, targetWeight } = req.body;
      const user = await User.findById(id);
      if (!user) {
        console.log('User not found with id:', id);
        return res.status(404).json({ message: 'User not found' });
      }
      user.targetWeight = targetWeight;
      await user.save();
      return res.status(200).json({ message: 'Target weight updated' });
    } catch (error) {
      console.error('Error updating user target weight:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async saveAdminFCMToken(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const { fcmToken } = req.body;
      AdminSettings.create({
        key: 'admin_fcm_token',
        value: fcmToken,
      });
      return res.status(200).json({ message: 'FCM token updated' });
    } catch (error) {
      console.error('Error updating admin FCM token:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }
  readHTMLFile = (filePath: string) => {
    return fs.readFileSync(filePath, 'utf8');
  };
  public async addSubscriber(req: Request, res: Response): Promise<Response> {
    try {
      const { firstName, lastName, age } = req.body;
      const email = String(req.body.email ?? '').trim().toLowerCase();
      if (!email) {
        return res.status(400).json({ message: 'Email is required' });
      }
      const existingUser = await User.findOne({
        email: { $regex: `^${email.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`, $options: 'i' },
      });
      if (existingUser) {
        return res.status(400).json({
          message: `User with email ${existingUser.email} already exists (status: ${existingUser.status}, type: ${existingUser.type})`,
        });
      }
      await User.create({
        email,
        firstName,
        lastName,
        age,
        type: 'online_coaching',
        customerId: 'manual_subscriber',
        subscriptionId: 'manual_subscriber',
        status: 'active',
        startDate: new Date(),
      });

      // Send confirmation only after the subscriber is actually created
      const template_path = path.join(
        process.cwd(),
        'templates',
        'online_coaching_confirmation.html'
      );
      const templateSource = this.readHTMLFile(template_path);
      const { data, error } = await resend.emails.send({
        from: 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>',
        to: [email],
        subject: 'Subscription Confirmation',
        html: templateSource,
      });
      if (error) {
        console.error('Error sending email:', error);
      } else {
        console.log('✅ Email sent successfully:', data);
      }

      return res.status(200).json({ message: 'Subscriber added' });
    } catch (error) {
      console.error('Error adding subscriber:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async getTrainingPlans(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      console.log('Fetching training plans...');
      const trainingPlans = await PlanForSale.find();
      return res.status(200).json(trainingPlans);
    } catch (error) {
      console.error('Error fetching training plans:', error);

      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async editTrainingPlan(req: Request, res: Response): Promise<void> {
    try {
      const { id, updatedPlan } = req.body;
      const trainingPlan = await PlanForSale.findById(id);
      if (!trainingPlan) {
        res.status(404).json({ message: 'Training plan not found' });
        return;
      }
      console.log('Updated Plan:', updatedPlan.days[0].exercises);
      trainingPlan.name = updatedPlan.name;
      trainingPlan.price = updatedPlan.price;
      trainingPlan.days = updatedPlan.days;

      const newExcelFile = await excelService.generateBufferFromTemplate(
        trainingPlan,
        {
          templatePath: path.join(
            __dirname,
            '../../../templates/training_plan.xlsx'
          ),
        }
      );
      const uploadResponse = await uploadExcelToCloudinary(
        newExcelFile,
        `${trainingPlan._id}_training_plan.xlsx`,
        'training_plans'
      );
      trainingPlan.excelFileUrl = uploadResponse.url;
      await trainingPlan.save();

      res.status(200).json({ message: 'Training plan updated' });
    } catch (error) {
      console.error('Error editing training plan:', error);
    }
  }

  public async deleteTrainingPlan(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.body;
      const trainingPlan = await PlanForSale.findById(id);
      if (!trainingPlan) {
        res.status(404).json({ message: 'Training plan not found' });
        return;
      }
      await PlanForSale.findByIdAndDelete(id);
      res.status(200).json({ message: 'Training plan deleted' });
    } catch (error) {
      console.error('Error deleting training plan:', error);
    }
  }

  public async addPlanForSell(req: Request, res: Response): Promise<Response> {
    try {
      const { name, days, price, currency = 'eur' } = req.body;

      // Create Stripe product
      const stripeProduct = await stripe.products.create({
        name: name,
        description: `Training plan: ${name}`,
        metadata: {
          type: 'training_plan',
        },
      });

      // Create Stripe price for the product
      const stripePrice = await stripe.prices.create({
        product: stripeProduct.id,
        unit_amount: Math.round(price * 100), // Convert to cents
        currency: currency,
      });

      // Save training plan with Stripe product ID
      const newPlan = new PlanForSale({
        name,

        price,
        days,
        priceId: stripePrice.id,
        stripeProductId: stripeProduct.id,
      });
      const excelFile = await excelService.generateBufferFromTemplate(newPlan, {
        templatePath: path.join(
          __dirname,
          '../../../templates/training_plan.xlsx'
        ),
      });

      const uploadResponse = await uploadExcelToCloudinary(
        excelFile,
        `${newPlan._id}_training_plan.xlsx`,
        'training_plans'
      );
      newPlan.excelFileUrl = uploadResponse.url;

      await newPlan.save();

      console.log(
        `✅ Training plan created with Stripe Product ID: ${stripeProduct.id}`
      );
      return res.status(200).json({
        message: 'Training plan added',
        productId: stripeProduct.id,
        priceId: stripePrice.id,
      });
    } catch (error) {
      console.error('Error adding training plan:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async getGroupClasses(req: Request, res: Response): Promise<Response> {
    console.log('Fetching group classes...');
    const groupClasses = await GroupClass.find();

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Calculate next date for recurring classes
    const updatedClasses = groupClasses.map((groupClass) => {
      let classDate = groupClass.date;

      if (groupClass.recurring && groupClass.dayOfWeek) {
        const nextDate = this.getNextDayOfWeek(groupClass.dayOfWeek);
        classDate = nextDate;
      }

      // Check if class is today
      const classDayStart = new Date(classDate!);
      classDayStart.setHours(0, 0, 0, 0);
      const isToday = classDayStart.getTime() === today.getTime();

      const obj = groupClass.toObject();

      // For recurring classes, only show attendees for the upcoming occurrence —
      // each week is its own pool. Pending (unpaid) holds are excluded from the
      // roster; confirmed and legacy bookings are kept.
      if (groupClass.recurring && groupClass.dayOfWeek && classDate) {
        const occ = toLocalDateString(new Date(classDate));
        obj.timeSlots = (obj.timeSlots as any[]).map((slot: any) => ({
          ...slot,
          spots: (slot.spots || []).filter(
            (s: any) => s.occurrenceDate === occ && s.status !== 'pending'
          ),
        })) as any;
      }

      return {
        ...obj,
        date: classDate,
        isToday,
      };
    });

    return res.json(updatedClasses);
  }

  private getNextDayOfWeek(dayOfWeek: string): Date {
    const daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    const targetDay = daysOfWeek.indexOf(dayOfWeek);

    if (targetDay === -1) {
      // If day not found, return current date
      return new Date();
    }

    const today = new Date();
    const currentDay = today.getDay();

    // Calculate days until next occurrence (today counts — a class on its own
    // weekday is "today", matching the public calendar which keeps today bookable)
    let daysUntilTarget = targetDay - currentDay;
    if (daysUntilTarget < 0) {
      daysUntilTarget += 7; // Move to next week
    }

    // Create next date
    const nextDate = new Date(today);
    nextDate.setDate(today.getDate() + daysUntilTarget);
    nextDate.setHours(0, 0, 0, 0); // Reset time to midnight

    return nextDate;
  }

  public async createGroupClass(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const {
        title,
        durationMinutes,
        timeSlots,
        date,
        spotsAvailable,
        recurring,
        dayOfWeek,
      } = req.body;

      const newGroupClass = new GroupClass({
        title,
        durationMinutes,
        timeSlots,
        date,
        recurring,
        dayOfWeek,
        spotsAvailable,
      });

      await newGroupClass.save();
      return res
        .status(200)
        .json({ message: 'Group class created', groupClass: newGroupClass });
    } catch (error) {
      console.error('Error creating group class:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async editGroupClass(req: Request, res: Response): Promise<Response> {
    try {
      const {
        _id,
        title,
        durationMinutes,
        timeSlots,
        date,
        spotsAvailable,
        recurring,
        dayOfWeek,
      } = req.body;

      const groupClass = await GroupClass.findById(_id);
      if (!groupClass) {
        return res.status(404).json({ message: 'Group class not found' });
      }

      groupClass.title = title;
      groupClass.durationMinutes = durationMinutes;

      // The admin editor only ever sees one occurrence's attendees (the upcoming
      // week for recurring classes) and its spots carry no occurrenceDate/status.
      // Overwriting timeSlots wholesale would therefore destroy every other
      // week's bookings and any in-flight pending holds. Instead, merge: keep the
      // bookings the editor never saw, and treat the editor's list as
      // authoritative only for the edited occurrence (so removals still work).
      const editedOcc =
        recurring && dayOfWeek
          ? toLocalDateString(this.getNextDayOfWeek(dayOfWeek))
          : date
            ? toLocalDateString(new Date(date))
            : undefined;

      if (editedOcc) {
        const existingByTime = new Map<string, any[]>();
        for (const slot of groupClass.timeSlots as any[]) {
          existingByTime.set(slot.time, slot.spots || []);
        }
        groupClass.timeSlots = (timeSlots as any[]).map((slot: any) => {
          const prior = existingByTime.get(slot.time) || [];
          // Bookings the editor didn't see: other weeks + live pending holds.
          const preserved = prior.filter(
            (s: any) => s.occurrenceDate !== editedOcc || s.status === 'pending'
          );
          // Editor's list for this occurrence (re-stamped, since the app strips
          // occurrenceDate/status off spots).
          const incoming = (slot.spots || []).map((s: any) => ({
            firstName: s.firstName,
            lastName: s.lastName,
            email: s.email,
            bookedAt: s.bookedAt || new Date(),
            occurrenceDate: editedOcc,
            status: 'confirmed',
          }));
          return { time: slot.time, spots: [...preserved, ...incoming] };
        }) as any;
      } else {
        groupClass.timeSlots = timeSlots;
      }

      groupClass.date = date;
      groupClass.spotsAvailable = spotsAvailable;
      if (recurring !== undefined) groupClass.recurring = recurring;
      if (dayOfWeek) groupClass.dayOfWeek = dayOfWeek;

      await groupClass.save();
      console.log('Group class updated:', groupClass);
      return res
        .status(200)
        .json({ message: 'Group class updated', groupClass });
    } catch (error) {
      console.error('Error editing group class:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async deleteGroupClass(
    req: Request,
    res: Response
  ): Promise<Response> {
    try {
      const { id } = req.body;
      const groupClass = await GroupClass.findById(id);
      if (!groupClass) {
        return res.status(404).json({ message: 'Group class not found' });
      }

      await GroupClass.findByIdAndDelete(id);
      return res.status(200).json({ message: 'Group class deleted' });
    } catch (error) {
      console.error('Error deleting group class:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  // ============ EXERCISE CRUD METHODS ============

  public async createExercise(req: Request, res: Response): Promise<Response> {
    try {
      const { name, description, bodyParts } = req.body;
      const files = req.files as {
        video?: Express.Multer.File[];
        image?: Express.Multer.File[];
      };

      if (!name || !bodyParts) {
        return res
          .status(400)
          .json({ message: 'Name and body parts are required' });
      }

      let videoUrl: string | undefined;
      let imageUrl: string | undefined;
      let videoLengthSeconds: number | undefined;

      // Upload video if provided
      if (files?.video && files.video[0]) {
        const videoFile = files.video[0];
        const videoResult = await uploadVideoToCloudinary(
          videoFile.buffer,
          videoFile.originalname,
          'exercises'
        );
        videoUrl = videoResult.url;
        videoLengthSeconds = videoResult.duration
          ? Math.round(videoResult.duration)
          : undefined;
        console.log('Video uploaded:', videoUrl);
      }

      // Upload image if provided
      if (files?.image && files.image[0]) {
        const imageFile = files.image[0];
        const imageResult = await uploadToCloudinary(
          imageFile.buffer,
          imageFile.originalname,
          'exercise-images'
        );
        imageUrl = imageResult.url;
        console.log('Image uploaded:', imageUrl);
      }

      const parsedBodyParts =
        typeof bodyParts === 'string' ? JSON.parse(bodyParts) : bodyParts;

      const exercise = new Exercise({
        name,
        description,
        bodyParts: parsedBodyParts,
        videoUrl,
        imageUrl,
        videoLengthSeconds,
      });

      await exercise.save();
      console.log('Exercise created:', exercise);
      return res.status(201).json({ message: 'Exercise created', exercise });
    } catch (error) {
      console.error('Error creating exercise:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async updateExercise(req: Request, res: Response): Promise<Response> {
    try {
      const {
        id,
        name,
        description,
        bodyParts,
        existingVideoUrl,
        existingImageUrl,
      } = req.body;
      const files = req.files as {
        video?: Express.Multer.File[];
        image?: Express.Multer.File[];
      };

      const exercise = await Exercise.findById(id);
      if (!exercise) {
        return res.status(404).json({ message: 'Exercise not found' });
      }

      // Update basic fields
      if (name) exercise.name = name;
      if (description !== undefined) exercise.description = description;
      if (bodyParts) {
        exercise.bodyParts =
          typeof bodyParts === 'string' ? JSON.parse(bodyParts) : bodyParts;
      }

      // Upload new video if provided
      if (files?.video && files.video[0]) {
        const videoFile = files.video[0];
        const videoResult = await uploadVideoToCloudinary(
          videoFile.buffer,
          videoFile.originalname,
          'exercises'
        );
        exercise.videoUrl = videoResult.url;
        exercise.videoLengthSeconds = videoResult.duration
          ? Math.round(videoResult.duration)
          : undefined;
        console.log('Video updated:', exercise.videoUrl);
      } else if (existingVideoUrl) {
        exercise.videoUrl = existingVideoUrl;
      }

      // Upload new image if provided
      if (files?.image && files.image[0]) {
        const imageFile = files.image[0];
        const imageResult = await uploadToCloudinary(
          imageFile.buffer,
          imageFile.originalname,
          'exercise-images'
        );
        exercise.imageUrl = imageResult.url;
        console.log('Image updated:', exercise.imageUrl);
      } else if (existingImageUrl) {
        exercise.imageUrl = existingImageUrl;
      }

      await exercise.save();
      console.log('Exercise updated:', exercise);
      return res.status(200).json({ message: 'Exercise updated', exercise });
    } catch (error) {
      console.error('Error updating exercise:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }

  public async deleteExercise(req: Request, res: Response): Promise<Response> {
    try {
      const { id } = req.body;

      const exercise = await Exercise.findById(id);
      if (!exercise) {
        return res.status(404).json({ message: 'Exercise not found' });
      }

      await Exercise.findByIdAndDelete(id);
      console.log('Exercise deleted:', id);
      return res.status(200).json({ message: 'Exercise deleted' });
    } catch (error) {
      console.error('Error deleting exercise:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }
}
