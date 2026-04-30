"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
// MongoDB schema (if using Mongoose)
const mongoose = require('mongoose');
const AdminSettingsSchema = new mongoose.Schema({
    key: {
        type: String,
        required: true,
        unique: true
    },
    value: {
        type: mongoose.Schema.Types.Mixed,
        required: true
    }
});
``;
const AdminSettings = mongoose.model('AdminSettings', AdminSettingsSchema);
exports.default = AdminSettings;
