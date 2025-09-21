import { NextFunction, Request, Response } from "express";

const mobileAppAuth = (req: Request, res: Response, next: NextFunction) => {
  // Check if the request has a valid mobile app token
  const token = req.headers["token"];
  if (token === process.env.ADMIN_TOKEN) {
    // Token is valid, proceed to the next middleware or route handler
    next();
  } else {
    // Token is invalid, send an unauthorized response
    res.status(401).json({ message: "Unauthorized" });
  }
};

import { getAuth } from "firebase-admin/auth";

// Middleware to verify Firebase JWT
const verifyFirebaseToken = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const token = req.headers.authorization?.split(" ")[1];

  try {
    const decodedToken = await getAuth().verifyIdToken(token!);
    (req as any).idToken = decodedToken;
    next();a
  } catch (error) {
    res.status(401).json({ error: "Unauthorized" });
  }
};
export default mobileAppAuth;
