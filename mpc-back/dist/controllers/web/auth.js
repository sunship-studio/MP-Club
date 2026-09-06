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
const fs_1 = require("fs");
const handlebars_1 = __importDefault(require("handlebars"));
const path_1 = __importDefault(require("path"));
const rate_limiter_flexible_1 = require("rate-limiter-flexible");
const resend_1 = __importDefault(require("../../config/resend"));
const auth_1 = require("../../services/auth");
const class_pass_1 = require("../../services/class_pass");
// Anyone can ask for a link for any address, so the endpoint is a mail cannon
// unless it is bounded. Per-address first (that is whose inbox suffers), then
// per-caller to stop one source working through a list.
const perEmail = new rate_limiter_flexible_1.RateLimiterMemory({ points: 3, duration: 15 * 60 });
const perCaller = new rate_limiter_flexible_1.RateLimiterMemory({ points: 20, duration: 60 * 60 });
const FROM = 'Midlands Performance Club <shanemahon@midlandsperformanceclub.ie>';
class AuthController {
    /**
     * Email a sign-in link.
     *
     * Always answers the same way. Saying "no account found" would turn this into
     * a membership oracle: anyone could test an address and learn whether that
     * person trains here.
     */
    requestSignInLink(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b, _c;
            const generic = {
                message: 'If we can reach you at that address, a sign-in link is on its way.',
            };
            try {
                const email = (0, auth_1.normaliseEmail)(String((_b = (_a = req.body) === null || _a === void 0 ? void 0 : _a.email) !== null && _b !== void 0 ? _b : ''));
                if (!email || !email.includes('@')) {
                    res.status(400).json({ error: 'Please enter a valid email address' });
                    return;
                }
                try {
                    yield perCaller.consume((_c = req.ip) !== null && _c !== void 0 ? _c : 'unknown');
                    yield perEmail.consume(email);
                }
                catch (_d) {
                    res.status(429).json({
                        error: 'Too many sign-in emails just now. Try again in a few minutes.',
                    });
                    return;
                }
                const customer = yield (0, auth_1.findOrCreateCustomer)(email);
                const token = yield (0, auth_1.createLoginToken)(customer);
                const templatePath = path_1.default.join(__dirname, '../../../', 'templates', 'sign_in_link.html');
                const html = handlebars_1.default.compile((0, fs_1.readFileSync)(templatePath, 'utf8'))({
                    signInLink: `${(0, class_pass_1.siteBaseUrl)()}/sign-in?token=${token}`,
                });
                yield resend_1.default.emails.send({
                    from: FROM,
                    to: email,
                    subject: 'Your sign-in link',
                    html,
                });
                res.status(200).json(generic);
            }
            catch (error) {
                console.error('Error sending sign-in link:', error);
                // Still generic: a failure here must not become a signal either.
                res.status(200).json(generic);
            }
        });
    }
    /** Exchange a sign-in link for a session. */
    verifySignInLink(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            var _a, _b;
            try {
                const token = String((_b = (_a = req.body) === null || _a === void 0 ? void 0 : _a.token) !== null && _b !== void 0 ? _b : '');
                if (!token) {
                    res.status(400).json({ error: 'A sign-in token is required' });
                    return;
                }
                const customer = yield (0, auth_1.consumeLoginToken)(token);
                if (!customer) {
                    res.status(401).json({
                        error: 'That sign-in link has already been used or has expired. Request a new one.',
                    });
                    return;
                }
                const session = yield (0, auth_1.createSession)(customer);
                res.cookie(auth_1.SESSION_COOKIE, session, (0, auth_1.sessionCookieOptions)());
                // The session value goes in the cookie and nowhere else, so no script on
                // the page can read it back out of a response body.
                res.status(200).json(this.publicCustomer(customer));
            }
            catch (error) {
                console.error('Error verifying sign-in link:', error);
                res.status(500).json({ error: 'Could not sign you in' });
            }
        });
    }
    /** Who is signed in, if anyone. Never an error — being anonymous is normal. */
    getCurrentCustomer(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                const customer = yield (0, auth_1.customerFromRequest)(req);
                if (!customer) {
                    res.status(200).json({ signedIn: false });
                    return;
                }
                res.status(200).json(Object.assign({ signedIn: true }, this.publicCustomer(customer)));
            }
            catch (error) {
                console.error('Error reading session:', error);
                res.status(200).json({ signedIn: false });
            }
        });
    }
    signOut(req, res) {
        return __awaiter(this, void 0, void 0, function* () {
            try {
                yield (0, auth_1.revokeSession)((0, auth_1.readCookie)(req, auth_1.SESSION_COOKIE));
                res.clearCookie(auth_1.SESSION_COOKIE, Object.assign(Object.assign({}, (0, auth_1.sessionCookieOptions)()), { maxAge: undefined }));
                res.status(200).json({ signedOut: true });
            }
            catch (error) {
                console.error('Error signing out:', error);
                res.status(500).json({ error: 'Could not sign you out' });
            }
        });
    }
    publicCustomer(customer) {
        return {
            email: customer.email,
            firstName: customer.firstName,
            lastName: customer.lastName,
        };
    }
}
exports.default = AuthController;
