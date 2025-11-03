# Apple Subscription Account Creation

This document describes the new Apple subscription account creation functionality added to the MPC backend.

## Overview

The new endpoint allows users to create accounts using their Apple App Store subscription receipts. This enables seamless onboarding for users who subscribe through the iOS app.

## Endpoint

### POST `/mobile-app/auth/create-account-apple-subscription`

Creates a new user account after verifying an Apple subscription receipt.

#### Request Body

```json
{
  "email": "user@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "age": 25,
  "targetWeight": 70, // optional
  "appleReceiptData": "base64_encoded_receipt_data",
  "subscriptionId": "com.mpc.subscription.premium"
}
```

#### Response

**Success (201):**

```json
{
  "message": "Account created successfully with Apple subscription",
  "user": {
    "_id": "...",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "age": 25,
    "customerId": "apple_1699123456789",
    "subscriptionId": "com.mpc.subscription.premium",
    "status": "active",
    "type": "apple_subscription",
    "hasPassword": false,
    "startDate": "2024-11-02T..."
  }
}
```

**Headers:**

- `authorization`: JWT access token
- `x-refresh-token`: JWT refresh token

**Error (400):**

```json
{
  "message": "User with this email already exists"
}
```

```json
{
  "message": "Invalid Apple subscription"
}
```

**Error (500):**

```json
{
  "message": "Internal server error"
}
```

## Apple Receipt Verification

The system verifies Apple App Store receipts using Apple's verification servers:

- **Production**: `https://buy.itunes.apple.com/verifyReceipt`
- **Sandbox**: `https://sandbox.itunes.apple.com/verifyReceipt`

### Environment Variables Required

Add these to your `.env` file:

```env
APPLE_SHARED_SECRET=your_apple_shared_secret_from_app_store_connect
```

### Receipt Validation Process

1. The receipt data is sent to Apple's verification servers
2. The system handles sandbox/production environment switching automatically
3. Active subscriptions are validated against the provided subscription ID
4. Only receipts with active, non-expired subscriptions are accepted

## Integration Notes

### iOS App Integration

In your iOS app, after a successful subscription purchase:

1. Get the receipt data:

```swift
if let receiptURL = Bundle.main.appStoreReceiptURL,
   let receiptData = try? Data(contentsOf: receiptURL) {
    let receiptString = receiptData.base64EncodedString()
    // Send receiptString to your backend
}
```

2. Call the account creation endpoint with the receipt data and user information.

### User Flow

1. User subscribes in the iOS app
2. iOS app collects user details (email, name, age, etc.)
3. iOS app gets receipt data from App Store
4. iOS app calls the account creation endpoint
5. Backend verifies the receipt with Apple
6. If valid, account is created and user is logged in
7. User can now access the app with their new account

### Error Handling

The system handles various Apple receipt validation errors:

- **21000**: Invalid JSON
- **21002**: Malformed receipt data
- **21003**: Receipt authentication failed
- **21004**: Shared secret mismatch
- **21005**: Receipt server unavailable
- **21006**: Valid receipt but subscription expired
- **21007**: Sandbox receipt (auto-handled)
- **21008**: Production receipt

## Security Considerations

1. **Receipt Validation**: All receipts are validated server-side with Apple
2. **Duplicate Prevention**: Checks for existing users with the same email
3. **Subscription Verification**: Ensures the subscription is active and matches the provided ID
4. **Token Security**: JWT tokens are generated with appropriate expiration times
5. **Environment Handling**: Automatic sandbox/production switching for receipt validation

## Testing

### Test Data

For testing in sandbox environment, use Apple's sandbox test accounts and ensure your app is configured for sandbox testing.

### Manual Testing

1. Set up a sandbox test account in App Store Connect
2. Use the sandbox environment in your iOS app
3. Make a test subscription purchase
4. Extract the receipt data
5. Call the endpoint with test data

## Troubleshooting

### Common Issues

1. **Invalid Receipt**: Ensure receipt data is properly base64 encoded
2. **Shared Secret**: Verify the Apple shared secret is correctly set
3. **Subscription ID**: Ensure the subscription ID matches your App Store Connect configuration
4. **Environment**: Check that you're using the correct environment (sandbox vs production)

### Logging

The system logs detailed information about receipt verification failures. Check server logs for specific error details.
