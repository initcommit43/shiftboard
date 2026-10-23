//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'dart:async';

import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:dio/dio.dart';

import 'package:shiftboard_api/src/api_util.dart';
import 'package:shiftboard_api/src/model/assignment_status.dart';
import 'package:shiftboard_api/src/model/problem.dart';
import 'package:shiftboard_api/src/model/remove_assignment_request.dart';
import 'package:shiftboard_api/src/model/shift_assignment.dart';
import 'package:shiftboard_api/src/model/shift_assignment_page.dart';

class AssignmentsApi {
  final Dio _dio;

  final Serializers _serializers;

  const AssignmentsApi(this._dio, this._serializers);

  /// Approve a claim
  /// Sets a pending assignment to &#x60;CONFIRMED&#x60;. Dispatchers and admins only.  Error codes: &#x60;forbidden&#x60; (403), &#x60;shift_not_found&#x60; (404), &#x60;assignment_not_found&#x60; (404), &#x60;assignment_not_pending&#x60; (409).
  ///
  /// Parameters:
  /// * [shiftId]
  /// * [assignmentId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ShiftAssignment] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ShiftAssignment>> approveAssignment({
    required String shiftId,
    required String assignmentId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/shifts/{shiftId}/assignments/{assignmentId}/approve'
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

  /// List the claims on a shift
  /// The assignments of the shift, sorted by claim time, oldest first. The waitlist is not part of it (&#x60;GET /shifts/{shiftId}/waitlist&#x60;). Dispatchers and admins only.  Error codes: &#x60;forbidden&#x60; (403), &#x60;shift_not_found&#x60; (404).
  ///
  /// Parameters:
  /// * [shiftId]
  /// * [status] - Only assignments with this status.
  /// * [page] - Page number, starting at 0.
  /// * [size] - Page size.
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ShiftAssignmentPage] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ShiftAssignmentPage>> listShiftAssignments({
    required String shiftId,
    AssignmentStatus? status,
    int? page = 0,
    int? size = 20,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/shifts/{shiftId}/assignments'.replaceAll(
        '{' r'shiftId' '}',
        encodeQueryParameter(_serializers, shiftId, const FullType(String))
            .toString());
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
      if (status != null)
        r'status': encodeQueryParameter(
            _serializers, status, const FullType(AssignmentStatus)),
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

    ShiftAssignmentPage? _responseData;

    try {
      final rawResponse = _response.data;
      _responseData = rawResponse == null
          ? null
          : _serializers.deserialize(
              rawResponse,
              specifiedType: const FullType(ShiftAssignmentPage),
            ) as ShiftAssignmentPage;
    } catch (error, stackTrace) {
      throw DioException(
        requestOptions: _response.requestOptions,
        response: _response,
        type: DioExceptionType.unknown,
        error: error,
        stackTrace: stackTrace,
      );
    }

    return Response<ShiftAssignmentPage>(
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

  /// Mark a worker as not turned up
  /// Sets a completed assignment to &#x60;NO_SHOW&#x60;. Dispatchers and admins only.  Error codes: &#x60;forbidden&#x60; (403), &#x60;shift_not_found&#x60; (404), &#x60;assignment_not_found&#x60; (404), and with 409: &#x60;assignment_not_completed&#x60; and &#x60;worker_attended&#x60; (the worker checked in or has approved hours).
  ///
  /// Parameters:
  /// * [shiftId]
  /// * [assignmentId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ShiftAssignment] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ShiftAssignment>> markNoShow({
    required String shiftId,
    required String assignmentId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/shifts/{shiftId}/assignments/{assignmentId}/no-show'
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

  /// Reject a claim
  /// Sets a pending assignment to &#x60;REJECTED&#x60; and frees its spot. Dispatchers and admins only.  Error codes: &#x60;forbidden&#x60; (403), &#x60;shift_not_found&#x60; (404), &#x60;assignment_not_found&#x60; (404), and with 409: &#x60;assignment_not_pending&#x60; and &#x60;concurrent_change&#x60; (the shift kept changing at the same moment; try again).
  ///
  /// Parameters:
  /// * [shiftId]
  /// * [assignmentId]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ShiftAssignment] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ShiftAssignment>> rejectAssignment({
    required String shiftId,
    required String assignmentId,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/shifts/{shiftId}/assignments/{assignmentId}/reject'
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

  /// Remove a worker from a shift
  /// Sets a pending or confirmed assignment to &#x60;CANCELLED&#x60; with &#x60;cancelledBy&#x60; &#x60;AGENCY&#x60; and frees its spot. The reason is kept for the agency; the worker does not see it. Dispatchers and admins only.  Field error codes: &#x60;required&#x60;, &#x60;invalid_length&#x60; (&#x60;reason&#x60;).  Error codes: &#x60;validation_failed&#x60; (400, with &#x60;errors&#x60;), &#x60;forbidden&#x60; (403), &#x60;shift_not_found&#x60; (404), &#x60;assignment_not_found&#x60; (404), and with 409: &#x60;assignment_not_active&#x60; (not pending or confirmed) and &#x60;concurrent_change&#x60; (the shift kept changing at the same moment; try again).
  ///
  /// Parameters:
  /// * [shiftId]
  /// * [assignmentId]
  /// * [removeAssignmentRequest]
  /// * [cancelToken] - A [CancelToken] that can be used to cancel the operation
  /// * [headers] - Can be used to add additional headers to the request
  /// * [extras] - Can be used to add flags to the request
  /// * [validateStatus] - A [ValidateStatus] callback that can be used to determine request success based on the HTTP status of the response
  /// * [onSendProgress] - A [ProgressCallback] that can be used to get the send progress
  /// * [onReceiveProgress] - A [ProgressCallback] that can be used to get the receive progress
  ///
  /// Returns a [Future] containing a [Response] with a [ShiftAssignment] as data
  /// Throws [DioException] if API call or serialization fails
  Future<Response<ShiftAssignment>> removeAssignment({
    required String shiftId,
    required String assignmentId,
    required RemoveAssignmentRequest removeAssignmentRequest,
    CancelToken? cancelToken,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
    ValidateStatus? validateStatus,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final _path = r'/shifts/{shiftId}/assignments/{assignmentId}/remove'
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
      contentType: 'application/json',
      validateStatus: validateStatus,
    );

    dynamic _bodyData;

    try {
      const _type = FullType(RemoveAssignmentRequest);
      _bodyData =
          _serializers.serialize(removeAssignmentRequest, specifiedType: _type);
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
}
