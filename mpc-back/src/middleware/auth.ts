import { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import User from "../models/User";


const adminAppAuth = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const token = req.headers["token"];
  if (token === process.env.ADMIN_TOKEN) {
    next();
  } else {
    res.status(401).json({ message: "Unauthorized" });
  }
  return;
};

const verifyToken = async (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers["authorization"] as string | undefined;
  const refreshToken = req.headers["x-refresh-token"] as string | undefined;
  if (!authHeader) {
    console.log("No token provided");
    res.status(401).json({ message: "No token provided" });
    return;
  }
  try {
    jwt.verify(
      authHeader,
      "a6a760517da71371b77e45ffc4900da5504f7824c0ef19d1b65ce6bb263dc4c103a21c44a70d5e5161274f11244cbdf1475176b97d40ea6ff692431841a0b9ff"
    );
          res.setHeader("authorization", authHeader);
      res.setHeader("x-refresh-token", refreshToken!);

    next();
  } catch (error) {
    try {
      jwt.verify(
        refreshToken!,
        "b18e762f3a079f9bcdacf0ccce05770b14ceed959e01f246b1bc9e70debaa6d05537219bb00376aecf84510a8d17f18f0194e4829189a226f88b2595629697bb"
      );
      const decoded = jwt.decode(refreshToken!) as { id: string };
      const newToken = jwt.sign(
        { id: decoded.id },
        "a6a760517da71371b77e45ffc4900da5504f7824c0ef19d1b65ce6bb263dc4c103a21c44a70d5e5161274f11244cbdf1475176b97d40ea6ff692431841a0b9ff",
        {
          expiresIn: "1h",
        }
      );
      const newRefreshToken = jwt.sign(
        { id: decoded.id },
        "b18e762f3a079f9bcdacf0ccce05770b14ceed959e01f246b1bc9e70debaa6d05537219bb00376aecf84510a8d17f18f0194e4829189a226f88b2595629697bb",
        { expiresIn: "7d" }
      );

      res.setHeader("authorization", newToken);
      res.setHeader("x-refresh-token", newRefreshToken);

      const user = await User.findById(decoded.id);
      user!.token = newToken;
      user!.refreshToken = newRefreshToken;

      await user?.save();

      if (!user) {
        console.log('no user found in verifyToken middleware');
        res.status(401).json({ message: "Unauthorized" });
        return;
      }

      next();
    } catch (error) {
      console.error("Token verification error:", error);
      res.status(401).json({ message: "Unauthorized" });
      return;
    }
  }
};

export { adminAppAuth, verifyToken };
