import { Request, Response } from "express";
import {
  WaitingListEntry,
  WeeklyAvailability,
} from "../../models/WaitingListEntry";
import { sendNotificationToAdmin } from "../../services/notification";

export default class WaitingListController {
  // Add a new user to the waiting list
  public async addUserToWaitingList(req: Request, res: Response) {
    try {
      const { firstName, lastName, email, age, availableWeekdays } = req.body;

      const newEntry = new WaitingListEntry({
        firstName,
        lastName,
        email,
        age,
      });
      // Set weekly availability from the request body
      availableWeekdays.forEach((day: any) => {
        const dayName = day.name.toLowerCase() as keyof WeeklyAvailability;

        if (
          newEntry.weeklyAvailability &&
          dayName in newEntry.weeklyAvailability
        ) {
          newEntry.weeklyAvailability[dayName] = {
            available: true,
            startTime: day.startTime,
            allDay: day.allDay,
            endTime: day.endTime,
          };
        }
      });

      await newEntry.save();

      res
        .status(201)
        .json({ message: "User added to waiting list", entry: newEntry });
      sendNotificationToAdmin(
        `New user added to waiting list: ${firstName} ${lastName}`,
        "New Waiting List Entry"
      );
    } catch (error) {
      console.error("Error adding user to waiting list:", error);
      res
        .status(500)
        .json({ message: "Error adding user to waiting list", error });
    }
  }
}
