import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/enums.dart';
import '../models/donor_model.dart';
import '../models/blood_request_model.dart';

/// Remote data source for donor operations
abstract class DonorRemoteDataSource {
  Future<DonorModel> createProfile({
    required String userId,
    required String fullName,
    required int age,
    required String gender,
    required String bloodGroup,
    required String mobile,
    required String governate,
    required String city,
  });

  Future<DonorModel> getProfile(String donorId);

  Future<DonorModel> updateProfile(DonorModel donor);

  Future<List<BloodRequestModel>> getAvailableRequests({
    required String bloodGroup,
    required String governate,
  });

  Future<BloodRequestModel> acceptRequest({
    required String requestId,
    required String donorId,
  });

  Future<BloodRequestModel> getRequestDetails(String requestId);
}

@LazySingleton(as: DonorRemoteDataSource)
class DonorRemoteDataSourceImpl implements DonorRemoteDataSource {
  final SupabaseClient _supabase;

  DonorRemoteDataSourceImpl(this._supabase);

  @override
  Future<DonorModel> createProfile({
    required String userId,
    required String fullName,
    required int age,
    required String gender,
    required String bloodGroup,
    required String mobile,
    required String governate,
    required String city,
  }) async {
    try {
      // Insert with user_id (not id - id is auto-generated)
      // Note: database uses 'phone_number' but app uses 'mobile'
      final insertedData = await _supabase
          .from(ApiConstants.donorsTable)
          .insert({
            'user_id': userId,
            'full_name': fullName,
            'age': age,
            'gender': gender,
            'blood_group': bloodGroup,
            'phone_number': mobile,
            'mobile': mobile,
            'governate': governate,
            'city': city,
            'is_available': true,
          })
          .select()
          .single();

      return DonorModel.fromJson(insertedData);
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to create profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<DonorModel> getProfile(String donorId) async {
    try {
      // Search by user_id since donorId is the auth user id
      final data = await _supabase
          .from(ApiConstants.donorsTable)
          .select()
          .eq('user_id', donorId)
          .single();

      return DonorModel.fromJson(data);
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to get profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<DonorModel> updateProfile(DonorModel donor) async {
    try {
      await _supabase
          .from(ApiConstants.donorsTable)
          .update(donor.toJson())
          .eq('user_id', donor.id);

      final data = await _supabase
          .from(ApiConstants.donorsTable)
          .select()
          .eq('user_id', donor.id)
          .single();

      return DonorModel.fromJson(data);
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to update profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<BloodRequestModel>> getAvailableRequests({
    required String bloodGroup,
    required String governate,
  }) async {
    try {
      // Get all requests (pending and completed)
      // Show completed requests so donors can see the status
      final data = await _supabase
          .from(ApiConstants.requestsTable)
          .select('*, hospitals(name, governate, city)')
          .inFilter('status', [
            RequestStatus.pending.value,
            RequestStatus.completed.value,
          ])
          .order('created_at', ascending: false);

      return data.map((json) => BloodRequestModel.fromJson(json)).toList();
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to get requests: ${e.toString()}',
      );
    }
  }

  @override
  Future<BloodRequestModel> acceptRequest({
    required String requestId,
    required String donorId,
  }) async {
    try {
      // Update request
      await _supabase
          .from(ApiConstants.requestsTable)
          .update({
            'status': RequestStatus.accepted.value,
            'accepted_by': donorId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);

      // Update donor's last donation date
      await _supabase
          .from(ApiConstants.donorsTable)
          .update({'last_donation_date': DateTime.now().toIso8601String()})
          .eq('id', donorId);

      // Get updated request with joins
      final data = await _supabase
          .from(ApiConstants.requestsTable)
          .select(
            '*, hospitals(name, governate, city, user_id), donors(full_name)',
          )
          .eq('id', requestId)
          .single();

      final request = BloodRequestModel.fromJson(data);

      // Send notification to hospital about accepted request
      try {
        final donorName = data['donors']?['full_name'] ?? 'A donor';
        final hospitalUserId = data['hospitals']?['user_id'];

        if (hospitalUserId != null) {
          // Get hospital's FCM token
          final hospitalUser = await _supabase
              .from('users')
              .select('fcm_token')
              .eq('id', hospitalUserId)
              .maybeSingle();

          final fcmToken = hospitalUser?['fcm_token'];

          if (fcmToken != null) {
            await _supabase.functions.invoke(
              'send-notification',
              body: {
                'type': 'single',
                'fcm_token': fcmToken,
                'title': '🎉 Donation Request Accepted!',
                'body':
                    '$donorName has accepted to donate ${request.bloodGroup} blood for ${request.patientName}',
                'data': {
                  'type': 'request_accepted',
                  'request_id': requestId,
                  'donor_name': donorName,
                  'blood_group': request.bloodGroup,
                },
              },
            );
          }

          // Also save notification to database
          await _supabase.from('notifications').insert({
            'user_id': hospitalUserId,
            'title': '🎉 Donation Request Accepted!',
            'body':
                '$donorName has accepted to donate ${request.bloodGroup} blood for ${request.patientName}',
            'type': 'request_accepted',
            'data': {
              'request_id': requestId,
              'donor_name': donorName,
              'blood_group': request.bloodGroup,
            },
            'is_read': false,
          });
        }
      } catch (e) {
        // Silently handle notification failure - don't fail the accept operation
      }

      return request;
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to accept request: ${e.toString()}',
      );
    }
  }

  @override
  Future<BloodRequestModel> getRequestDetails(String requestId) async {
    try {
      final data = await _supabase
          .from(ApiConstants.requestsTable)
          .select(
            '*, hospitals(name, governate, city, address, mobile), donors(full_name, mobile)',
          )
          .eq('id', requestId)
          .single();

      return BloodRequestModel.fromJson(data);
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to get request details: ${e.toString()}',
      );
    }
  }
}
