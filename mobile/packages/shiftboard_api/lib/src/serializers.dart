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

import 'package:shiftboard_api/src/model/agency_features.dart';
import 'package:shiftboard_api/src/model/agency_settings.dart';
import 'package:shiftboard_api/src/model/agency_summary.dart';
import 'package:shiftboard_api/src/model/assigned_worker.dart';
import 'package:shiftboard_api/src/model/assignment_status.dart';
import 'package:shiftboard_api/src/model/assignment_summary.dart';
import 'package:shiftboard_api/src/model/broadcast_request.dart';
import 'package:shiftboard_api/src/model/broadcast_result.dart';
import 'package:shiftboard_api/src/model/cancelled_by.dart';
import 'package:shiftboard_api/src/model/client.dart';
import 'package:shiftboard_api/src/model/client_page.dart';
import 'package:shiftboard_api/src/model/client_summary.dart';
import 'package:shiftboard_api/src/model/client_type.dart';
import 'package:shiftboard_api/src/model/conversation.dart';
import 'package:shiftboard_api/src/model/conversation_page.dart';
import 'package:shiftboard_api/src/model/conversation_worker.dart';
import 'package:shiftboard_api/src/model/current_user.dart';
import 'package:shiftboard_api/src/model/field_error.dart';
import 'package:shiftboard_api/src/model/location.dart';
import 'package:shiftboard_api/src/model/login_request.dart';
import 'package:shiftboard_api/src/model/message.dart';
import 'package:shiftboard_api/src/model/message_page.dart';
import 'package:shiftboard_api/src/model/message_request.dart';
import 'package:shiftboard_api/src/model/message_shift.dart';
import 'package:shiftboard_api/src/model/message_type.dart';
import 'package:shiftboard_api/src/model/notification_settings.dart';
import 'package:shiftboard_api/src/model/ping.dart';
import 'package:shiftboard_api/src/model/problem.dart';
import 'package:shiftboard_api/src/model/push_platform.dart';
import 'package:shiftboard_api/src/model/push_token_request.dart';
import 'package:shiftboard_api/src/model/qualification.dart';
import 'package:shiftboard_api/src/model/qualification_page.dart';
import 'package:shiftboard_api/src/model/refresh_token_request.dart';
import 'package:shiftboard_api/src/model/remove_assignment_request.dart';
import 'package:shiftboard_api/src/model/role.dart';
import 'package:shiftboard_api/src/model/shift.dart';
import 'package:shiftboard_api/src/model/shift_assignment.dart';
import 'package:shiftboard_api/src/model/shift_assignment_page.dart';
import 'package:shiftboard_api/src/model/shift_change_request.dart';
import 'package:shiftboard_api/src/model/shift_contact.dart';
import 'package:shiftboard_api/src/model/shift_page.dart';
import 'package:shiftboard_api/src/model/shift_period.dart';
import 'package:shiftboard_api/src/model/shift_request.dart';
import 'package:shiftboard_api/src/model/shift_status.dart';
import 'package:shiftboard_api/src/model/shift_template.dart';
import 'package:shiftboard_api/src/model/shift_template_page.dart';
import 'package:shiftboard_api/src/model/shift_template_request.dart';
import 'package:shiftboard_api/src/model/signup_info.dart';
import 'package:shiftboard_api/src/model/system_event.dart';
import 'package:shiftboard_api/src/model/token_response.dart';
import 'package:shiftboard_api/src/model/unread_count.dart';
import 'package:shiftboard_api/src/model/worker.dart';
import 'package:shiftboard_api/src/model/worker_page.dart';
import 'package:shiftboard_api/src/model/worker_profile.dart';
import 'package:shiftboard_api/src/model/worker_shift.dart';
import 'package:shiftboard_api/src/model/worker_shift_page.dart';
import 'package:shiftboard_api/src/model/worker_signup_request.dart';
import 'package:shiftboard_api/src/model/worker_status.dart';

part 'serializers.g.dart';

@SerializersFor([
  AgencyFeatures,
  AgencySettings,
  AgencySummary,
  AssignedWorker,
  AssignmentStatus,
  AssignmentSummary,
  BroadcastRequest,
  BroadcastResult,
  CancelledBy,
  Client,
  ClientPage,
  ClientSummary,
  ClientType,
  Conversation,
  ConversationPage,
  ConversationWorker,
  CurrentUser,
  FieldError,
  Location,
  LoginRequest,
  Message,
  MessagePage,
  MessageRequest,
  MessageShift,
  MessageType,
  NotificationSettings,
  Ping,
  Problem,
  PushPlatform,
  PushTokenRequest,
  Qualification,
  QualificationPage,
  RefreshTokenRequest,
  RemoveAssignmentRequest,
  Role,
  Shift,
  ShiftAssignment,
  ShiftAssignmentPage,
  ShiftChangeRequest,
  ShiftContact,
  ShiftPage,
  ShiftPeriod,
  ShiftRequest,
  ShiftStatus,
  ShiftTemplate,
  ShiftTemplatePage,
  ShiftTemplateRequest,
  SignupInfo,
  SystemEvent,
  TokenResponse,
  UnreadCount,
  Worker,
  WorkerPage,
  WorkerProfile,
  WorkerShift,
  WorkerShiftPage,
  WorkerSignupRequest,
  WorkerStatus,
])
Serializers serializers = (_$serializers.toBuilder()
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Client)]),
        () => ListBuilder<Client>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Message)]),
        () => ListBuilder<Message>(),
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
        const FullType(BuiltList, [FullType(ShiftAssignment)]),
        () => ListBuilder<ShiftAssignment>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(FieldError)]),
        () => ListBuilder<FieldError>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Location)]),
        () => ListBuilder<Location>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(WorkerShift)]),
        () => ListBuilder<WorkerShift>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(Conversation)]),
        () => ListBuilder<Conversation>(),
      )
      ..addBuilderFactory(
        const FullType(BuiltList, [FullType(ShiftTemplate)]),
        () => ListBuilder<ShiftTemplate>(),
      )
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer()))
    .build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();
