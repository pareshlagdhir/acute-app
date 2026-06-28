import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_provider.dart';
import '../../data/doctor_api.dart';
import '../../data/doctor_repository_impl.dart';
import '../../domain/doctor_repository.dart';

final doctorApiProvider = Provider<DoctorApi>(
  (ref) => DoctorApi(ref.watch(dioProvider)),
);

final doctorRepositoryProvider = Provider<DoctorRepository>(
  (ref) => DoctorRepositoryImpl(ref.watch(doctorApiProvider)),
);
