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
const express_1 = __importDefault(require("express"));
const cloudinary_1 = require("../../config/cloudinary");
const profile_1 = require("../../controllers/mobile/profile");
const profileRouter = express_1.default.Router();
const profileController = new profile_1.ProfileController();
profileRouter.post('/upload-profile-picture', cloudinary_1.upload.single('file'), (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    yield profileController.uploadProfilePicture(req, res);
}));
;
exports.default = profileRouter;
