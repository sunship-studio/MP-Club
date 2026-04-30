import moongose, { Document, Schema } from "mongoose";

interface DayAvailability {
  available: boolean;
  allDay?: boolean;
  startTime?: string;
  endTime?: string;
}

const DayAvailabilitySchema = new Schema(
  {
    available: { type: Boolean, default: false },
    allDay: { type: Boolean, default: false },
    startTime: { type: String, default: "" },
    endTime: { type: String, default: "" },
  },
  { _id: false }
);

interface WeeklyAvailability {
  monday: DayAvailability;
  tuesday: DayAvailability;
  wednesday: DayAvailability;
  thursday: DayAvailability;
  friday: DayAvailability;
  saturday: DayAvailability;

  [key: string]: DayAvailability;
}

export interface IWaitingListEntry extends Document {
  firstName: string;
  lastName: string;
  email: string;
  dateApplied: Date;
  approvalStatus: "pending" | "approved" | "rejected";
  approvedDate?: Date;
  age: number;
  weeklyAvailability: WeeklyAvailability;
}

const WaitingListEntrySchema = new Schema<IWaitingListEntry>({
  firstName: { type: String, required: true },
  lastName: { type: String, required: true },
  email: { type: String, required: true, unique: false },
  dateApplied: { type: Date, default: Date.now },
  approvalStatus: {
    type: String,
    enum: ["pending", "approved", "rejected"],
    default: "pending",
  },
  approvedDate: { type: Date },
  age: { type: Number, required: true },
  weeklyAvailability: {
    monday: {
      type: DayAvailabilitySchema,
      required: true,
      default: { available: false },
    },
    tuesday: {
      type: DayAvailabilitySchema,
      required: true,
      default: { available: false },
    },
    wednesday: {
      type: DayAvailabilitySchema,
      required: true,
      default: { available: false },
    },
    thursday: {
      type: DayAvailabilitySchema,
      required: true,
      default: { available: false },
    },
    friday: {
      type: DayAvailabilitySchema,
      required: true,
      default: { available: false },
    },
    saturday: {
      type: DayAvailabilitySchema,
      required: true,
      default: { available: false },
    },
    sunday: {
      type: DayAvailabilitySchema,
      required: true,
      default: { available: false },
    },
  },
});

const WaitingListEntry = moongose.model<IWaitingListEntry>(
  "WaitingListEntry",
  WaitingListEntrySchema
);

export { WeeklyAvailability, DayAvailability, WaitingListEntry };
