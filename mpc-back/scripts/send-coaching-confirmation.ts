/**
 * Script to manually send online coaching confirmation email
 * Usage: npx ts-node scripts/send-coaching-confirmation.ts
 */

import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';
import { Resend } from 'resend';

dotenv.config();

const RESEND_API_KEY = process.env.RESEND_API_KEY!;

// Client data for manual email send
const CLIENT_DATA = {
  email: 'seankeenansk@live.co.uk',
  firstName: 'Sean',
};

async function sendConfirmationEmail() {
  console.log('Sending confirmation email to:', CLIENT_DATA.email);

  // Read template
  const templatePath = path.join(
    process.cwd(),
    'templates',
    'online_coaching_confirmation.html'
  );
  const templateSource = fs.readFileSync(templatePath, 'utf8');
  const htmlContent = templateSource.replace(
    '{{firstName}}',
    CLIENT_DATA.firstName || ''
  );

  // Send email
  const resend = new Resend(RESEND_API_KEY);

  const { data, error } = await resend.emails.send({
    from: 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>',
    to: [CLIENT_DATA.email],
    subject: 'Subscription Confirmation',
    html: htmlContent,
  });

  if (error) {
    console.error('Error sending email:', error);
    process.exit(1);
  }

  console.log('✅ Email sent successfully:', data);
  console.log('Done!');
}

sendConfirmationEmail().catch((err) => {
  console.error('Error:', err);
  process.exit(1);
});
