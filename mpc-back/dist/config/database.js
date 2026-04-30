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
const dotenv_1 = __importDefault(require("dotenv"));
const mongoose_1 = __importDefault(require("mongoose"));
dotenv_1.default.config();
const mongoURI = `mongodb+srv://${process.env.MONGO_USER}:${process.env.MONGO_PASSWORD}@midlands-perfomance-clu.vfwz0lh.mongodb.net/?retryWrites=true&w=majority&appName=midlands-perfomance-cluster`;
const connectToDatabase = () => __awaiter(void 0, void 0, void 0, function* () {
    console.log('Connecting to MongoDB...' + mongoURI);
    if (!process.env.MONGO_USER || !process.env.MONGO_PASSWORD) {
        console.error('MongoDB credentials are not set in environment variables.');
        return;
    }
    try {
        yield mongoose_1.default.connect(mongoURI);
        console.log('Connected to MongoDB as ' + process.env.MONGO_USER);
    }
    catch (error) {
        console.error('Error connecting to MongoDB:', error);
    }
});
exports.default = connectToDatabase;
