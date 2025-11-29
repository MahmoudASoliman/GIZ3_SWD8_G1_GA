import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart' as app_exceptions;
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/enums.dart';
import '../models/hospital_model.dart';
import '../models/hospital_request_model.dart';

/// Remote data source for hospital operations
abstract class HospitalRemoteDataSource {
  Future<HospitalModel> createProfile({
    required String userId,
    required String name,
    required String governate,
    required String city,
    required String address,
    required String mobile,
  });

  Future<HospitalModel> getProfile(String hospitalId);

  Future<HospitalModel> updateProfile(HospitalModel hospital);

  Future<HospitalRequestModel> createRequest({
    required String hospitalId,
    required String hospitalName,
    required String patientName,
    required String bloodGroup,
    required String roomNumber,
    required String companionMobile,
    required String governate,
    required String city,
  });

  Future<List<HospitalRequestModel>> getRequests(String hospitalId);

  /// Get all pending requests in the same governate (for donation)
  Future<List<HospitalRequestModel>> getAllPendingRequests(String governate);

  Future<HospitalRequestModel> updateRequestStatus({
    required String requestId,
    required RequestStatus status,
  });

  Future<void> deleteRequest(String requestId);

  Future<HospitalRequestModel> getRequestDetails(String requestId);
}

@LazySingleton(as: HospitalRemoteDataSource)
class HospitalRemoteDataSourceImpl implements HospitalRemoteDataSource {
  final SupabaseClient _supabase;

  HospitalRemoteDataSourceImpl(this._supabase);

  @override
  Future<HospitalModel> createProfile({
    required String userId,
    required String name,
    required String governate,
    required String city,
    required String address,
    required String mobile,
  }) async {
    try {
      // Insert with user_id (not id - id is auto-generated)
      // Note: database uses 'phone_number' but app uses 'mobile'
      final insertedData = await _supabase
          .from(ApiConstants.hospitalsTable)
          .insert({
            'user_id': userId,
            'name': name,
            'governate': governate,
            'city': city,
            'address': address,
            'phone_number': mobile,
            'mobile': mobile,
          })
          .select()
          .single();

      return HospitalModel.fromJson(insertedData);
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to create hospital profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<HospitalModel> getProfile(String hospitalId) async {
    try {
      // Search by user_id since hospitalId is the auth user id
      final data = await _supabase
          .from(ApiConstants.hospitalsTable)
          .select()
          .eq('user_id', hospitalId)
          .maybeSingle();

      if (data == null) {
        throw app_exceptions.ServerException(
          'Hospital profile not found. Please complete your profile setup first.',
        );
      }

      return HospitalModel.fromJson(data);
    } catch (e) {
      if (e is app_exceptions.ServerException) rethrow;
      throw app_exceptions.ServerException(
        'Failed to get hospital profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<HospitalModel> updateProfile(HospitalModel hospital) async {
    try {
      await _supabase
          .from(ApiConstants.hospitalsTable)
          .update(hospital.toJson())
          .eq('id', hospital.id);

      final data = await _supabase
          .from(ApiConstants.hospitalsTable)
          .select()
          .eq('id', hospital.id)
          .single();

      return HospitalModel.fromJson(data);
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to update hospital profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<HospitalRequestModel> createRequest({
    required String hospitalId,
    required String hospitalName,
    required String patientName,
    required String bloodGroup,
    required String roomNumber,
    required String companionMobile,
    required String governate,
    required String city,
  }) async {
    try {
      final data = await _supabase
          .from(ApiConstants.requestsTable)
          .insert({
            'hospital_id': hospitalId,
            'hospital_name': hospitalName,
            'patient_name': patientName,
            'blood_group': bloodGroup,
            'room_number': roomNumber,
            'companion_mobile': companionMobile,
            'governate': governate,
            'city': city,
            'status': RequestStatus.pending.value,
          })
          .select()
          .single();

      final request = HospitalRequestModel.fromJson(data);

      // Send notification to matching donors via Edge Function
      try {
        await _supabase.functions.invoke(
          'send-notification',
          body: {
            'type': 'blood_request',
            'blood_group': bloodGroup,
            'hospital_name': hospitalName,
            'governate': governate,
            'city': city,
            'patient_name': patientName,
            'urgency_level': 'high',
            'request_id': request.id,
          },
        );
      } catch (e) {
        // Silently handle notification failure - don't fail the request creation
      }

      return request;
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to create blood request: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<HospitalRequestModel>> getRequests(String hospitalId) async {
    try {
      final data = await _supabase
          .from(ApiConstants.requestsTable)
          .select('*, donors(full_name, mobile)')
          .eq('hospital_id', hospitalId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((json) => HospitalRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to get blood requests: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<HospitalRequestModel>> getAllPendingRequests(
    String governate,
  ) async {
    try {
      // Get ALL pending requests (removed governate filter to show all requests)
      final data = await _supabase
          .from(ApiConstants.requestsTable)
          .select('*, donors(full_name, mobile), hospitals(name, address)')
          .eq('status', RequestStatus.pending.value)
          .order('created_at', ascending: false);

      return (data as List)
          .map((json) => HospitalRequestModel.fromJson(json))
          .toList();
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to get pending requests: ${e.toString()}',
      );
    }
  }

  @override
  Future<HospitalRequestModel> updateRequestStatus({
    required String requestId,
    required RequestStatus status,
  }) async {
    try {
      await _supabase
          .from(ApiConstants.requestsTable)
          .update({
            'status': status.value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);

      final data = await _supabase
          .from(ApiConstants.requestsTable)
          .select('*, donors(full_name, mobile)')
          .eq('id', requestId)
          .single();

      return HospitalRequestModel.fromJson(data);
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to update request status: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    try {
      await _supabase
          .from(ApiConstants.requestsTable)
          .delete()
          .eq('id', requestId);
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to delete request: ${e.toString()}',
      );
    }
  }

  @override
  Future<HospitalRequestModel> getRequestDetails(String requestId) async {
    try {
      // First, check if request exists at all
      final checkData = await _supabase
          .from(ApiConstants.requestsTable)
          .select('id, patient_name, blood_group, status')
          .eq('id', requestId);
      
      if (checkData.isEmpty) {
        throw app_exceptions.ServerException(
          'Request not found with ID: $requestId',
        );
      }
      
      final data = await _supabase
          .from(ApiConstants.requestsTable)
          .select('*, hospitals(name, governate, city, address, mobile)')
          .eq('id', requestId)
          .single();

      return HospitalRequestModel.fromJson(data);
    } catch (e) {
      throw app_exceptions.ServerException(
        'Failed to get request details: ${e.toString()}',
      );
    }
  }
}
