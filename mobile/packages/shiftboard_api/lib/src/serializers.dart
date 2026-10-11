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
import 'package:shiftboard_api/src/model/client.dart';
import 'package:shiftboard_api/src/model/client_page.dart';
import 'package:shiftboard_api/src/model/client_summary.dart';
import 'package:shiftboard_api/src/model/client_type.dart';
import 'package:shiftboard_api/src/model/current_user.dart';
import 'package:shiftboard_api/src/model/field_error.dart';
import 'package:shiftboard_api/src/model/location.dart';
import 'package:shiftboard_api/src/model/login_request.dart';
import 'package:shiftboard_api/src/model/ping.dart';
import 'package:shiftboard_api/src/model/problem.dart';
import 'package:shiftboard_api/src/model/qualification.dart';
import 'package:shiftboard_api/src/model/qualification_page.dart';
import 'package:shiftboard_api/src/model/refresh_token_request.dart';
import 'package:shiftboard_api/src/model/role.dart';
import 'package:shiftboard_api/src/model/shift.dart';
import 'package:shiftboard_api/src/model/shift_page.dart';
import 'package:shiftboard_api/src/model/shift_request.dart';
import 'package:shiftboard_api/src/model/shift_status.dart';
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
  Client,
  ClientPage,
  ClientSummary,
  ClientType,
  CurrentUser,
  FieldError,
  Location,
  LoginRequest,
  Ping,
  Problem,
  Qualification,
  QualificationPage,
  RefreshTokenRequest,
  Role,
  Shift,
  ShiftPage,
  ShiftRequest,
  ShiftStatus,
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
        const FullType(BuiltList, [FullType(Client)]),
        () => ListBuilder<Client>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Qualification)]),
        () => ListBuilder<Qualification>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Worker)]),
        () => ListBuilder<Worker>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltSet, [FullType(String)]),
        () => SetBuilder<String>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Shift)]),
        () => ListBuilder<Shift>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(FieldError)]),
        () => ListBuilder<FieldError>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Location)]),
        () => ListBuilder<Location>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
