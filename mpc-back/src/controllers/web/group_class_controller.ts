import { Request, Response } from 'express';
import GroupClass from '../../models/GroupClass';
export default class GroupClassController {
  public async getGroupClasses(req: Request, res: Response): Promise<void> {
    try {
      const groupClasses = await GroupClass.find();
      res.status(200).json(groupClasses);
    } catch (error) {
      console.error('Error fetching group classes:', error);
      res.status(500).json({ error: 'Failed to fetch group classes' });
    }
  }
}
