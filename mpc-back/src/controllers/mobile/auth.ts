import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { refreshSecret, secret } from '../../middleware/auth';
import User, { IUser } from '../../models/User';
import ChatRoom from '../../models/ChatRoom';
import Message from '../../models/Message';
import GroupClass from '../../models/GroupClass';
export class AuthController {
  static async checkEmail(
    email: string
  ): Promise<{ exists: boolean; hasPassword: boolean }> {
    console.log('Checking email:', email);
    const user = await User.findOne({ email: email.replace(/\s+/g, '') });
    console.log('User found:', user);
    const hasPassword = user?.hasPassword;
    return { exists: user == null ? false : true, hasPassword: hasPassword! };
  }

  static async hashPassword(password: string): Promise<string> {
    const bcrypt = require('bcrypt');
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    return hashedPassword;
  }

  static async verifyPassword(
    password: string,
    hashedPassword: string
  ): Promise<boolean> {
    const bcrypt = require('bcrypt');
    return await bcrypt.compare(password, hashedPassword);
  }

  static async forgotPassword(email: string): Promise<void> {
    const user = await User.findOne({
      email,
    });
    if (user) {
    }
  }

  static async setPassword(
    email: string,
    newPassword: string
  ): Promise<null | {
    refreshToken: string;
    token: string;
  }> {
    const hashedPassword = await this.hashPassword(newPassword);
    const user = await User.findOneAndUpdate(
      { email },
      { password: hashedPassword, hasPassword: true }
    );

    if (!user) {
      return null;
    }
    const token = jwt.sign({ id: user._id }, secret, {
      expiresIn: '1h',
    });
    const refreshToken = jwt.sign({ id: user._id }, refreshSecret, {
      expiresIn: '30d',
    });

    user.token = token;
    user.refreshToken = refreshToken;
    await user.save();

    return { token, refreshToken };
  }
  static async login(
    email: string,
    password: string
  ): Promise<{
    token: string;
    refreshToken: string;
  } | null> {
    const user = await User.findOne({ email: email.replace(/\s+/g, '') });
    if (user && user.password) {
      const isMatch = await this.verifyPassword(password, user.password);
      // create and save jwt tokens
      const token = jwt.sign({ id: user._id }, secret, {
        expiresIn: '10s',
      });
      const refreshToken = jwt.sign({ id: user._id }, refreshSecret, {
        expiresIn: '30d',
      });
      user.token = token;
      user.refreshToken = refreshToken;
      await user.save();

      if (isMatch) {
        return { token, refreshToken };
      }
    }
    return null;
  }

  static async getUser(req: Request, res: Response) {
    const userId = req.user?.id;

    if (!userId) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }

    const user = await User.findById(userId);
    if (!user) {
      res.status(404).json({ error: 'User not found' });
      return;
    }
    res.json(user);
  }


  /**
   * Permanent account deletion (App Store Guideline 5.1.1(v)).
   *
   * Removes the user document (which embeds workouts, check-ins, calorie logs
   * and the training plan), their chat room and messages, and any group-class
   * spot still held under their email. Class pass purchase records are kept:
   * they are financial records of a paid real-world service and are keyed by
   * email, not by account.
   */
  static async deleteAccount(req: Request, res: Response) {
    const userId = req.user?.id;

    if (!userId) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }

    try {
      const user = await User.findById(userId);
      if (!user) {
        res.status(404).json({ error: 'User not found' });
        return;
      }

      const email = user.email;

      await Message.deleteMany({ client_id: user._id });
      await ChatRoom.deleteOne({ clientId: userId });

      // Release any spot the user is still holding so it frees up for others.
      await GroupClass.updateMany(
        { 'timeSlots.spots.email': email },
        { $pull: { 'timeSlots.$[].spots': { email } } }
      );

      await User.deleteOne({ _id: user._id });

      res.status(200).json({ message: 'Account deleted' });
    } catch (error) {
      console.error('Error deleting account:', error);
      res.status(500).json({ error: 'Failed to delete account' });
    }
  }

  static async createAccountWithAppleSubscription(userData: {
    email: string;
    firstName: string;
    lastName: string;
    age: number;
    targetWeight?: number;
    appleReceiptData: string;
    subscriptionId: string;
  }): Promise<{
    success: boolean;
    message?: string;
    token?: string;

    refreshToken?: string;
    user?: IUser;
  }> {
    try {
      const {
        email,
        firstName,
        lastName,
        age,
        targetWeight,
        appleReceiptData,
        subscriptionId,
      } = userData;

      // Check if user already exists
      const existingUser = await User.findOne({
        email: email.replace(/\s+/g, ''),
      });

      if (existingUser) {
        return {
          success: false,
          message: 'User with this email already exists',
        };
      }

      // TODO: Re-enable Apple receipt verification once properly configured
      // const subscriptionValid = await this.verifyAppleReceipt(
      //   appleReceiptData,
      //   subscriptionId
      // );

      // if (!subscriptionValid.valid) {
      //   return {
      //     success: false,
      //     message: subscriptionValid.message || 'Invalid Apple subscription',
      //   };
      // }

      console.log(
        '⚠️ Skipping Apple receipt verification (temporarily disabled)'
      );
      console.log('Creating account for user:', { email, firstName, lastName });

      // Create new user with Apple subscription
      const newUser = new User({
        email: email.replace(/\s+/g, ''),
        firstName,
        lastName,
        age,
        targetWeight,
        customerId: `apple_${Date.now()}`, // Generate unique customer ID for Apple users
        subscriptionId: subscriptionId,
        status: 'active',
        type: 'apple_subscription',
        hasPassword: false,
        startDate: new Date(),
      });

      // Generate JWT tokens
      const token = jwt.sign({ id: newUser._id }, secret, { expiresIn: '1h' });

      const refreshToken = jwt.sign({ id: newUser._id }, refreshSecret, {
        expiresIn: '30d',
      });

      newUser.token = token;
      newUser.refreshToken = refreshToken;

      await newUser.save();

      return {
        success: true,
        message: 'Account created successfully',
        token,
        refreshToken,
        user: newUser,
      };
    } catch (error) {
      console.error('Error creating account with Apple subscription:', error);
      return {
        success: false,
        message: 'Failed to create account',
      };
    }
  }

  static async verifyAppleReceipt(
    receiptData: string,
    subscriptionId: string
  ): Promise<{ valid: boolean; message?: string }> {
    try {
      // Apple App Store receipt verification
      const isProduction = process.env.NODE_ENV === 'production';
      const verifyURL = isProduction
        ? 'https://buy.itunes.apple.com/verifyReceipt'
        : 'https://sandbox.itunes.apple.com/verifyReceipt';

      const requestBody = {
        'receipt-data': receiptData,
        password: process.env.APPLE_SHARED_SECRET || '',
        'exclude-old-transactions': true,
      };

      const response = await fetch(verifyURL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(requestBody),
      });

      const result = await response.json();

      // Handle sandbox fallback for production environment
      if (result.status === 21007 && isProduction) {
        // Receipt is from sandbox, retry with sandbox URL
        const sandboxResponse = await fetch(
          'https://sandbox.itunes.apple.com/verifyReceipt',
          {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(requestBody),
          }
        );

        const sandboxResult = await sandboxResponse.json();
        return this.processAppleReceiptResult(sandboxResult, subscriptionId);
      }

      return this.processAppleReceiptResult(result, subscriptionId);
    } catch (error) {
      console.error('Error verifying Apple receipt:', error);
      return {
        valid: false,
        message: 'Failed to verify Apple receipt',
      };
    }
  }

  private static processAppleReceiptResult(
    result: any,
    subscriptionId: string
  ): { valid: boolean; message?: string } {
    if (result.status !== 0) {
      const statusMessages: { [key: number]: string } = {
        21000: 'The App Store could not read the JSON object you provided',
        21002: 'The data in the receipt-data property was malformed or missing',
        21003: 'The receipt could not be authenticated',
        21004:
          'The shared secret you provided does not match the shared secret on file',
        21005: 'The receipt server is not currently available',
        21006: 'This receipt is valid but the subscription has expired',
        21007: 'This receipt is from the sandbox environment',
        21008: 'This receipt is from the production environment',
      };

      return {
        valid: false,
        message:
          statusMessages[result.status] ||
          `Apple receipt verification failed with status ${result.status}`,
      };
    }

    // Check if receipt contains the expected subscription
    const receipt = result.receipt;
    const latestReceiptInfo = result.latest_receipt_info || [];

    // Look for active subscription matching the provided subscription ID
    const activeSubscription = latestReceiptInfo.find(
      (info: any) =>
        info.product_id === subscriptionId &&
        new Date(parseInt(info.expires_date_ms)) > new Date()
    );

    if (!activeSubscription) {
      return {
        valid: false,
        message:
          'No active subscription found for the provided subscription ID',
      };
    }

    return {
      valid: true,
      message: 'Apple subscription verified successfully',
    };
  }
}

export default new AuthController();
