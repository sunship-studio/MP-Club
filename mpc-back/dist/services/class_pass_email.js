"use strict";
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
exports.sendPassLinkEmail = sendPassLinkEmail;
exports.sendPassRenewalEmail = sendPassRenewalEmail;
/**
 * Sending pass emails.
 *
 * Split from `class_pass.ts` deliberately: importing the Resend client throws
 * at module load when no API key is set, and the term/entitlement logic must
 * stay importable without one.
 */
const resend_1 = __importDefault(require("../config/resend"));
const ClassPassProduct_1 = __importDefault(require("../models/ClassPassProduct"));
const auth_1 = require("./auth");
const class_pass_1 = require("./class_pass");
const FROM = 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>';
/**
 * Confirm a pass and sign its holder in.
 *
 * The link is single-use and short-lived — it saves the buyer a round trip
 * through the sign-in form, and losing this email costs nothing (D16).
 */
function sendPassLinkEmail(pass) {
    return __awaiter(this, void 0, void 0, function* () {
        var _a;
        const product = yield ClassPassProduct_1.default.findById(pass.productId).lean();
        const customer = yield (0, auth_1.findOrCreateCustomer)(pass.email, {
            firstName: pass.firstName,
            lastName: pass.lastName,
        });
        const token = yield (0, auth_1.createLoginToken)(customer);
        const html = (0, class_pass_1.renderPassPurchaseEmail)({
            firstName: pass.firstName,
            productName: (_a = product === null || product === void 0 ? void 0 : product.name) !== null && _a !== void 0 ? _a : `${pass.months} Month Pass`,
            signInLink: `${(0, class_pass_1.siteBaseUrl)()}/sign-in?token=${token}`,
            validUntilDate: pass.validUntilDate,
            pricePaidCents: pass.pricePaidCents,
        });
        yield resend_1.default.emails.send({
            from: FROM,
            to: pass.email,
            subject: 'Your class pass is active',
            html,
        });
    });
}
/**
 * Tell a member their membership renewed and how long it now runs.
 *
 * No sign-in link here: this is a receipt, not an invitation, and a renewal
 * arrives every month. Anyone who needs back in asks for a link on the site.
 */
function sendPassRenewalEmail(pass) {
    return __awaiter(this, void 0, void 0, function* () {
        var _a;
        const product = yield ClassPassProduct_1.default.findById(pass.productId).lean();
        const html = (0, class_pass_1.renderPassRenewalEmail)({
            firstName: pass.firstName,
            productName: (_a = product === null || product === void 0 ? void 0 : product.name) !== null && _a !== void 0 ? _a : `${pass.months} Month Pass`,
            validUntilDate: pass.validUntilDate,
            pricePaidCents: pass.pricePaidCents,
            manageLink: `${(0, class_pass_1.siteBaseUrl)()}/group-classes`,
        });
        yield resend_1.default.emails.send({
            from: FROM,
            to: pass.email,
            subject: 'Your membership renewed',
            html,
        });
    });
}
