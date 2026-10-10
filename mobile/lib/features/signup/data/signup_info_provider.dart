import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftboard_api/shiftboard_api.dart';

import '../../../core/api/api_provider.dart';

/// The agency behind a signup code and the qualifications it offers.
final signupInfoProvider = FutureProvider.autoDispose
    .family<SignupInfo, String>(
      (ref, signupCode) async {
        final response = await ref
            .watch(apiProvider)
            .getSignupApi()
            .getSignupInfo(signupCode: signupCode);
        return response.data!;
      },
      // The screen offers a manual retry.
      retry: (retryCount, error) => null,
    );
