import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mpc_mobile_app/cubits/auth.dart';
import 'package:mpc_mobile_app/services/subscription_service.dart';

// States
abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionActive extends SubscriptionState {
  final PurchaseDetails purchaseDetails;
  final String receipt;

  SubscriptionActive({required this.purchaseDetails, required this.receipt});
}

class SubscriptionInactive extends SubscriptionState {}

class SubscriptionError extends SubscriptionState {
  final String message;

  SubscriptionError(this.message);
}

class SubscriptionPurchasing extends SubscriptionState {}

// Cubit
class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionService _subscriptionService;
  final AuthCubit _authCubit;

  SubscriptionCubit(this._subscriptionService, this._authCubit)
    : super(SubscriptionInitial()) {
    _initialize();
  }

  void _initialize() {
    _subscriptionService.onPurchaseComplete = _onPurchaseComplete;
    _subscriptionService.onPurchaseError = _onPurchaseError;
    _subscriptionService.initialize();
  }

  /// Check if user has active subscription on app launch
  Future<void> checkSubscriptionStatus() async {
    emit(SubscriptionLoading());

    try {
      final hasSubscription =
          await _subscriptionService.hasActiveSubscription();

      if (hasSubscription) {
        // User has active subscription, can skip login
        // Note: Actual purchase details will come from restore callback
        emit(SubscriptionInactive()); // Will be updated by restore
      } else {
        emit(SubscriptionInactive());
      }
    } catch (e) {
      emit(SubscriptionError('Failed to check subscription: $e'));
    }
  }

  /// Purchase subscription
  Future<void> purchaseSubscription() async {
    emit(SubscriptionPurchasing());

    try {
      final success = await _subscriptionService.purchaseSubscription();

      if (!success) {
        emit(SubscriptionError('Failed to start purchase'));
      }
      // Wait for purchase callback
    } catch (e) {
      emit(SubscriptionError('Purchase failed: $e'));
    }
  }

  /// Restore previous purchases
  Future<void> restorePurchases() async {
    emit(SubscriptionLoading());

    try {
      await _subscriptionService.restorePurchases();
      // Wait for restore callback
    } catch (e) {
      emit(SubscriptionError('Failed to restore purchases: $e'));
    }
  }

  void _onPurchaseComplete(PurchaseDetails purchase, String receipt) async {
    // Emit state with receipt data for navigation to signup form
    print('✅ Purchase complete, receipt received');
    emit(SubscriptionActive(purchaseDetails: purchase, receipt: receipt));
  }

  void _onPurchaseError(String error) {
    emit(SubscriptionError(error));
  }

  @override
  Future<void> close() {
    _subscriptionService.dispose();
    return super.close();
  }
}
