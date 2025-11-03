# In-App Subscription Integration

## Overview

The app now supports in-app purchases for €260/month subscriptions through Apple App Store and Google Play Store.

## Architecture

### 1. **SubscriptionService** (`lib/services/subscription_service.dart`)

- Singleton service that handles all IAP operations
- Listens to purchase stream from Apple/Google
- Manages purchase lifecycle (pending → purchased → verified → completed)
- Provides callbacks for purchase completion and errors

### 2. **SubscriptionCubit** (`lib/cubits/subscription.dart`)

- State management for subscription status
- States:
  - `SubscriptionInitial` - Initial state
  - `SubscriptionLoading` - Checking subscription status
  - `SubscriptionPurchasing` - Purchase in progress
  - `SubscriptionActive` - User has active subscription
  - `SubscriptionInactive` - No active subscription
  - `SubscriptionError` - Error occurred

### 3. **Integration in Main App** (`lib/main.dart`)

- `SubscriptionCubit` is provided globally via `MultiBlocProvider`
- Listens to subscription state changes
- When subscription becomes active with `userToken`, triggers auto-login

### 4. **Login Screen** (`lib/presentation/screens/login.dart`)

- "Purchase a Membership" button triggers subscription purchase
- Listens to subscription state for feedback
- Shows loading/success/error messages via SnackBar

## Flow

### Purchase Flow:

```
1. User taps "Purchase a Membership"
   ↓
2. SubscriptionCubit.purchaseSubscription() called
   ↓
3. SubscriptionService queries Apple/Google for product
   ↓
4. Native store UI appears (€260/month subscription)
   ↓
5. User completes purchase
   ↓
6. Purchase stream receives update
   ↓
7. SubscriptionService._verifyPurchase() called
   ↓
8. Receipt sent to backend for verification
   ↓
9. Backend:
   - Verifies receipt with Apple/Google
   - Creates user account (if doesn't exist)
   - Activates subscription
   - Returns user token/credentials
   ↓
10. SubscriptionCubit emits SubscriptionActive with userToken
    ↓
11. Main app detects active subscription
    ↓
12. AuthCubit.loadUser() called (auto-login)
    ↓
13. User is logged in and sees main app
```

### App Launch Flow (existing user with subscription):

```
1. App starts
   ↓
2. Both AuthCubit and SubscriptionCubit initialize
   ↓
3. SubscriptionCubit.checkSubscriptionStatus()
   ↓
4. Restores previous purchases
   ↓
5. If active subscription found → Skip login, load user
   ↓
6. User goes directly to main app
```

## Backend Requirements

### Webhook Endpoint: `/api/verify-purchase`

The backend needs to handle purchase verification:

**Request:**

```json
{
  "receipt": "base64_encoded_receipt_data",
  "productId": "mpc_monthly_subscription_260",
  "platform": "ios" | "android"
}
```

**Responsibilities:**

1. Verify receipt with Apple/Google servers
2. Extract user information (email from receipt metadata if available)
3. Create user account if doesn't exist
4. Activate subscription in database
5. Return user credentials

**Response:**

```json
{
  "success": true,
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "token": "jwt_access_token",
    "refreshToken": "jwt_refresh_token"
  }
}
```

## App Store Connect Setup

### 1. Create Subscription Group

- Go to App Store Connect → Your App → Subscriptions
- Create new subscription group: "MPC Membership"

### 2. Create Subscription Product

- **Product ID**: `mpc_monthly_subscription_260` (must match exactly)
- **Duration**: 1 month (auto-renewable)
- **Price**: €260/month
- **Localization**: Add display name and description
- **Review Information**: Fill out for Apple review

### 3. Server Notifications (Webhooks)

- Configure server notification URL in App Store Connect
- Apple will send webhooks for:
  - Initial purchase
  - Renewal
  - Cancellation
  - Refund
  - etc.

## Testing

### Sandbox Testing (iOS)

1. Create sandbox tester account in App Store Connect
2. Sign out of real Apple ID on device
3. Run app, attempt purchase
4. Sign in with sandbox tester account when prompted
5. Purchase completes without real charge

### Production

- Subscription must be approved by Apple before going live
- Can take 24-48 hours for review

## Next Steps

1. **Backend Implementation**:

   - Create `/api/verify-purchase` endpoint
   - Implement receipt verification
   - Handle account creation logic
   - Set up webhook listeners for subscription events

2. **Update SubscriptionService**:

   - Uncomment and implement `_verifyPurchase()` API call
   - Add proper error handling
   - Implement subscription status check with backend

3. **Add Restore Purchases**:

   - Add "Restore Purchases" button in login screen
   - Useful for users who reinstall app

4. **Handle Subscription Lifecycle**:
   - Monitor subscription expiration
   - Handle cancellations
   - Show renewal reminders

## Important Notes

- Product ID `mpc_monthly_subscription_260` must be created in both App Store Connect and Google Play Console
- Subscriptions are auto-renewable by default
- Apple takes 30% commission (15% after first year)
- Subscriptions can be managed by users in App Store settings
- Must provide privacy policy and terms of service URLs
