import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/doctor_api.dart';
import '../../data/doctor_repository_impl.dart';
import '../../data/models/profile_models.dart';
import '../../domain/doctor_repository.dart';

final doctorApiProvider = Provider<DoctorApi>(
  (ref) => DoctorApi(ref.watch(dioProvider)),
);

final doctorRepositoryProvider = Provider<DoctorRepository>(
  (ref) => DoctorRepositoryImpl(ref.watch(doctorApiProvider)),
);

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, DoctorProfile>(
  ProfileController.new,
);

class ProfileController extends AsyncNotifier<DoctorProfile> {
  @override
  Future<DoctorProfile> build() => _load();

  Future<DoctorProfile> _load() async {
    final res = await ref.read(doctorRepositoryProvider).getMe();
    return res.fold((f) => throw Exception(f.message), (p) => p);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}
