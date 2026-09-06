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
exports.sessionCookieOptions = exports.SESSION_COOKIE = void 0;
exports.normaliseEmail = normaliseEmail;
exports.findOrCreateCustomer = findOrCreateCustomer;
exports.createLoginToken = createLoginToken;
exports.consumeLoginToken = consumeLoginToken;
exports.createSession = createSession;
exports.readCookie = readCookie;
exports.customerFromRequest = customerFromRequest;
exports.revokeSession = revokeSession;
/**
 * Passwordless sign-in: single-use emailed links exchanged for server-side
 * sessions (D16).
 *
 * Raw secrets are never stored. What goes in the database is a SHA-256 hash,
 * so a database read yields nothing anyone can sign in with. The raw value
 * exists only in the email and in the browser's cookie.
 */
const crypto_1 = require("crypto");
const Customer_1 = __importDefault(require("../models/Customer"));
const LoginToken_1 = __importDefault(require("../models/LoginToken"));
const Session_1 = __importDefault(require("../models/Session"));
exports.SESSION_COOKIE = 'mpc_session';
/** Long enough that people are not signed out mid-term on a 3-month pass. */
const SESSION_TTL_MS = 90 * 24 * 60 * 60 * 1000;
/** Short enough that a forwarded or shoulder-surfed email goes stale fast. */
const LOGIN_TOKEN_TTL_MS = 20 * 60 * 1000;
function hash(raw) {
    return (0, crypto_1.createHash)('sha256').update(raw).digest('hex');
}
function secret() {
    return (0, crypto_1.randomBytes)(32).toString('base64url');
}
function normaliseEmail(email) {
    return email.trim().toLowerCase();
}
/**
 * The customer for an email, creating one if this is the first we've seen of
 * them. Names are filled in when known and never overwritten with nothing.
 */
function findOrCreateCustomer(email_1) {
    return __awaiter(this, arguments, void 0, function* (email, names = {}) {
        const normalised = normaliseEmail(email);
        const update = { email: normalised };
        if (names.firstName)
            update.firstName = names.firstName;
        if (names.lastName)
            update.lastName = names.lastName;
        return Customer_1.default.findOneAndUpdate({ email: normalised }, { $set: update, $setOnInsert: { createdAt: new Date() } }, { new: true, upsert: true });
    });
}
/** Mint a sign-in link secret. The caller emails it; we keep only its hash. */
function createLoginToken(customer) {
    return __awaiter(this, void 0, void 0, function* () {
        const raw = secret();
        yield LoginToken_1.default.create({
            tokenHash: hash(raw),
            customerId: customer._id,
            expiresAt: new Date(Date.now() + LOGIN_TOKEN_TTL_MS),
        });
        return raw;
    });
}
/**
 * Spend a sign-in link, returning its customer.
 *
 * The claim is a single conditional update, so two clicks racing each other
 * cannot both succeed — a link that has been used is used.
 */
function consumeLoginToken(raw) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!raw)
            return null;
        const claimed = yield LoginToken_1.default.findOneAndUpdate({ tokenHash: hash(raw), usedAt: { $exists: false }, expiresAt: { $gt: new Date() } }, { $set: { usedAt: new Date() } }, { new: true });
        if (!claimed)
            return null;
        return Customer_1.default.findById(claimed.customerId);
    });
}
/** Start a session. Returns the raw cookie value, which is never stored. */
function createSession(customer) {
    return __awaiter(this, void 0, void 0, function* () {
        const raw = secret();
        yield Session_1.default.create({
            tokenHash: hash(raw),
            customerId: customer._id,
            expiresAt: new Date(Date.now() + SESSION_TTL_MS),
        });
        return raw;
    });
}
const sessionCookieOptions = () => ({
    httpOnly: true,
    sameSite: 'lax',
    // The proxy makes this first-party, so Lax is enough; Secure everywhere but
    // local development, where there is no TLS.
    secure: process.env.NODE_ENV !== 'development',
    maxAge: SESSION_TTL_MS,
    path: '/',
});
exports.sessionCookieOptions = sessionCookieOptions;
/** Read one cookie without pulling in a parser dependency. */
function readCookie(req, name) {
    var _a;
    const header = (_a = req.headers) === null || _a === void 0 ? void 0 : _a.cookie;
    if (typeof header !== 'string')
        return null;
    for (const part of header.split(';')) {
        const index = part.indexOf('=');
        if (index === -1)
            continue;
        if (part.slice(0, index).trim() === name) {
            return decodeURIComponent(part.slice(index + 1).trim());
        }
    }
    return null;
}
/**
 * Who is making this request, or null. Compares the stored hash in constant
 * time, since a lookup by hash is an equality test on a secret-derived value.
 */
function customerFromRequest(req) {
    return __awaiter(this, void 0, void 0, function* () {
        const raw = readCookie(req, exports.SESSION_COOKIE);
        if (!raw)
            return null;
        const candidate = hash(raw);
        const session = yield Session_1.default.findOne({ tokenHash: candidate });
        if (!session || session.revokedAt || session.expiresAt <= new Date())
            return null;
        const a = Buffer.from(session.tokenHash);
        const b = Buffer.from(candidate);
        if (a.length !== b.length || !(0, crypto_1.timingSafeEqual)(a, b))
            return null;
        return Customer_1.default.findById(session.customerId);
    });
}
/** End a session server-side, so the cookie is inert even if it is kept. */
function revokeSession(raw) {
    return __awaiter(this, void 0, void 0, function* () {
        if (!raw)
            return;
        yield Session_1.default.updateOne({ tokenHash: hash(raw) }, { $set: { revokedAt: new Date() } });
    });
}
