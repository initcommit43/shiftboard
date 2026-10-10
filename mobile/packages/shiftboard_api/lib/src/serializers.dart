//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:shiftboard_api/src/date_serializer.dart';
import 'package:shiftboard_api/src/model/date.dart';

import 'package:shiftboard_api/src/model/agency_summary.dart';
import 'package:shiftboard_api/src/model/client_type.dart';
import 'package:shiftboard_api/src/model/current_user.dart';
import 'package:shiftboard_api/src/model/field_error.dart';
import 'package:shiftboard_api/src/model/login_request.dart';
import 'package:shiftboard_api/src/model/ping.dart';
import 'package:shiftboard_api/src/model/problem.dart';
import 'package:shiftboard_api/src/model/qualification.dart';
import 'package:shiftboard_api/src/model/refresh_token_request.dart';
import 'package:shiftboard_api/src/model/role.dart';
import 'package:shiftboard_api/src/model/signup_info.dart';
import 'package:shiftboard_api/src/model/token_response.dart';
import 'package:shiftboard_api/src/model/worker.dart';
import 'package:shiftboard_api/src/model/worker_page.dart';
import 'package:shiftboard_api/src/model/worker_profile.dart';
import 'package:shiftboard_api/src/model/worker_signup_request.dart';
import 'package:shiftboard_api/src/model/worker_status.dart';

part 'serializers.g.dart';

@SerializersFor([
  AgencySummary,
  ClientType,
  CurrentUser,
  FieldError,
  LoginRequest,
  Ping,
  Problem,
  Qualification,
  RefreshTokenRequest,
  Role,
  SignupInfo,
  TokenResponse,
  Worker,
  WorkerPage,
  WorkerProfile,
  WorkerSignupRequest,
  WorkerStatus,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Qualification)]),
        () => ListBuilder<Qualification>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Worker)]),
        () => ListBuilder<Worker>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(FieldError)]),
        () => ListBuilder<FieldError>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
