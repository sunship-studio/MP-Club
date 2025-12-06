import dotenv from 'dotenv';
import mongoose from 'mongoose';

dotenv.config();

const mongoURI = `mongodb+srv://${process.env.MONGO_USER}:${process.env.MONGO_PASSWORD}@midlands-perfomance-clu.vfwz0lh.mongodb.net/?retryWrites=true&w=majority&appName=midlands-perfomance-cluster`;

const connectToDatabase = async () => {
  console.log('Connecting to MongoDB...' + mongoURI);
  if (!process.env.MONGO_USER || !process.env.MONGO_PASSWORD) {
    console.error('MongoDB credentials are not set in environment variables.');
    return;
  }
  try {
    await mongoose.connect(mongoURI);
    console.log('Connected to MongoDB as ' + process.env.MONGO_USER);
  } catch (error) {
    console.error('Error connecting to MongoDB:', error);
  }
};

export default connectToDatabase;
