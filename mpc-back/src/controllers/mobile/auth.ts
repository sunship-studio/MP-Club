import jwt from "jsonwebtoken";
import User from "../../models/User";
export class AuthController {
  static async checkEmail(
    email: string
  ): Promise<{ exists: boolean; hasPassword: boolean }> {
    console.log("Checking email:", email);
    const user = await User.findOne({ email: email.replace(/\s+/g, "") });
    console.log("User found:", user);
    const hasPassword = user?.hasPassword;
    return { exists: user == null ? false : true, hasPassword: hasPassword!};
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
    const token = jwt.sign(
      { id: user._id },
      "a6a760517da71371b77e45ffc4900da5504f7824c0ef19d1b65ce6bb263dc4c103a21c44a70d5e5161274f11244cbdf1475176b97d40ea6ff692431841a0b9ff",
      {
        expiresIn: "1h",
      }
    );
    const refreshToken = jwt.sign(
      { id: user._id },
      "b18e762f3a079f9bcdacf0ccce05770b14ceed959e01f246b1bc9e70debaa6d05537219bb00376aecf84510a8d17f18f0194e4829189a226f88b2595629697bb",
      { expiresIn: "7d" }
    );

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
    const user = await User.findOne({ email: email.replace(/\s+/g, "") });
    if (user && user.password) {
      const isMatch = await this.verifyPassword(password, user.password);
      // create and save jwt tokens
      const token = jwt.sign(
        { id: user._id },
        "a6a760517da71371b77e45ffc4900da5504f7824c0ef19d1b65ce6bb263dc4c103a21c44a70d5e5161274f11244cbdf1475176b97d40ea6ff692431841a0b9ff",
        {
          expiresIn: "10s",
        }
      );
      const refreshToken = jwt.sign(
        { id: user._id },
        "b18e762f3a079f9bcdacf0ccce05770b14ceed959e01f246b1bc9e70debaa6d05537219bb00376aecf84510a8d17f18f0194e4829189a226f88b2595629697bb",
        { expiresIn: "7d" }
      );
      user.token = token;
      user.refreshToken = refreshToken;
      await user.save();

      if (isMatch) {
        return { token, refreshToken };
      }
    }
    return null;
  }

  static async getUser(token: string) {


    const user = await User.findOne({ token: token });
    console.log("User found in getUser:", user);
    return user;
  }
}

export default new AuthController();
