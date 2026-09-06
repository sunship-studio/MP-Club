import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/class%20passes/state.dart';
import 'package:mpc_admin_app/app/models/class_pass.dart';
import 'package:mpc_admin_app/app/network/api.dart';

class ClassPassesCubit extends Cubit<ClassPassesState> {
  ClassPassesCubit() : super(ClassPassesInitial());

  List<ClassPassProduct> _products = [];

  Future<void> loadPasses({String search = '', String? notice}) async {
    emit(ClassPassesLoading());
    try {
      if (_products.isEmpty) {
        final productsResponse = await apiService.get('/class-pass-products');
        _products = (productsResponse.data as List<dynamic>)
            .map((json) => ClassPassProduct.fromJson(json))
            .toList();
      }

      final query = search.isEmpty ? '' : '?search=${Uri.encodeQueryComponent(search)}';
      final response = await apiService.get('/class-passes$query');

      final passes = (response.data as List<dynamic>)
          .map((json) => ClassPass.fromJson(json))
          .toList();

      emit(ClassPassesLoaded(
        passes: passes,
        products: _products,
        search: search,
        notice: notice,
      ));
    } catch (e) {
      emit(ClassPassesError(message: e.toString()));
    }
  }

  /// Grant a pass by hand — the Stripe-took-the-money-but-the-webhook-didn't
  /// -land fix. Reports back when the pass was created but the email failed,
  /// because the holder then has no link until it is resent.
  Future<void> grantPass({
    required String productId,
    required String email,
    required String firstName,
    String? lastName,
  }) async {
    final search = _currentSearch();
    try {
      final response = await apiService.post('/class-passes', {
        'productId': productId,
        'email': email,
        'firstName': firstName,
        'lastName': lastName ?? '',
      });

      final emailSent = response.data is Map && response.data['emailSent'] == true;
      await loadPasses(
        search: search,
        notice: emailSent
            ? 'Pass granted. The link has been emailed to $email.'
            : 'Pass granted, but the email did not send. Use "Resend link".',
      );
    } catch (e) {
      emit(ClassPassesError(message: _clean(e)));
    }
  }

  /// Revoke blocks new bookings and leaves existing ones standing. Reversible:
  /// a misclick is fixed by un-revoking, not by rebuilding a calendar.
  Future<void> setRevoked(ClassPass pass, bool revoked) async {
    final search = _currentSearch();
    try {
      await apiService.patch('/class-passes/${pass.id}/revoked', {'revoked': revoked});
      await loadPasses(
        search: search,
        notice: revoked
            ? '${pass.fullName}\'s pass is revoked. Classes already booked still stand.'
            : '${pass.fullName}\'s pass is active again.',
      );
    } catch (e) {
      emit(ClassPassesError(message: _clean(e)));
    }
  }

  Future<void> resendLink(ClassPass pass) async {
    final search = _currentSearch();
    try {
      await apiService.post('/class-passes/${pass.id}/resend', {});
      await loadPasses(search: search, notice: 'Link resent to ${pass.email}.');
    } catch (e) {
      emit(ClassPassesError(message: _clean(e)));
    }
  }

  String _currentSearch() {
    final current = state;
    return current is ClassPassesLoaded ? current.search : '';
  }

  String _clean(Object error) => error.toString().replaceFirst('Exception: ', '');
}
