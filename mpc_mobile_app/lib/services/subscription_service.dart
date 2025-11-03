import 'dart:async';
import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  static const String subscriptionId = 'mpc_monthly_subscription_260';

  // Callback when purchase is completed successfully
  // Now returns receipt data for backend verification
  Function(PurchaseDetails, String receipt)? onPurchaseComplete;

  // Callback when purchase fails
  Function(String error)? onPurchaseError;

  /// Initialize the subscription service
  Future<void> initialize() async {
    // Listen to purchase updates
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) => onPurchaseError?.call(error.toString()),
    );
  }

  /// Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        // Purchase is pending (waiting for payment confirmation)
        print('⏳ Purchase pending: ${purchase.productID}');
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Purchase successful!
        print('✅ Purchase successful: ${purchase.productID}');

        // Get receipt data
        final receiptData = await _getReceiptData(purchase);

        if (receiptData != null && receiptData.isNotEmpty) {
          // Pass receipt to callback for backend verification
          onPurchaseComplete?.call(purchase, receiptData);
        } else {
          onPurchaseError?.call('No receipt data available');
        }

        // Mark purchase as delivered
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        // Purchase failed
        print('❌ Purchase error: ${purchase.error}');
        onPurchaseError?.call(purchase.error?.message ?? 'Purchase failed');

        // Complete the failed purchase
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.canceled) {
        print('🚫 Purchase canceled');
        onPurchaseError?.call('Purchase canceled');
      }
    }
  }

  /// Get receipt data from purchase
  Future<String?> _getReceiptData(PurchaseDetails purchase) async {
    try {
      String? receiptData;

      if (Platform.isIOS) {
        // iOS: Handle both StoreKit 1 and StoreKit 2
        if (purchase is AppStorePurchaseDetails) {
          // StoreKit 1
          receiptData = purchase.verificationData.serverVerificationData;
        } else {
          // StoreKit 2 (SK2PurchaseDetails) - use generic verification data
          receiptData = purchase.verificationData.serverVerificationData;
        }
      } else if (Platform.isAndroid) {
        // Android: Get Play Store token
        if (purchase is GooglePlayPurchaseDetails) {
          receiptData = purchase.verificationData.serverVerificationData;
        } else {
          receiptData = purchase.verificationData.serverVerificationData;
        }
      }

      if (receiptData != null && receiptData.isNotEmpty) {
        print('✅ Receipt data received: ${receiptData.substring(0, 50)}...');
        return receiptData;
      } else {
        print('❌ No receipt data available');
        return null;
      }
    } catch (e) {
      print('❌ Error getting receipt data: $e');
      return null;
    }
  }

  /// Verify purchase with your backend (DEPRECATED - moved to cubit)
  @Deprecated('Use onPurchaseComplete callback instead')
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    try {
      // Get the receipt/token
      String? receiptData;

      if (Platform.isIOS) {
        // iOS: Handle both StoreKit 1 and StoreKit 2
        if (purchase is AppStorePurchaseDetails) {
          // StoreKit 1
          receiptData = purchase.verificationData.serverVerificationData;
        } else {
          // StoreKit 2 (SK2PurchaseDetails) - use generic verification data
          receiptData = purchase.verificationData.serverVerificationData;
        }
      } else if (Platform.isAndroid) {
        // Android: Get Play Store token
        if (purchase is GooglePlayPurchaseDetails) {
          receiptData = purchase.verificationData.serverVerificationData;
        } else {
          receiptData = purchase.verificationData.serverVerificationData;
        }
      }

      if (receiptData == null || receiptData.isEmpty) {
        print('❌ No receipt data available');
        return false;
      }

      print('✅ Receipt data received: ${receiptData.substring(0, 50)}...');

      // TODO: Send receipt to your backend for verification
      // This is where your backend will:
      // 1. Verify the receipt with Apple/Google
      // 2. Create the user account if it doesn't exist
      // 3. Activate the subscription
      // 4. Return user credentials

      // Example API call:
      // final response = await dio.post('/api/verify-purchase', data: {
      //   'receipt': receiptData,
      //   'productId': purchase.productID,
      //   'platform': Platform.isIOS ? 'ios' : 'android',
      // });

      print('📤 Sending receipt to backend for verification...');

      // For now, return true (you'll implement the actual verification)
      return true;
    } catch (e) {
      print('❌ Error verifying purchase: $e');
      return false;
    }
  }

  /// Check if user has an active subscription
  Future<bool> hasActiveSubscription() async {
    try {
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        return false;
      }

      // Query past purchases
      await _inAppPurchase.restorePurchases();

      // Check for active subscription
      // This will trigger _onPurchaseUpdate with restored purchases

      // You should also check with your backend
      // to verify the subscription status

      return false; // Will be updated by restore callback
    } catch (e) {
      print('❌ Error checking subscription: $e');
      return false;
    }
  }

  /// Purchase the subscription
  Future<bool> purchaseSubscription() async {
    try {
      if (!Platform.isIOS && !Platform.isAndroid) {
        onPurchaseError?.call(
          'In-app purchases are only available on iOS and Android',
        );
        return false;
      }

      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        onPurchaseError?.call('Store is not available');
        return false;
      }

      // Query the product details
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails({subscriptionId});

      if (response.notFoundIDs.isNotEmpty) {
        onPurchaseError?.call('Subscription not found in store');
        return false;
      }

      if (response.productDetails.isEmpty) {
        onPurchaseError?.call('No subscription products available');
        return false;
      }

      // Get the product and initiate purchase
      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      // Purchase subscription (auto-renewable)
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      return success;
    } catch (e) {
      onPurchaseError?.call('Failed to initiate purchase: $e');
      return false;
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      onPurchaseError?.call('Failed to restore purchases: $e');
    }
  }

  /// Dispose the service
  void dispose() {
    _subscription.cancel();
  }
}
