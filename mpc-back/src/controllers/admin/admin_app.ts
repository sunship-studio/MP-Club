import console from 'console';
import { Request, Response } from 'express';
import fs from 'fs';
import path from 'path';
import { uploadExcelToCloudinary } from '../../config/cloudinary';
import resend from '../../config/resend';
import stripe from '../../config/stripe';
import AdminSettings from '../../models/AdminSettings';
import Exercise from '../../models/Exercise';
import GroupClass from '../../models/GroupClass';
import { PlanForSale } from '../../models/PlanForSale';
import User from '../../models/User';
import { WaitingListEntry } from '../../models/WaitingListEntry';
import excelService from '../../services/excel';
export default class AdminAppController {
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
    // Sending mail (Waiting for designers to create templates)
    const template_path = path.join(
      __dirname,
      '../../../templates',
      'online_coaching_confirmation.html'
    );
    const templateSource = this.readHTMLFile(template_path);

    const { data, error } = await resend.emails.send({
      from: 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>',
      to: [req.body.email],
      subject: 'Subscription Confirmation',
      html: templateSource,
    });

    if (error) {
      console.error('Error sending email:', error);
    } else {
      console.log('✅ Email sent successfully:', data);
    }
    try {
      const { email, firstName, lastName, age } = req.body;
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(400).json({ message: 'User already exists' });
      }
      const newUser = await User.create({
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

        clientName: '',
        startDate: new Date(),
        weekOnProgramme: 23,
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
    const groupClasses = await GroupClass.find().sort({ date: 1 });
    return res.json(groupClasses);
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
        .status(201)
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
      groupClass.timeSlots = timeSlots;
      groupClass.date = date;
      groupClass.spotsAvailable = spotsAvailable;
      if (recurring !== undefined) groupClass.recurring = recurring;
      if (dayOfWeek) groupClass.dayOfWeek = dayOfWeek;

      await groupClass.save();
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
}
