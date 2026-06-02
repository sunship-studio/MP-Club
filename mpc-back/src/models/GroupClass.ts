import mongoose, { Document, Schema } from 'mongoose';

export interface IGroupClass extends Document {
  title: string;
  durationMinutes: number;
  timeSlots: [
    {
      time: string;
      spots: [
        {
          firstName: string;
          lastName: string;
          email: string;
          bookedAt: Date;
          occurrenceDate?: string; // "YYYY-MM-DD" of the booked week's occurrence
          status?: 'pending' | 'confirmed';
          holdId?: string; // ties a pending reservation to its Stripe session
          holdExpiresAt?: Date; // pending holds stop counting after this
        },
      ];
    },
  ]; // 9:00 AM, 10:00 AM, etc.
  date?: Date; // Date of the class
  recurring?: boolean; // Indicates if the class is recurring
  dayOfWeek?: string; // e.g., "Monday", "Tuesday" for recurring classes
  spotsAvailable: number;
}

const GroupClassSchema: Schema = new Schema<IGroupClass>({
  title: { type: String, required: true },
  durationMinutes: { type: Number, required: true },
  timeSlots: {
    type: [
      {
        time: { type: String, required: true },
        spots: [
          {
            id: { type: Schema.Types.ObjectId },
            email: { type: String, required: true },
            bookedAt: { type: Date, default: Date.now },
            firstName: { type: String, required: true },
            lastName: { type: String, required: false },
            occurrenceDate: { type: String, required: false },
            status: {
              type: String,
              enum: ['pending', 'confirmed'],
              default: 'confirmed',
            },
            holdId: { type: String, required: false },
            holdExpiresAt: { type: Date, required: false },
          },
        ],
      },
    ],
    required: true,
  },
  date: { type: Date, required: false, index: true },
  spotsAvailable: { type: Number, required: true },
  recurring: { type: Boolean, default: false },
  dayOfWeek: { type: String, required: false },
});

const GroupClass = mongoose.model<IGroupClass>('GroupClass', GroupClassSchema);

export default GroupClass;
