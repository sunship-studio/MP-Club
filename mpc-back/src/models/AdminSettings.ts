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
 ``
const AdminSettings = mongoose.model('AdminSettings', AdminSettingsSchema);

export default AdminSettings;