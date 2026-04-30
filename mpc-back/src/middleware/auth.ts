import { NextFunction, Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import User from '../models/User';

// Extend Express Request type to include user
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
      };
    }
  }
}

const refreshSecret =
  'b18e762f3a079f9bcdacf0ccce05770b14ceed959e01f246b1bc9e70debaa6d05537219bb00376aecf84510a8d17f18f0194e4829189a226f88b2595629697bb';
const secret =
  'a6a760517da71371b77e45ffc4900da5504f7824c0ef19d1b65ce6bb263dc4c103a21c44a70d5e5161274f11244cbdf1475176b97d40ea6ff692431841a0b9ff';

const adminAppAuth = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const token = req.headers['token'];
  if (token === process.env.ADMIN_TOKEN) {
    next();
  } else {
    res.status(401).json({ message: 'Unauthorized' });
  }
  return;
};

const verifyToken = async (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers['authorization'] as string | undefined;
  const refreshToken = req.headers['x-refresh-token'] as string | undefined;
  if (!authHeader) {
    console.log('No token provided');
    res.status(401).json({ message: 'No token provided' });
    return;
  }
  try {
    const decoded = jwt.verify(authHeader, secret) as { id: string };

    // Attach user to request
    req.user = { id: decoded.id };
    next();
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      try {
        jwt.verify(refreshToken!, refreshSecret);
        const decoded = jwt.decode(refreshToken!) as { id: string };
        const newToken = jwt.sign({ id: decoded.id }, secret, {
          expiresIn: '10s',
        });

        res.setHeader('authorization', newToken);

        const user = await User.findById(decoded.id);
        user!.token = newToken;

        await user?.save();

        if (!user) {
          console.log('no user found in verifyToken middleware');
          res.status(401).json({ message: 'Unauthorized' });
          return;
        }

        // Attach user to request
        req.user = { id: decoded.id };
        next();
      } catch (error) {
        console.error('Token verification error:', error);
        res.status(401).json({ message: 'Unauthorized' });
        return;
      }
    }
  }
};

const verifyTokenInternal = async (
  token: string,
  refreshToken: string
): Promise<string | null> => {
  try {
    jwt.verify(token, secret);
    return jwt.decode(token) as string | null;
  } catch (error) {
    try {
      jwt.verify(refreshToken!, refreshSecret);
      const decoded = jwt.decode(refreshToken!) as { id: string };
      const newToken = jwt.sign({ id: decoded.id }, secret, {
        expiresIn: '10s',
      });

      const user = await User.findById(decoded.id);
      user!.token = newToken;

      await user?.save();

      if (!user) {
        console.log('no user found in verifyToken middleware');

        return null;
      }
      return jwt.decode(newToken) as string | null;
    } catch (error) {
      console.error('Token verification error:', error);

      return null;
    }
  }
};

export {
  adminAppAuth,
  refreshSecret,
  secret,
  verifyToken,
  verifyTokenInternal,
};
