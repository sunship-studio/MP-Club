/**
 * Seeds the sellable class-pass products.
 *
 * Products are seeded rather than admin-editable (D11): pricing changes twice a
 * year at most, so a product-editor screen is the expensive half of the admin
 * work for the least return.
 *
 * Run: npx ts-node src/scripts/seed_class_passes.ts
 */
import mongoose from 'mongoose';

import connectToDatabase from '../config/database';
import ClassPassProduct, { IClassPassProduct } from '../models/ClassPassProduct';

export interface PassProductSpec {
  name: string;
  months: number;
  priceCents: number;
  currency: string;
  /** Off unless the product is meant to be sold recurring (D17). */
  allowSubscription?: boolean;
}

/**
 * €90 a month, sellable recurring — what Shane asked for on 2026-09-04 (D17).
 */
export const MONTHLY_PASS_PRODUCT: PassProductSpec = {
  name: '1 Month Unlimited',
  months: 1,
  priceCents: 9000,
  currency: 'eur',
  allowSubscription: true,
};

/**
 * The pass this feature launched with. Off sale since D17, and kept here only
 * so the retirement is expressed as data rather than a hand-typed name.
 */
export const LEGACY_QUARTERLY_PASS_PRODUCT: PassProductSpec = {
  name: '3 Months Unlimited',
  months: 3,
  priceCents: 30000,
  currency: 'eur',
};

/** What `seedClassPassProduct()` puts on sale when asked for nothing specific. */
export const DEFAULT_PASS_PRODUCT: PassProductSpec = MONTHLY_PASS_PRODUCT;

/**
 * Put a product on sale, superseding any earlier version of it.
 *
 * A price change never edits an existing product: passes reference the product
 * they were sold under, and a €300 pass must keep pointing at a €300 product
 * however the price moves afterwards. So the old row is taken off sale and a
 * new one created. Re-running with an unchanged spec is a no-op.
 */
export async function seedClassPassProduct(
  spec: PassProductSpec = DEFAULT_PASS_PRODUCT
): Promise<IClassPassProduct> {
  const allowSubscription = spec.allowSubscription ?? false;

  const existing = await ClassPassProduct.findOne({
    name: spec.name,
    months: spec.months,
    priceCents: spec.priceCents,
    currency: spec.currency,
  });

  // Only one version of a given pass is ever on sale at a time.
  await ClassPassProduct.updateMany(
    existing
      ? { name: spec.name, _id: { $ne: existing._id } }
      : { name: spec.name },
    { $set: { active: false } }
  );

  if (existing) {
    // Billing mode is not a price, so flipping it edits the product in place
    // rather than superseding it: passes already sold under it are unaffected.
    if (!existing.active || existing.allowSubscription !== allowSubscription) {
      existing.active = true;
      existing.allowSubscription = allowSubscription;
      await existing.save();
    }
    return existing;
  }

  return ClassPassProduct.create({ ...spec, allowSubscription, active: true });
}

/**
 * Take a product off sale by name. Never deletes: a pass references the product
 * it was sold under, and a €300 pass must keep resolving its own name however
 * the catalogue moves on. Returns how many rows it retired.
 */
export async function retirePassProduct(name: string): Promise<number> {
  const result = await ClassPassProduct.updateMany(
    { name, active: true },
    { $set: { active: false } }
  );
  return result.modifiedCount;
}

async function main(): Promise<void> {
  await connectToDatabase();

  const product = await seedClassPassProduct();
  console.log(
    `Seeded pass product: ${product.name} — ${product.months} months, ` +
      `${(product.priceCents / 100).toFixed(2)} ${product.currency.toUpperCase()}` +
      `${product.allowSubscription ? ' (recurring available)' : ''}`
  );

  const retired = await retirePassProduct(LEGACY_QUARTERLY_PASS_PRODUCT.name);
  if (retired > 0) {
    console.log(`Took off sale: ${LEGACY_QUARTERLY_PASS_PRODUCT.name}`);
  }

  await mongoose.disconnect();
}

if (require.main === module) {
  main().catch((error) => {
    console.error('Failed to seed class pass products:', error);
    process.exit(1);
  });
}
