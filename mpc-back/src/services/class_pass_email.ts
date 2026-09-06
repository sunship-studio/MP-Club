/**
 * Sending pass emails.
 *
 * Split from `class_pass.ts` deliberately: importing the Resend client throws
 * at module load when no API key is set, and the term/entitlement logic must
 * stay importable without one.
 */
import resend from '../config/resend';
import ClassPassProduct from '../models/ClassPassProduct';
import { IClassPass } from '../models/ClassPass';
import { createLoginToken, findOrCreateCustomer } from './auth';
import { renderPassPurchaseEmail, renderPassRenewalEmail, siteBaseUrl } from './class_pass';

const FROM = 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>';

/**
 * Confirm a pass and sign its holder in.
 *
 * The link is single-use and short-lived — it saves the buyer a round trip
 * through the sign-in form, and losing this email costs nothing (D16).
 */
export async function sendPassLinkEmail(pass: IClassPass): Promise<void> {
  const product = await ClassPassProduct.findById(pass.productId).lean();

  const customer = await findOrCreateCustomer(pass.email, {
    firstName: pass.firstName,
    lastName: pass.lastName,
  });
  const token = await createLoginToken(customer);

  const html = renderPassPurchaseEmail({
    firstName: pass.firstName,
    productName: product?.name ?? `${pass.months} Month Pass`,
    signInLink: `${siteBaseUrl()}/sign-in?token=${token}`,
    validUntilDate: pass.validUntilDate,
    pricePaidCents: pass.pricePaidCents,
  });

  await resend.emails.send({
    from: FROM,
    to: pass.email,
    subject: 'Your class pass is active',
    html,
  });
}

/**
 * Tell a member their membership renewed and how long it now runs.
 *
 * No sign-in link here: this is a receipt, not an invitation, and a renewal
 * arrives every month. Anyone who needs back in asks for a link on the site.
 */
export async function sendPassRenewalEmail(pass: IClassPass): Promise<void> {
  const product = await ClassPassProduct.findById(pass.productId).lean();

  const html = renderPassRenewalEmail({
    firstName: pass.firstName,
    productName: product?.name ?? `${pass.months} Month Pass`,
    validUntilDate: pass.validUntilDate,
    pricePaidCents: pass.pricePaidCents,
    manageLink: `${siteBaseUrl()}/group-classes`,
  });

  await resend.emails.send({
    from: FROM,
    to: pass.email,
    subject: 'Your membership renewed',
    html,
  });
}
