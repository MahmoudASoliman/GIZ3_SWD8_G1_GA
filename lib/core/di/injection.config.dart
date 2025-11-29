// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../features/auth/data/datasources/auth_local_datasource.dart'
    as _i992;
import '../../features/auth/data/datasources/auth_remote_datasource.dart'
    as _i161;
import '../../features/auth/data/repositories/auth_repository_impl.dart'
    as _i153;
import '../../features/auth/domain/repositories/auth_repository.dart' as _i787;
import '../../features/auth/domain/usecases/get_current_user_usecase.dart'
    as _i17;
import '../../features/auth/domain/usecases/google_signin_usecase.dart'
    as _i653;
import '../../features/auth/domain/usecases/login_usecase.dart' as _i188;
import '../../features/auth/domain/usecases/logout_usecase.dart' as _i48;
import '../../features/auth/domain/usecases/signup_usecase.dart' as _i57;
import '../../features/auth/presentation/cubit/auth_cubit.dart' as _i117;
import '../../features/donation/data/datasources/donation_remote_datasource.dart'
    as _i312;
import '../../features/donation/data/repositories/donation_repository_impl.dart'
    as _i493;
import '../../features/donation/domain/repositories/donation_repository.dart'
    as _i664;
import '../../features/donation/presentation/cubit/donation_cubit.dart'
    as _i228;
import '../../features/donor/data/datasources/donor_remote_datasource.dart'
    as _i984;
import '../../features/donor/data/repositories/donor_repository_impl.dart'
    as _i231;
import '../../features/donor/domain/repositories/donor_repository.dart'
    as _i212;
import '../../features/donor/domain/usecases/accept_request_usecase.dart'
    as _i123;
import '../../features/donor/domain/usecases/create_profile_usecase.dart'
    as _i874;
import '../../features/donor/domain/usecases/get_profile_usecase.dart' as _i58;
import '../../features/donor/domain/usecases/get_request_details_usecase.dart'
    as _i214;
import '../../features/donor/domain/usecases/get_requests_usecase.dart' as _i19;
import '../../features/donor/domain/usecases/update_profile_usecase.dart'
    as _i589;
import '../../features/donor/presentation/cubit/donor_cubit.dart' as _i1018;
import '../../features/hospital/data/datasources/hospital_remote_datasource.dart'
    as _i131;
import '../../features/hospital/data/repositories/hospital_repository_impl.dart'
    as _i349;
import '../../features/hospital/domain/repositories/hospital_repository.dart'
    as _i21;
import '../../features/hospital/domain/usecases/create_blood_request_usecase.dart'
    as _i534;
import '../../features/hospital/domain/usecases/create_hospital_profile_usecase.dart'
    as _i906;
import '../../features/hospital/domain/usecases/delete_request_usecase.dart'
    as _i420;
import '../../features/hospital/domain/usecases/get_all_pending_requests_usecase.dart'
    as _i492;
import '../../features/hospital/domain/usecases/get_hospital_profile_usecase.dart'
    as _i17;
import '../../features/hospital/domain/usecases/get_hospital_requests_usecase.dart'
    as _i767;
import '../../features/hospital/domain/usecases/update_request_status_usecase.dart'
    as _i83;
import '../../features/hospital/presentation/cubit/hospital_cubit.dart' as _i55;
import '../../features/notifications/data/datasources/notifications_remote_datasource.dart'
    as _i937;
import '../../features/notifications/data/repositories/notifications_repository_impl.dart'
    as _i201;
import '../../features/notifications/domain/repositories/notifications_repository.dart'
    as _i563;
import '../../features/notifications/presentation/cubit/notifications_cubit.dart'
    as _i405;
import '../services/notification_service.dart' as _i941;
import 'injection.dart' as _i464;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i892.FirebaseMessaging>(
      () => registerModule.firebaseMessaging,
    );
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => registerModule.localNotifications,
    );
    gh.lazySingleton<_i131.HospitalRemoteDataSource>(
      () => _i131.HospitalRemoteDataSourceImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i161.AuthRemoteDataSource>(
      () => _i161.AuthRemoteDataSourceImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i992.AuthLocalDataSource>(
      () => _i992.AuthLocalDataSourceImpl(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i941.NotificationService>(
      () => _i941.NotificationService(
        gh<_i892.FirebaseMessaging>(),
        gh<_i163.FlutterLocalNotificationsPlugin>(),
      ),
    );
    gh.lazySingleton<_i937.NotificationsRemoteDataSource>(
      () => _i937.NotificationsRemoteDataSourceImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i984.DonorRemoteDataSource>(
      () => _i984.DonorRemoteDataSourceImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i21.HospitalRepository>(
      () => _i349.HospitalRepositoryImpl(gh<_i131.HospitalRemoteDataSource>()),
    );
    gh.factory<_i312.DonationRemoteDataSource>(
      () => _i312.DonationRemoteDataSourceImpl(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i534.CreateBloodRequestUseCase>(
      () => _i534.CreateBloodRequestUseCase(gh<_i21.HospitalRepository>()),
    );
    gh.lazySingleton<_i906.CreateHospitalProfileUseCase>(
      () => _i906.CreateHospitalProfileUseCase(gh<_i21.HospitalRepository>()),
    );
    gh.lazySingleton<_i420.DeleteRequestUseCase>(
      () => _i420.DeleteRequestUseCase(gh<_i21.HospitalRepository>()),
    );
    gh.lazySingleton<_i492.GetAllPendingRequestsUseCase>(
      () => _i492.GetAllPendingRequestsUseCase(gh<_i21.HospitalRepository>()),
    );
    gh.lazySingleton<_i17.GetHospitalProfileUseCase>(
      () => _i17.GetHospitalProfileUseCase(gh<_i21.HospitalRepository>()),
    );
    gh.lazySingleton<_i767.GetHospitalRequestsUseCase>(
      () => _i767.GetHospitalRequestsUseCase(gh<_i21.HospitalRepository>()),
    );
    gh.lazySingleton<_i83.UpdateRequestStatusUseCase>(
      () => _i83.UpdateRequestStatusUseCase(gh<_i21.HospitalRepository>()),
    );
    gh.lazySingleton<_i563.NotificationsRepository>(
      () => _i201.NotificationsRepositoryImpl(
        gh<_i937.NotificationsRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i787.AuthRepository>(
      () => _i153.AuthRepositoryImpl(
        remoteDataSource: gh<_i161.AuthRemoteDataSource>(),
        localDataSource: gh<_i992.AuthLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i17.GetCurrentUserUseCase>(
      () => _i17.GetCurrentUserUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i653.GoogleSignInUseCase>(
      () => _i653.GoogleSignInUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i188.LoginUseCase>(
      () => _i188.LoginUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i48.LogoutUseCase>(
      () => _i48.LogoutUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i57.SignUpUseCase>(
      () => _i57.SignUpUseCase(gh<_i787.AuthRepository>()),
    );
    gh.lazySingleton<_i212.DonorRepository>(
      () => _i231.DonorRepositoryImpl(gh<_i984.DonorRemoteDataSource>()),
    );
    gh.lazySingleton<_i123.AcceptRequestUseCase>(
      () => _i123.AcceptRequestUseCase(gh<_i212.DonorRepository>()),
    );
    gh.lazySingleton<_i874.CreateProfileUseCase>(
      () => _i874.CreateProfileUseCase(gh<_i212.DonorRepository>()),
    );
    gh.lazySingleton<_i58.GetProfileUseCase>(
      () => _i58.GetProfileUseCase(gh<_i212.DonorRepository>()),
    );
    gh.lazySingleton<_i214.GetRequestDetailsUseCase>(
      () => _i214.GetRequestDetailsUseCase(gh<_i212.DonorRepository>()),
    );
    gh.lazySingleton<_i19.GetRequestsUseCase>(
      () => _i19.GetRequestsUseCase(gh<_i212.DonorRepository>()),
    );
    gh.lazySingleton<_i589.UpdateProfileUseCase>(
      () => _i589.UpdateProfileUseCase(gh<_i212.DonorRepository>()),
    );
    gh.factory<_i117.AuthCubit>(
      () => _i117.AuthCubit(
        loginUseCase: gh<_i188.LoginUseCase>(),
        signUpUseCase: gh<_i57.SignUpUseCase>(),
        logoutUseCase: gh<_i48.LogoutUseCase>(),
        getCurrentUserUseCase: gh<_i17.GetCurrentUserUseCase>(),
        googleSignInUseCase: gh<_i653.GoogleSignInUseCase>(),
      ),
    );
    gh.factory<_i55.HospitalCubit>(
      () => _i55.HospitalCubit(
        gh<_i906.CreateHospitalProfileUseCase>(),
        gh<_i17.GetHospitalProfileUseCase>(),
        gh<_i534.CreateBloodRequestUseCase>(),
        gh<_i767.GetHospitalRequestsUseCase>(),
        gh<_i492.GetAllPendingRequestsUseCase>(),
        gh<_i83.UpdateRequestStatusUseCase>(),
        gh<_i420.DeleteRequestUseCase>(),
        gh<_i21.HospitalRepository>(),
      ),
    );
    gh.factory<_i405.NotificationsCubit>(
      () => _i405.NotificationsCubit(gh<_i563.NotificationsRepository>()),
    );
    gh.factory<_i1018.DonorCubit>(
      () => _i1018.DonorCubit(
        gh<_i874.CreateProfileUseCase>(),
        gh<_i58.GetProfileUseCase>(),
        gh<_i589.UpdateProfileUseCase>(),
        gh<_i19.GetRequestsUseCase>(),
        gh<_i123.AcceptRequestUseCase>(),
        gh<_i214.GetRequestDetailsUseCase>(),
      ),
    );
    gh.factory<_i664.DonationRepository>(
      () => _i493.DonationRepositoryImpl(gh<_i312.DonationRemoteDataSource>()),
    );
    gh.factory<_i228.DonationCubit>(
      () => _i228.DonationCubit(gh<_i664.DonationRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i464.RegisterModule {}
