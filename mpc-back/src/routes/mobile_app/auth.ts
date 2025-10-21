import crypto from "crypto";
import express from "express";
import fs from "fs";
import path from "path";
import { AuthController } from "../../controllers/mobile/auth";
import { verifyToken } from "../../middleware/auth";
import PasswordResetToken from "../../models/PasswordResetToken";
import User from "../../models/User";
const authRouter = express.Router();

authRouter.post("/check-email", async (req, res) => {
  try {
    console.log("Request body:", req.body);
    const { email } = req.body;

    const data = await AuthController.checkEmail(email);
    console.log("Email check data:", data);
    res.json({ exists: data.exists, hasPassword: data.hasPassword });
  } catch (error) {
    res.status(500).json({ message: "Error checking email" });
  }
});

authRouter.post("/set-password", async (req, res) => {
  const { email, newPassword } = req.body;
  const result = await AuthController.setPassword(email, newPassword);
  res.setHeader("authorization", result?.token || "");
  res.setHeader("x-refresh-token", result?.refreshToken || "");
  res.json({
    message: "Password set successfully",

  });
});

authRouter.post("/login", async (req, res) => {
  const { email, password } = req.body;
  const tokens = await AuthController.login(email, password);
  res.setHeader("authorization", tokens?.token || "");
  res.setHeader("x-refresh-token", tokens?.refreshToken || "");
  if (tokens) {
    res.json({
      message: "Login successful",

    });
  } else {
    res.status(401).json({ message: "Invalid email or password" });
  }
});

authRouter.get('/verify-reset-token/:token', async (req, res) => {
  try {
    const { token } = req.params;
    const hashedToken = crypto.createHash('sha256').update(token).digest('hex');

    const resetTokenDoc = await PasswordResetToken.findOne({ token: hashedToken, used: false });
    if (!resetTokenDoc || resetTokenDoc.expiry < Date.now()) {
        res.status(400).json({ valid: false, message: 'Invalid or expired token' });
        return;
      }
    res.json({ valid: true, message: 'Token is valid' });
  }
    catch (error) {
    console.error('Error verifying reset token:', error);
    res.status(500).json({ valid: false, message: 'Server error' });
  }

});

authRouter.post("/forgot-password", async (req, res): Promise<void> =>  {
try {
    const { email } = req.body;

    if (!email) {
       res.status(400).json({ error: 'Email is required' });
        return;
    }


    const user = await User.findOne({ email });
    if (!user) {
       res.status(404).json({ error: 'User not found' });
       return;
    }

    // Generate secure token
    const resetToken = crypto.randomBytes(32).toString('hex');
    const hashedToken = crypto.createHash('sha256').update(resetToken).digest('hex');
    const expiry = Date.now() + 3600000; // 1 hour

    PasswordResetToken.create({
      userId: user._id,
      token: hashedToken,
      expiry: expiry,
      used: false
    })

    // Create deep link
    const deepLink =  createResetLink(resetToken);


    try {
    await sendPasswordResetEmail(email, deepLink);
    } catch (emailError) {
      console.error('Error sending password reset email:', emailError);
        res.status(500).json({ error: 'Failed to send reset link' });
        return;
      }
    // Send email


    res.json({
      message: 'Password reset link sent to your email',
      // For testing only - remove in production
      ...(process.env.NODE_ENV === 'development' && { resetLink: deepLink })
    });

  } catch (error: any) {
    console.error('Error requesting password reset:', error);
    res.status(500).json({ error: 'Failed to send reset link' });
  }
});

 function createResetLink(token: string): string{
  const baseUrl =  'https://mp-club-production.up.railway.app/mobile-app/auth/';
  return `${baseUrl}reset-password?token=${token}`;
}

async function sendPasswordResetEmail(email: string, link: string): Promise<void> {
  const sgMail = require('@sendgrid/mail');
  sgMail.setApiKey(process.env.SENDGRID_API_KEY!);

  const templatePath = path.join(__dirname, '../../../templates/forgot_password.html');
  let template = fs.readFileSync(templatePath, 'utf-8');
  template = template.replace('{{resetLink}}', link);


  const msg = {
    to: email,
    from: 'forgot_password@midlandsperformanceclub.ie',
    subject: 'Password Reset Request',
    html: template,
  };

  await sgMail.send(msg);
  console.log('Password reset email sent');

}

authRouter.get('/reset-password', (req, res) => {
  const token = req.query.token as string;

  if (!token) {
     res.status(400).send('Invalid reset link');


  }

  // Send HTML page that attempts to open the app
  const html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Reset Password - MPC</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
      background: linear-gradient(135deg, #002638 0%, #004d6b 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }

    .container {
      background: white;
      border-radius: 16px;
      padding: 40px;
      max-width: 500px;
      width: 100%;
      text-align: center;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    }

    .logo {
      width: 120px;
      height: 120px;
      margin: 0 auto 30px;
      background: #002638;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 48px;
      color: white;
    }

    h1 {
      color: #002638;
      font-size: 28px;
      margin-bottom: 16px;
    }

    p {
      color: #666;
      font-size: 16px;
      line-height: 1.6;
      margin-bottom: 30px;
    }

    .spinner {
      width: 50px;
      height: 50px;
      margin: 20px auto;
      border: 4px solid #f3f3f3;
      border-top: 4px solid #002638;
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }

    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }

    .buttons {
      display: flex;
      flex-direction: column;
      gap: 12px;
      margin-top: 30px;
    }

    .btn {
      display: inline-block;
      padding: 14px 28px;
      text-decoration: none;
      border-radius: 8px;
      font-weight: 600;
      font-size: 16px;
      transition: all 0.3s;
    }

    .btn-primary {
      background: #002638;
      color: white;
    }

    .btn-primary:hover {
      background: #003d52;
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(0, 38, 56, 0.3);
    }

    .btn-secondary {
      background: #f3f4f6;
      color: #002638;
    }

    .btn-secondary:hover {
      background: #e5e7eb;
    }

    .stores {
      display: flex;
      gap: 12px;
      justify-content: center;
      margin-top: 20px;
    }

    .store-badge {
      height: 50px;
    }

    #fallback {
      display: none;
    }

    .success {
      color: #059669;
      font-weight: 600;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="logo">🏋️</div>

    <div id="opening">
      <h1>Opening MPC App...</h1>
      <div class="spinner"></div>
      <p>If the app doesn't open automatically, click the button below.</p>
      <button class="btn btn-primary" onclick="openApp()">Open MPC App</button>
    </div>

    <div id="fallback">
      <h1>App Not Installed?</h1>
      <p>Download the MPC app to reset your password and access your training plans.</p>

      <div class="stores">
        <a href="https://apps.apple.com/app/mpc" target="_blank">
          <img src="https://tools.applemediaservices.com/api/badges/download-on-the-app-store/black/en-us?size=250x83"
               alt="Download on App Store"
               class="store-badge">
        </a>
        <a href="https://play.google.com/store/apps/details?id=com.mpc" target="_blank">
          <img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
               alt="Get it on Google Play"
               class="store-badge">
        </a>
      </div>

      <div class="buttons">
        <button class="btn btn-secondary" onclick="openApp()">Try Opening App Again</button>
      </div>
    </div>
  </div>

  <script>
    const token = '${token}';
    const deepLink = \`mpc://reset-password?token=\${token}\`;
    const appStoreUrl = 'https://apps.apple.com/app/mpc';
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.mpc';

    function openApp() {
      // Try to open the app
      window.location.href = deepLink;

      // Track if user left the page (app opened)
      let appOpened = false;

      window.addEventListener('blur', () => {
        appOpened = true;
      });

      // Show fallback after 2 seconds if app didn't open
      setTimeout(() => {
        if (!appOpened && document.visibilityState === 'visible') {
          showFallback();
        }
      }, 2000);
    }

    function showFallback() {
      document.getElementById('opening').style.display = 'none';
      document.getElementById('fallback').style.display = 'block';
    }

    // Detect platform and adjust store links
    function detectPlatform() {
      const userAgent = navigator.userAgent.toLowerCase();
      const isIOS = /iphone|ipad|ipod/.test(userAgent);
      const isAndroid = /android/.test(userAgent);

      // Hide the store badge that's not relevant
      if (isIOS) {
        document.querySelector('a[href*="play.google"]').style.display = 'none';
      } else if (isAndroid) {
        document.querySelector('a[href*="apps.apple"]').style.display = 'none';
      }
    }

    // Try to open app immediately when page loads
    window.onload = () => {
      detectPlatform();
      openApp();
    };

    // Handle visibility change (app coming back to foreground)
    document.addEventListener('visibilitychange', () => {
      if (document.visibilityState === 'visible') {
        // User came back - app might not be installed
        setTimeout(showFallback, 500);
      }
    });
  </script>
</body>
</html>
  `;

  res.send(html);
});

authRouter.get("/user", verifyToken,  (req, res) =>
   AuthController.getUser(req, res)
);



export default authRouter;
