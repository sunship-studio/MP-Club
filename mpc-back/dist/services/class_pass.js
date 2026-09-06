"use strict";
/**
 * Term maths and entitlement for fixed-term class passes.
 *
 * Dates here are plain `"YYYY-MM-DD"` strings and are never converted to `Date`.
 * The codebase mixes local dates (`toLocalDateString`) with UTC
 * (`new Date(d).toISOString().split('T')[0]`), which is off by a day in Irish
 * summer time — precisely at the expiry boundary this product sells. Strings
 * compare lexicographically, which is exactly calendar order for this format.
 *
 * See docs/specs/class-pass.md — D3 (term), D4 (gate on the class date),
 * D7 (one active pass), D9 (revoke), D15 (no date fallback).
 */
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.isPassDateString = isPassDateString;
exports.computeTerm = computeTerm;
exports.extendTerm = extendTerm;
exports.passCovers = passCovers;
exports.venueToday = venueToday;
exports.activatePass = activatePass;
exports.findActivePassForEmail = findActivePassForEmail;
exports.applyRenewalInvoice = applyRenewalInvoice;
exports.siteBaseUrl = siteBaseUrl;
exports.renderPassPurchaseEmail = renderPassPurchaseEmail;
exports.renderPassRenewalEmail = renderPassRenewalEmail;
const fs_1 = require("fs");
const path_1 = __importDefault(require("path"));
const handlebars_1 = __importDefault(require("handlebars"));
const ClassPass_1 = __importDefault(require("../models/ClassPass"));
const ClassPassProduct_1 = __importDefault(require("../models/ClassPassProduct"));
const DATE_PATTERN = /^\d{4}-\d{2}-\d{2}$/;
/** Whether a value is a well-formed calendar date string. No coercion (D15). */
function isPassDateString(value) {
    if (typeof value !== 'string' || !DATE_PATTERN.test(value))
        return false;
    try {
        parseDate(value, 'date');
        return true;
    }
    catch (_a) {
        return false;
    }
}
function isLeapYear(year) {
    return year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0);
}
function daysInMonth(year, month) {
    if (month === 2)
        return isLeapYear(year) ? 29 : 28;
    return [4, 6, 9, 11].includes(month) ? 30 : 31;
}
/**
 * Parse a `"YYYY-MM-DD"` string, rejecting anything else. Deliberately strict:
 * a silently coerced date is a wrong expiry date on a €300 product.
 */
function parseDate(value, label) {
    if (typeof value !== 'string' || !DATE_PATTERN.test(value)) {
        throw new Error(`${label} must be a "YYYY-MM-DD" date string, got: ${String(value)}`);
    }
    const year = Number(value.slice(0, 4));
    const month = Number(value.slice(5, 7));
    const day = Number(value.slice(8, 10));
    if (month < 1 || month > 12 || day < 1 || day > daysInMonth(year, month)) {
        throw new Error(`${label} is not a real calendar date: ${value}`);
    }
    return { year, month, day };
}
function formatDate(year, month, day) {
    return `${String(year).padStart(4, '0')}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
}
/**
 * The term a pass bought on `purchaseDate` runs for: anniversary-inclusive, so
 * 3 months from 2026-09-01 is valid *through* 2026-12-01. Where the anniversary
 * does not exist the end clamps to the last day of that month (2026-08-31 + 3
 * months → 2026-11-30). Slightly generous by a day, which is the right
 * direction to err on a non-refundable product (D3).
 */
function computeTerm(purchaseDate, months) {
    return {
        validFromDate: purchaseDate,
        validUntilDate: addMonths(purchaseDate, months, 'purchaseDate'),
    };
}
/**
 * Where a renewal pushes a pass's end date to (D18).
 *
 * It counts from the pass's current end date, not from the day the money
 * arrived: Stripe bills a few days before the term runs out, so counting from
 * the payment date would quietly cost the customer those days every month.
 *
 * The exception is a pass that already lapsed — a charge that failed and later
 * succeeded, say. Its end date is in the past, and extending from it would hand
 * back a pass born expired. There the term starts today.
 */
function extendTerm(currentValidUntilDate, months, today = venueToday()) {
    parseDate(currentValidUntilDate, 'currentValidUntilDate');
    parseDate(today, 'today');
    const from = currentValidUntilDate < today ? today : currentValidUntilDate;
    return addMonths(from, months, 'currentValidUntilDate');
}
/**
 * `date` plus `months` calendar months, clamped to the last day of the target
 * month where the anniversary does not exist (31 Jan + 1 month → 28 Feb).
 * Clamping down rather than spilling into the next month keeps a term inside
 * the month it was sold for.
 */
function addMonths(date, months, label) {
    const { year, month, day } = parseDate(date, label);
    if (!Number.isInteger(months) || months < 1) {
        throw new Error(`months must be a positive whole number, got: ${String(months)}`);
    }
    const monthsFromYearZero = year * 12 + (month - 1) + months;
    const endYear = Math.floor(monthsFromYearZero / 12);
    const endMonth = (monthsFromYearZero % 12) + 1;
    return formatDate(endYear, endMonth, Math.min(day, daysInMonth(endYear, endMonth)));
}
/**
 * Whether a pass covers a given date: one rule, asked at two moments.
 *
 * Booking asks about the date the class *runs*, never the date the booking is
 * made — gating on the booking date would let a holder spend their last valid
 * day booking classes dated after their term ended (D4).
 *
 * Purchase asks about today, for the D7 stacking check. That is the same
 * question because `validFromDate` is always the purchase day, so a pass is
 * never future-dated and "live today" is just "covers today".
 */
function passCovers(pass, occurrenceDate) {
    parseDate(occurrenceDate, 'occurrenceDate');
    if (pass.revoked)
        return false;
    return pass.validFromDate <= occurrenceDate && occurrenceDate <= pass.validUntilDate;
}
// ---------------------------------------------------------------------------
// Purchase
// ---------------------------------------------------------------------------
const VENUE_TIME_ZONE = 'Europe/Dublin';
/**
 * Today at the venue, as a `"YYYY-MM-DD"` string.
 *
 * Not `toLocalDateString`: that reads the *server's* clock, which is UTC on
 * Heroku, so between midnight and 1am Irish summer time it names yesterday.
 * A pass bought at 00:30 would then be dated a day early and expire a day
 * early (D3).
 */
function venueToday(now = new Date()) {
    return new Intl.DateTimeFormat('en-CA', {
        timeZone: VENUE_TIME_ZONE,
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
    }).format(now);
}
/**
 * Turn a completed payment into a usable pass.
 *
 * Idempotent on `stripeSessionId`: Stripe redelivers webhooks, and a redelivery
 * must not extend a term, mint a second token, or take a second €300 (D14).
 * The unique sparse index on `stripeSessionId` is what makes that hold under
 * simultaneous redelivery, not the read below — the read is just the fast path.
 */
function activatePass(input) {
    return __awaiter(this, void 0, void 0, function* () {
        var _a, _b;
        const email = input.email.trim().toLowerCase();
        if (input.stripeSessionId) {
            const existing = yield ClassPass_1.default.findOne({ stripeSessionId: input.stripeSessionId });
            if (existing)
                return existing;
        }
        const product = yield ClassPassProduct_1.default.findById(input.productId);
        if (!product) {
            throw new Error(`Unknown class pass product: ${input.productId}`);
        }
        const purchaseDate = (_a = input.purchaseDate) !== null && _a !== void 0 ? _a : venueToday();
        const term = computeTerm(purchaseDate, product.months);
        try {
            return yield ClassPass_1.default.create({
                email,
                firstName: input.firstName,
                lastName: input.lastName,
                productId: product._id,
                months: product.months,
                pricePaidCents: product.priceCents,
                validFromDate: term.validFromDate,
                validUntilDate: term.validUntilDate,
                revoked: false,
                purchasedAt: new Date(),
                stripeSessionId: input.stripeSessionId,
                grantedByAdmin: (_b = input.grantedByAdmin) !== null && _b !== void 0 ? _b : false,
                stripeSubscriptionId: input.stripeSubscriptionId,
                // A pass only renews if it was sold as a subscription. Stripe is asked
                // for the real state on the first `customer.subscription.*` event.
                autoRenew: Boolean(input.stripeSubscriptionId),
                subscriptionStatus: input.stripeSubscriptionId ? 'active' : undefined,
                consumedInvoiceIds: [],
            });
        }
        catch (error) {
            // Lost a race with a concurrent redelivery of the same session.
            if ((error === null || error === void 0 ? void 0 : error.code) === 11000 && input.stripeSessionId) {
                const winner = yield ClassPass_1.default.findOne({ stripeSessionId: input.stripeSessionId });
                if (winner)
                    return winner;
            }
            throw error;
        }
    });
}
/**
 * The pass this email is currently holding, or null. Used for the D7 stacking
 * check at purchase and to tell a would-be buyer when their current pass ends.
 * Email is matched case-insensitively because the booking form takes it as
 * free text and people capitalise inconsistently.
 */
function findActivePassForEmail(email_1) {
    return __awaiter(this, arguments, void 0, function* (email, onDate = venueToday()) {
        parseDate(onDate, 'onDate');
        return ClassPass_1.default.findOne({
            email: email.trim().toLowerCase(),
            revoked: false,
            validFromDate: { $lte: onDate },
            validUntilDate: { $gte: onDate },
        });
    });
}
/**
 * The public site's base URL, matching the checkout redirect targets already
 * used for group-class bookings.
 */
/**
 * Spend a paid invoice on the pass its subscription belongs to (D18).
 *
 * Extending an existing pass rather than creating one is what keeps a
 * subscriber from tripping the one-active-pass rule against themselves (D7).
 *
 * Returns `null` when no pass owns the subscription — an invoice for something
 * else, or a pass deleted out from under it. That is not an error: the webhook
 * must still acknowledge, or Stripe retries forever.
 */
function applyRenewalInvoice(input) {
    return __awaiter(this, void 0, void 0, function* () {
        var _a;
        const today = (_a = input.today) !== null && _a !== void 0 ? _a : venueToday();
        parseDate(today, 'today');
        const pass = yield ClassPass_1.default.findOne({
            stripeSubscriptionId: input.stripeSubscriptionId,
        });
        if (!pass)
            return null;
        // A revoked pass keeps its dates. Extending one would hand back the
        // entitlement an admin just took away (D9); stopping the charge is a
        // separate job, done at revoke time.
        if (pass.revoked)
            return { pass, extended: false };
        if (pass.consumedInvoiceIds.includes(input.invoiceId)) {
            return { pass, extended: false };
        }
        const newValidUntil = extendTerm(pass.validUntilDate, pass.months, today);
        // Compare-and-set on the end date and the invoice together: a redelivery
        // racing itself must move the date exactly once.
        const result = yield ClassPass_1.default.updateOne({
            _id: pass._id,
            validUntilDate: pass.validUntilDate,
            consumedInvoiceIds: { $ne: input.invoiceId },
        }, {
            $set: { validUntilDate: newValidUntil },
            $push: { consumedInvoiceIds: input.invoiceId },
            $inc: { __v: 1 },
        });
        const current = (yield ClassPass_1.default.findById(pass._id));
        return { pass: current, extended: result.modifiedCount === 1 };
    });
}
function siteBaseUrl() {
    return process.env.NODE_ENV === 'development'
        ? 'http://localhost:3000'
        : 'https://midlandsperformanceclub.ie';
}
/**
 * The confirmation email: the exact expiry date and the non-refundable terms,
 * because this and the purchase page are the only places they are stated (D5),
 * plus a sign-in link so buying flows straight into booking.
 *
 * The link is a convenience now, not a credential — losing this email costs
 * nothing, since signing in again restores everything (D16).
 */
function renderPassPurchaseEmail(input) {
    const templatePath = path_1.default.join(__dirname, '../../', 'templates', 'class_pass_purchase.html');
    const template = handlebars_1.default.compile((0, fs_1.readFileSync)(templatePath, 'utf8'));
    return template({
        firstName: input.firstName,
        productName: input.productName,
        signInLink: input.signInLink,
        validUntilDate: input.validUntilDate,
        pricePaid: (input.pricePaidCents / 100).toFixed(2),
    });
}
/** The "we took your money and here is what you got" note for a renewal (D18). */
function renderPassRenewalEmail(input) {
    const templatePath = path_1.default.join(__dirname, '../../', 'templates', 'class_pass_renewal.html');
    const template = handlebars_1.default.compile((0, fs_1.readFileSync)(templatePath, 'utf8'));
    return template({
        firstName: input.firstName,
        productName: input.productName,
        validUntilDate: input.validUntilDate,
        pricePaid: (input.pricePaidCents / 100).toFixed(2),
        manageLink: input.manageLink,
    });
}
