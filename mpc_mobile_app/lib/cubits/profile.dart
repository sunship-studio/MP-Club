import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mpc_mobile_app/data/repositories/profile.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required this.profileRepository}) : super(ProfileInitial());
  ProfileRepository profileRepository;
  Future<void> updateProfilePicture(File image, String userId) async {
    emit(ProfileLoading());
    final result = await profileRepository.uploadProfilePicture(image, userId);
    if (result) {
      emit(ProfilePictureUpdated());
    } else {
      emit(ProfilePictureUpdateFailed());
    }
  }
}

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfilePictureUpdateFailed extends ProfileState {}

class ProfilePictureUpdated extends ProfileState {}
