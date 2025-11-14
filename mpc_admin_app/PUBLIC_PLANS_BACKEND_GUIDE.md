# Public Training Plans - Backend Integration Guide

## Overview

This document outlines the backend API endpoints needed to support the public training plans feature in the admin app.

## Required API Endpoints

### 1. Get All Training Plans

**Endpoint:** `GET /admin-app/training-plans`

**Headers:**

```
token: shanempc113@
Content-Type: application/json
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "_id": "plan_id_123",
      "name": "Beginner Full Body",
      "description": "A comprehensive full body workout plan for beginners",
      "exercisesIncluded": ["Squat", "Bench Press", "Deadlift", "Pull-ups"],
      "excelFileUrl": "https://storage.example.com/plans/beginner-full-body.xlsx",
      "createdAt": "2025-11-13T10:00:00.000Z",
      "updatedAt": "2025-11-13T10:00:00.000Z"
    }
  ]
}
```

---

### 2. Add Training Plan (Create New)

**Endpoint:** `POST /admin-app/add-training-plan`

**Headers:**

```
token: shanempc113@
Content-Type: application/json
```

**Request Body:**

```json
{
  "name": "Beginner Full Body",
  "description": "A comprehensive full body workout plan for beginners",
  "exercisesIncluded": ["Squat", "Bench Press", "Deadlift", "Pull-ups"],
  "excelFileUrl": "https://storage.example.com/plans/beginner-full-body.xlsx"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "_id": "plan_id_123",
    "name": "Beginner Full Body",
    "description": "A comprehensive full body workout plan for beginners",
    "exercisesIncluded": ["Squat", "Bench Press", "Deadlift", "Pull-ups"],
    "excelFileUrl": "https://storage.example.com/plans/beginner-full-body.xlsx",
    "createdAt": "2025-11-13T10:00:00.000Z",
    "updatedAt": "2025-11-13T10:00:00.000Z"
  }
}
```

---

### 3. Edit Training Plan

**Endpoint:** `POST /admin-app/edit-training-plan`

**Headers:**

```
token: shanempc113@
Content-Type: application/json
```

**Request Body:**

```json
{
  "planId": "plan_id_123",
  "name": "Updated Plan Name",
  "description": "Updated description",
  "exercisesIncluded": ["Squat", "Bench Press", "Deadlift", "Pull-ups", "Rows"],
  "excelFileUrl": "https://storage.example.com/plans/updated-plan.xlsx"
}
```

**Response:**

```json
{
  "success": true,
  "data": {
    "_id": "plan_id_123",
    "name": "Updated Plan Name",
    "description": "Updated description",
    "exercisesIncluded": [
      "Squat",
      "Bench Press",
      "Deadlift",
      "Pull-ups",
      "Rows"
    ],
    "excelFileUrl": "https://storage.example.com/plans/updated-plan.xlsx",
    "createdAt": "2025-11-13T10:00:00.000Z",
    "updatedAt": "2025-11-13T12:00:00.000Z"
  }
}
```

---

### 4. Delete Training Plan

**Endpoint:** `POST /admin-app/delete-training-plan`

**Headers:**

```
token: shanempc113@
Content-Type: application/json
```

**Request Body:**

```json
{
  "planId": "plan_id_123"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Plan deleted successfully"
}
```

---

### 5. Upload Training Plan File

**Endpoint:** `POST /admin-app/upload-training-plan-file`

**Headers:**

```
token: shanempc113@
Content-Type: multipart/form-data
```

**Request Body:**

```
FormData with:
- file: [Excel file binary data]
```

**Response:**

```json
{
  "success": true,
  "data": {
    "url": "https://storage.example.com/plans/workout-plan-123.xlsx",
    "name": "workout-plan-123.xlsx",
    "size": 45678
  }
}
```

**Notes:**

- Accepted file types: `.xlsx`, `.xls`
- Max file size: 10MB
- Files should be stored in cloud storage (AWS S3, Cloudinary, etc.)
- Return publicly accessible URL

---

## Database Schema

### PublicPlan Collection

```javascript
{
  _id: ObjectId,
  name: String (required),
  description: String (optional),
  exercisesIncluded: [String] (required, array of exercise names),
  excelFileUrl: String (optional, URL to Excel file),
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes:**

- `_id` (primary key)
- `name` (for search/filter)
- `createdAt` (for sorting)

---

## Integration with Private Website

The Excel files uploaded through this system will be automatically available for sale on the private website. The website should:

1. **Fetch Plans:** Call the same `/admin-app/public-plans` endpoint to get all available plans
2. **Display Plans:** Show plan name, description, and exercise list to customers
3. **Purchase Flow:** When a customer purchases a plan, provide download link to the Excel file
4. **Access Control:** Implement authentication/payment verification before allowing Excel file downloads

---

## Error Handling

All endpoints should return appropriate HTTP status codes:

- `200` - Success
- `201` - Created (for new resources)
- `400` - Bad Request (invalid data)
- `401` - Unauthorized (invalid token)
- `404` - Not Found (plan doesn't exist)
- `500` - Internal Server Error

**Error Response Format:**

```json
{
  "success": false,
  "error": "Error message here"
}
```

---

## Security Considerations

1. **Authentication:** All endpoints require the admin token (`shanempc113@`)
2. **File Upload Validation:**
   - Verify file type (only Excel files)
   - Check file size limits
   - Scan for malware
   - Generate unique file names to prevent overwriting
3. **Input Validation:**
   - Sanitize plan names and descriptions
   - Validate exercise names exist in the database
   - Prevent XSS attacks
4. **Rate Limiting:** Implement rate limiting on file upload endpoints

---

## Testing Checklist

- [ ] Create a new plan without Excel file
- [ ] Create a new plan with Excel file
- [ ] Update plan name only
- [ ] Update plan with new Excel file
- [ ] Delete a plan
- [ ] Load all plans
- [ ] Handle invalid file types
- [ ] Handle oversized files
- [ ] Handle duplicate plan names
- [ ] Test with invalid token
- [ ] Test concurrent uploads

---

## Example Implementation (Node.js/Express)

```javascript
// Your existing backend implementation is correct!
// The routes you have match the Flutter app perfectly:

adminAppRouter.get(
  '/training-plans',
  adminAppAuth,
  async (req: Request, res: Response) => {
    console.log('Received request to get all training plans');
    await adminAppController.getTrainingPlans(req, res);
  }
);

adminAppRouter.post(
  '/add-training-plan',
  adminAppAuth,
  async (req: Request, res: Response) => {
    console.log('Received request to add training plan to sell:', req.body);
    await adminAppController.addTrainingPlanToSell(req, res);
  }
);

adminAppRouter.post(
  '/edit-training-plan',
  adminAppAuth,
  async (req: Request, res: Response) => {
    console.log('Received request to edit training plan:', req.body);
    await adminAppController.editTrainingPlan(req, res);
  }
);

adminAppRouter.post(
  '/delete-training-plan',
  adminAppAuth,
  async (req: Request, res: Response) => {
    console.log('Received request to delete training plan:', req.body);
    await adminAppController.deleteTrainingPlan(req, res);
  }
);

adminAppRouter.post(
  '/upload-training-plan-file',
  adminAppAuth,
  upload.single('file'),
  async (req: Request, res: Response) => {
    console.log('Received request to upload training plan file');
    await adminAppController.uploadTrainingPlanFile(req, res);
  }
);
```

---

## Frontend Usage

The admin app is already set up with all necessary UI components. Once the backend endpoints are implemented:

1. Launch the app
2. Navigate to "TRAINING PLANS" from the home screen
3. Use the "+" button to create new plans
4. Click edit icon to modify plans
5. Click delete icon to remove plans
6. Upload Excel files during plan creation/editing

All data will automatically sync with the backend and be available on the private website for purchase.
