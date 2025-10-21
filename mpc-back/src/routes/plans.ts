import express from "express";

import { Request, Response } from "express";
import PlansController from "../controllers/web/plans";

import sgMail from "@sendgrid/mail";
import bodyParser from "body-parser";
import console from "console";
import fs from "fs";
import path from "path";
import { sendTrainingPlanEmail } from "../plan_webhook";
sgMail.setApiKey(process.env.SENDGRID_API_KEY!);
// Plans Router
const plansRouter = express.Router();
const plansController = new PlansController();

// Purchase Plan
plansRouter.post("/create-checkout-session", bodyParser.json(), plansController.createCheckoutSession);




const TRAINING_PLANS = {
  femaleLower: 'female-lower.xlsx',
  lower: 'lower.xlsx',
  upper: 'upper.xlsx',
  ppl: 'ppl.xlsx',
};


// webhook for Stripe
plansRouter.post(
  "/webhook",
  bodyParser.raw({ type: "application/json" }),

  async (req: Request, res: Response) : Promise<void> => {

  }
);




// Download specific training plan
plansRouter.get('/download-training-plan/:planType/:token', async (req: Request, res: Response): Promise<void> => {
  try {
    if (req.params.token !== process.env.TRAINING_PLAN_DOWNLOAD_TOKEN) {
      res.status(403).json({ error: 'Forbidden' });
      return;
    }

    const { planType } = req.params;

    // Validate plan type
    if (!TRAINING_PLANS[planType as keyof typeof TRAINING_PLANS]) {
       res.status(400).json({
        error: 'Invalid plan type',
        availablePlans: Object.keys(TRAINING_PLANS)
      });
      return;
    }

    // Get the filename
    const filename = TRAINING_PLANS[planType as keyof typeof TRAINING_PLANS];

    // Path to the template file
    const filePath = path.join(__dirname, '../../templates/plans', filename);
    console.log('File path:', filePath);

    // Check if file exists
    if (!fs.existsSync(filePath)) {
       res.status(404).json({ error: 'Training plan file not found' });
       return;
    }

    // Set headers for download
    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);

    // Stream the file
    const fileStream = fs.createReadStream(filePath);
    fileStream.pipe(res);

  } catch (error) {
    console.error('Error downloading training plan:', error);
    res.status(500).json({ error: 'Failed to download training plan' });
  }
});

plansRouter.post("/", async (req, res) => {
  sendTrainingPlanEmail("kamryydev@gmail.com", "upper", "1234567890");
    console.log('✅ Email sent successfully');
    res.status(200).send("Email sent");
  } );





export default plansRouter;

