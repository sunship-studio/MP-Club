import mongoose, { Schema } from 'mongoose';

export interface IUser extends Document {
  customerId: string;
  token?: string;
  refreshToken?: string;
  fcmToken?: string; // Firebase Cloud Messaging token for push notifications
  subscriptionId: string;
  status: string;
  type: string;
  profilePictureUrl?: string;
  caloriesPerDay?: number;
  targetWeight?: number;
  doneWorkouts: [
    {
      date: Date;

      workout: {
        name: string;
        exercises: [
          {
            bodyParts: [string];
            exerciseId: string;
            minutes: number;
            seconds: number;
            sets: [
              {
                reps: number;
                rir: number;
                weight: number;
              }
            ];
            name: string;
          }
        ];
      };
    }
  ];
  checkIns: [
    {
      date: Date;
      weight: number;
      imageUrl?: string | null;
      note?: string | null;
    }
  ];
  caloriesLogs: [
    {
      date: Date;
      calories: number;
      note?: string | null;
    }
  ];
  hasPassword?: boolean;
  lastLogin?: Date;
  password?: string;
  trainingPlan: {
    lastUpdated?: Date;
    name: string;
    days: [
      {
        name: string;
        exercises: [
          {
            bodyParts: [string];
            exerciseId: string;
            minutes: number;
            seconds: number;
            sets: [
              {
                reps: number;
                rir: number;
                weight: number;
              }
            ];
            name: string;
          }
        ];
      }
    ];
    bodyParts: [string];
  };
  startDate: Date;
  firstName: string;
  lastName: string;
  email: string;
  age: number;
  cancelToken?: string;
}

const UserSchema = new Schema<IUser>({
  profilePictureUrl: { type: String },
  customerId: { type: String, required: true },
  subscriptionId: { type: String, required: true },
  status: { type: String, required: true },
  startDate: { type: Date, default: Date.now },
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  email: { type: String, required: true },
  age: { type: Number, required: true },
  token: { type: String },
  targetWeight: { type: Number },
  refreshToken: { type: String },
  fcmToken: { type: String }, // Firebase Cloud Messaging token
  checkIns: [
    {
      id: { type: Schema.Types.ObjectId },
      date: { type: Date, required: true },
      weight: { type: Number, required: true },
      imageUrl: { type: String },
      note: { type: String },
    },
  ],
  caloriesLogs: [
    {
      date: { type: Date, required: true },
      calories: { type: Number, required: true },
      note: { type: String },
    },
  ],

  doneWorkouts: {
    type: [
      {
        date: { type: Date, required: true },
        workout: {
          name: { type: String, required: true },
          exercises: [
            {
              bodyParts: { type: [String], default: [] },
              exerciseId: { type: String, required: true },
              minutes: { type: Number, default: 0 },
              seconds: { type: Number, default: 0 },
              sets: [
                {
                  reps: { type: Number, required: true },
                  rir: { type: Number, required: true },

                  weight: { type: Number, required: true },
                },
              ],
              name: { type: String, required: true },
            },
          ],
        },
      },
    ],
    default: [],
  },
  type: { type: String, required: true },
  caloriesPerDay: { type: Number },
  lastLogin: { type: Date },
  password: { type: String },
  trainingPlan: {
    lastUpdated: { type: Date },
    name: {
      type: String,
      default: function () {
        return `Plan for ${this.firstName}`;
      },
    },
    days: [
      {
        lastUpdated: { type: Date },
        name: { type: String, required: true },
        exercises: [
          {
            bodyParts: { type: [String], default: [] },
            exerciseId: { type: String, required: true },
            minutes: { type: Number, default: 0 },
            seconds: { type: Number, default: 0 },
            sets: [
              {
                reps: { type: Number, required: true },
                rir: { type: Number, required: true },

                weight: { type: Number, required: true },
              },
            ],
            name: { type: String, required: true },
          },
        ],
      },
    ],
    bodyParts: { type: [String], default: [] },
  },
  hasPassword: { type: Boolean, default: false },

  cancelToken: { type: String },
  // Optional field for storing the cancel token
});

// Export the model and return your IUser interface
// @ts-ignore
const User = mongoose.model<IUser>('User', UserSchema);
export default User;
