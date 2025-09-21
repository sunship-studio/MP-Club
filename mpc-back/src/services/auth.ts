import User, { IUser } from "../models/User";

export class AuthService {
  static async checkEmailExists(email: string): Promise<boolean> {
    const user = await User.findOne({ email });
    return !!user;
  }

  static async hashPassword(password: string): Promise<string> {
    const bcrypt = require("bcrypt");
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    return hashedPassword;
  }

  static async verifyPassword(
    password: string,
    hashedPassword: string
  ): Promise<boolean> {
    const bcrypt = require("bcrypt");
    return await bcrypt.compare(password, hashedPassword);
  }

  static async setPassword(email: string, newPassword: string): Promise<void> {
    const hashedPassword = await this.hashPassword(newPassword);
    await User.findOneAndUpdate(
      { email },
      { password: hashedPassword, hasPassword: true }
    );
  }
  static async login(email: string, password: string): Promise<IUser | null> {
    const user = await User.findOne({ email });
    if (user && user.passwordHash) {
      const isMatch = await this.verifyPassword(password, user.passwordHash);
      if (isMatch) {
        return user;
      }
    }
    return null;
  }
}

export default new AuthService();
