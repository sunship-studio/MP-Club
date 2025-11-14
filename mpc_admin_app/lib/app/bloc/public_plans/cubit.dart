import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_admin_app/app/bloc/public_plans/state.dart';
import 'package:mpc_admin_app/app/models/PublicPlan.dart';
import 'package:mpc_admin_app/app/network/api.dart';

class PublicPlansCubit extends Cubit<PublicPlansState> {
  PublicPlansCubit() : super(PublicPlansInitial());

  Future<void> loadPlans() async {
    emit(PublicPlansLoading());

    final response = await apiService.get('/training-plans');
    print('Response data: ${response.data}');
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data as List<dynamic>;
      final plans = data.map((json) => PublicPlan.fromJson(json)).toList();
      emit(PublicPlansLoaded(plans: plans));
    } else {
      emit(PublicPlansError(message: 'Failed to load plans'));
    }
  }

  Future<void> createPlan(PublicPlan plan, String filePath) async {
    emit(PublicPlansLoading());
    try {
      final uploadUrl = await uploadExcelFile(filePath);
      if (uploadUrl == null) {
        emit(PublicPlansError(message: 'Failed to upload Excel file'));
        return;
      }
      plan.excelFileUrl = uploadUrl;
      print(uploadUrl);
      print(plan.toJson());
      final response = await apiService.post(
        '/add-training-plan',
        plan.toJson(),
      );
      print('Create plan response status: ${response.statusCode}');
      print('Create plan response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadPlans();
      } else {
        emit(PublicPlansError(message: 'Failed to create plan'));
      }
    } catch (e) {
      emit(PublicPlansError(message: e.toString()));
    }
  }

  Future<void> updatePlan(String planId, PublicPlan plan) async {
    emit(PublicPlansLoading());
    try {
      final response = await apiService.post('/edit-training-plan', {
        ...plan.toJson(),
        'id': planId,
      });

      if (response.statusCode == 200) {
        await loadPlans();
      } else {
        emit(PublicPlansError(message: 'Failed to update plan'));
      }
    } catch (e) {
      emit(PublicPlansError(message: e.toString()));
    }
  }

  Future<void> deletePlan(String planId) async {
    emit(PublicPlansLoading());
    try {
      final response = await apiService.post('/delete-training-plan', {
        'id': planId,
      });

      if (response.statusCode == 200) {
        await loadPlans();
      } else {
        emit(PublicPlansError(message: 'Failed to delete plan'));
      }
    } catch (e) {
      emit(PublicPlansError(message: e.toString()));
    }
  }

  Future<String?> uploadExcelFile(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await apiService.postFormData(
        endpoint: '/upload-training-plan-file',
        formData: formData,
      );

      if (response.statusCode == 200) {
        return response.data['url'] as String;
      }
      return null;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }
}
