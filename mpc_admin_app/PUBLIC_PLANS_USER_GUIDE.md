# Public Training Plans Feature - User Guide

## Overview

The Public Training Plans feature allows you to create, manage, and distribute workout plans that will be automatically available for purchase on your private website.

---

## Features

### ✅ Create New Plans

- Add plan name and description
- Select exercises from your existing exercise database
- Upload Excel files with detailed workout information
- Plans automatically sync to your private website for sale

### ✅ Edit Plans

- Update plan names and descriptions
- Add or remove exercises
- Replace or add Excel files
- Changes instantly reflect on the website

### ✅ Delete Plans

- Remove plans you no longer want to offer
- Confirmation dialog prevents accidental deletions
- Automatically removed from website

### ✅ Exercise Management

- Search through all your exercises
- Select multiple exercises per plan
- View selected exercises as chips
- Same exercise database as personal training plans

---

## How to Use

### Creating a New Plan

1. **Open Training Plans Screen**
   - From home screen, tap "TRAINING PLANS"

2. **Start Creating**
   - Tap the "+" icon in the top right corner

3. **Fill in Plan Details**
   - **Plan Name:** Enter a descriptive name (e.g., "Beginner Full Body")
   - **Description:** Add optional details about the plan
   - **Excel File:** Tap to upload an Excel file (optional but recommended)

4. **Select Exercises**
   - Use the search bar to find exercises
   - Tap checkboxes to select exercises
   - Selected exercises appear as blue chips above the list
   - Tap the X on a chip to remove an exercise

5. **Save Plan**
   - Tap "Create Plan" button
   - Plan is saved and uploaded to backend
   - Automatically appears on your website

### Editing a Plan

1. **Open Plan Card**
   - Tap the edit icon (pencil) on any plan card

2. **Make Changes**
   - Update name, description, or exercises
   - Upload a new Excel file if needed
   - Original file remains if you don't upload a new one

3. **Save Changes**
   - Tap "Save Changes" button
   - Updates sync to backend and website

### Deleting a Plan

1. **Confirm Deletion**
   - Tap the delete icon (trash) on any plan card
   - Confirm deletion in the dialog

2. **Plan Removed**
   - Plan removed from app and backend
   - Automatically removed from website

---

## Plan Card Information

Each plan card displays:

- **Plan Name** - The title of the plan
- **Description** - Brief overview (if provided)
- **Exercise Count** - Number of exercises included
- **Excel File Status** - Green indicator if file is attached
- **Exercise Preview** - First 5 exercises as blue chips
- **Edit Button** - Pencil icon to edit the plan
- **Delete Button** - Trash icon to delete the plan

---

## Excel File Guidelines

### Recommended Format

- **File Type:** .xlsx or .xls
- **Max Size:** 10MB
- **Content:** Detailed workout information, sets, reps, progression, etc.

### What to Include

- Week-by-week workout breakdown
- Exercise instructions
- Progressive overload guidelines
- Rest periods
- Tempo recommendations
- Deload weeks
- Any additional notes

### File Naming

- Use descriptive names
- Example: "beginner-full-body-12-weeks.xlsx"
- System will handle file storage and naming

---

## Exercise Selection

### Using the Search

1. Type exercise name in the search bar
2. Results filter in real-time
3. Clear search to see all exercises again

### Managing Selection

- **Add Exercise:** Check the checkbox
- **Remove Exercise:** Click X on chip or uncheck checkbox
- **View All Selected:** Scroll through chips above search bar

### Exercise Requirements

- At least 1 exercise required per plan
- No maximum limit
- Exercises must exist in your database
- Same exercises as used in personal training plans

---

## Integration with Private Website

### Automatic Syncing

- Plans automatically appear on website after creation
- Updates sync immediately
- Deletions remove from website instantly

### Customer Access

- Customers browse plans on your private website
- See plan name, description, and exercise list
- Purchase plan to download Excel file
- Excel files only accessible after purchase

### Payment Flow

- Customer purchases plan
- Payment processed on website
- Download link provided
- Excel file delivered securely

---

## Tips & Best Practices

### Creating Quality Plans

1. **Clear Naming:** Use descriptive, searchable names
2. **Detailed Descriptions:** Help customers understand what they're buying
3. **Complete Exercise List:** Include all exercises in the plan
4. **Comprehensive Excel Files:** Provide detailed workout information

### Managing Your Library

1. **Regular Updates:** Keep plans current with your training philosophy
2. **Seasonal Plans:** Create plans for different times of year
3. **Skill Levels:** Offer beginner, intermediate, and advanced options
4. **Specializations:** Create plans for specific goals (strength, hypertrophy, etc.)

### File Management

1. **Backup Files:** Keep local copies of Excel files
2. **Version Control:** Update file names when making revisions
3. **Quality Check:** Review Excel files before uploading
4. **Clear Formatting:** Make files easy to read and follow

---

## Troubleshooting

### "Failed to load plans"

- Check internet connection
- Pull down to refresh
- Try again in a few moments

### "Failed to upload Excel file"

- Check file size (must be under 10MB)
- Verify file type (.xlsx or .xls only)
- Check internet connection

### "Please select at least one exercise"

- Must choose at least 1 exercise
- Use search to find exercises
- Check that exercises are selected (chips visible)

### Plan not appearing on website

- Wait a few moments for sync
- Refresh website
- Contact backend team if issue persists

---

## Technical Details

### Data Storage

- Plans stored in backend database
- Excel files stored in cloud storage
- Exercises referenced from main exercise database

### Syncing

- Real-time updates to backend
- Pull-to-refresh to reload data
- Automatic error handling and retry

### Security

- Admin authentication required
- Secure file upload
- Protected API endpoints

---

## Next Steps

1. **Set Up Backend:** Share `PUBLIC_PLANS_BACKEND_GUIDE.md` with backend team
2. **Create First Plan:** Test the feature with a sample plan
3. **Add Multiple Plans:** Build your plan library
4. **Website Integration:** Ensure private website displays plans correctly
5. **Launch:** Start selling plans to customers!

---

## Support

For technical issues:

- Check backend integration guide
- Verify API endpoints are working
- Review error messages in console
- Contact backend development team

For feature requests:

- Document desired functionality
- Share with development team
- Prioritize with other app features
