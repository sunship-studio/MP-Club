import { Request, Response } from "express";
import jwt from "jsonwebtoken";
import { refreshSecret, secret } from "../../middleware/auth";
import User, { IUser } from "../../models/User";
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
    secret,
      {
        expiresIn: "1h",
      }
    );
    const refreshToken = jwt.sign(
      { id: user._id },
      refreshSecret,
      { expiresIn: "30d" }
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
        secret,
        {
          expiresIn: "10s",
        }
      );
      const refreshToken = jwt.sign(
        { id: user._id },
        refreshSecret,
        { expiresIn: "30d" }
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

  static async getUser(req: Request, res: Response){
    const token = req.headers["authorization"] as string;
    const refreshToken = req.headers["x-refresh-token"] as string;

      let user = await User.findOne({token:token})
      if (!user ) {
        user = await User.findOne({refreshToken:refreshToken});
      }

      if (!user) {
        res.status(401).json({ message: "Unauthorized" });
      }
      res.json(user);

  }
}

export default new AuthController();
