//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:shiftboard_api/src/api_util.dart';
import 'package:shiftboard_api/src/model/hours_entry_page.dart';
import 'package:shiftboard_api/src/model/hours_request.dart';
import 'package:shiftboard_api/src/model/hours_status.dart';
import 'package:shiftboard_api/src/model/problem.dart';
import 'package:shiftboard_api/src/model/shift_assignment.dart';
import 'package:shiftboard_api/src/model/worker_shift.dart';

class HoursApi {
  final Dio _dio;

  final Serializers _serializers;

  const HoursApi(this._dio, this._serializers);

  /// Approve the hours a worker worked
  /// Saves start, end and break of a worker who held a confirmed spot on a shift that has started, and approves them for payroll. The hours can be saved again; the latest save counts. Dispatchers and admins only.  Field error codes: &#x60;required&#x60;, &#x60;before_start&#x60; (&#x60;endedAt&#x60; is not after &#x60;startedAt&#x60;), &#x60;too_long&#x60; (&#x60;endedAt&#x60; is more than 24 hours after &#x60;startedAt&#x60;, or &#x60;breakMinutes&#x60; is not shorter than the time between them), &#x60;out_of_range&#x60;.  Error codes: &#x60;validation_failed&#x60; (400, with &#x60;errors&#x60;), &#x60;forbidden&#x60; (403), &#x60;shift_not_found&#x60; (404), &#x60;assignment_not_found&#x60; (404), and with 409: &#x60;shift_not_started&#x60; and &#x60;assignment_not_worked&#x60; (the assignment is not confirmed or completed).
  ///
  /// Parameters:
  /// * [shiftId]
  /// * [assignmentId]
  /// * [hoursRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ShiftAssignment] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ShiftAssignment>> approveHours({
    required String shiftId,
    required String assignmentId,
    required HoursRequest hoursRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/shifts/{shiftId}/assignments/{assignmentId}/hours'
        .replaceAll(
            '{' r'shiftId' '}',
            encodeQueryParameter(_serializers, shiftId, const FullType(String))
                .toString())
        .replaceAll(
            '{' r'assignmentId' '}',
            encodeQueryParameter(
                    _serializers, assignmentId, const FullType(String))
                .toString());
    final _options = Options(
      method: r'PUT',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(HoursRequest);
      _bodyData = _serializers.serialize(hoursRequest, specifiedType: _type);
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _options.compose(
          _dio.options,
          _path,
        ),
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    final _response = await _dio.request<Object>(
      _path,
      data: _bodyData,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    ShiftAssignment? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(ShiftAssignment),
            ) as ShiftAssignment;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ShiftAssignment>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Check in on arrival
  /// Records the time the worker arrived. Possible once, with a confirmed spot, from &#x60;assignment.checkInFrom&#x60; until the shift&#39;s end, when the agency uses check-in. No location is stored. Active workers only.  Error codes: &#x60;forbidden&#x60; (403), &#x60;worker_not_active&#x60; (403), &#x60;shift_not_found&#x60; (404), &#x60;assignment_not_found&#x60; (404, the worker has not claimed the shift), and with 409: &#x60;check_in_disabled&#x60; (the agency does not use check-in), &#x60;assignment_not_confirmed&#x60;, &#x60;check_in_not_open&#x60; (too early or after the end) and &#x60;already_checked_in&#x60;.
  ///
  /// Parameters:
  /// * [shiftId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [WorkerShift] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<WorkerShift>> checkIn({
    required String shiftId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/worker/shifts/{shiftId}/check-in'.replaceAll(
        '{' r'shiftId' '}',
        encodeQueryParameter(_serializers, shiftId, const FullType(String))
            .toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    WorkerShift? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(WorkerShift),
            ) as WorkerShift;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<WorkerShift>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// Check out when leaving
  /// Records the time the worker left. Possible once after checking in, also after the planned end, until the agency approved the hours. Active workers only.  Error codes: &#x60;forbidden&#x60; (403), &#x60;worker_not_active&#x60; (403), &#x60;shift_not_found&#x60; (404), &#x60;assignment_not_found&#x60; (404), and with 409: &#x60;check_in_disabled&#x60;, &#x60;assignment_not_confirmed&#x60; (the worker no longer holds the spot), &#x60;not_checked_in&#x60;, &#x60;already_checked_out&#x60; and &#x60;hours_approved&#x60;.
  ///
  /// Parameters:
  /// * [shiftId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [WorkerShift] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<WorkerShift>> checkOut({
    required String shiftId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/worker/shifts/{shiftId}/check-out'.replaceAll(
        '{' r'shiftId' '}',
        encodeQueryParameter(_serializers, shiftId, const FullType(String))
            .toString());
    final _options = Options(
      method: r'POST',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    WorkerShift? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(WorkerShift),
            ) as WorkerShift;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<WorkerShift>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }

  /// List the hours of a period
  /// One entry per worker who held a confirmed spot on a shift that has started, for shifts starting in &#x60;[from, to)&#x60;, sorted by shift start, earliest first. An entry is &#x60;OPEN&#x60; until the agency approved its hours. Feeds the payroll export, which the dashboard builds. Dispatchers and admins only.  Error codes: &#x60;validation_failed&#x60; (400, &#x60;to&#x60; is not after &#x60;from&#x60;), &#x60;forbidden&#x60; (403).
  ///
  /// Parameters:
  /// * [from] - Shifts starting at or after this time.
  /// * [to] - Shifts starting before this time.
  /// * [status] - Only entries with this status.
  /// * [page] - Page number, starting at 0.
  /// * [size] - Page size.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [HoursEntryPage] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<HoursEntryPage>> listHours({
    required DateTime from,
    required DateTime to,
    HoursStatus? status,
    int? page = 0,
    int? size = 20,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/hours';
    final _options = Options(
      method: r'GET',
      headers: <String, dynamic>{
        ...?headers,
      },
      extra: <String, dynamic>{
        'secure': <Map<String, String>>[
          {
            'type': 'http',
            'scheme': 'bearer',
            'name': 'bearerAuth',
          },
        ],
        ...?extra,
      },
      validateStatus: validateStatus,
    );

    final _queryParameters = <String, dynamic>{
      r'from':
          encodeQueryParameter(_serializers, from, const FullType(DateTime)),
      r'to': encodeQueryParameter(_serializers, to, const FullType(DateTime)),
      if (status != null)
        r'status': encodeQueryParameter(
            _serializers, status, const FullType(HoursStatus)),
      if (page != null)
        r'page': encodeQueryParameter(_serializers, page, const FullType(int)),
      if (size != null)
        r'size': encodeQueryParameter(_serializers, size, const FullType(int)),
    };

    final _response = await _dio.request<Object>(
      _path,
      options: _options,
      queryParameters: _queryParameters,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    HoursEntryPage? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(HoursEntryPage),
            ) as HoursEntryPage;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<HoursEntryPage>(
      data: _responseData,
      headers: _response.headers,
      isRedirect: _response.isRedirect,
      requestOptions: _response.requestOptions,
      redirects: _response.redirects,
      statusCode: _response.statusCode,
      statusMessage: _response.statusMessage,
      extra: _response.extra,
    );
  }
}
