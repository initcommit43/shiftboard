/// The path segment in front of the code in an invitation link, as in
/// `shiftboard://join/<code>`.
const invitationLinkSegment = 'join';

final _code = RegExp(r'^[A-Za-z0-9._~-]{1,64}$');

/// Reads the signup code from what a worker pasted: the agency's invitation
/// link or the bare code. Returns null when there is no code in it.
String? parseInvitationCode(String input) {
  final text = input.trim();
  if (_code.hasMatch(text)) return text;

  final uri = Uri.tryParse(text);
  if (uri == null) return null;

  // In `shiftboard://join/<code>` the marker is the host, in a web link
  // (`https://…/join/<code>`) a path segment.
  final segments = [uri.host, ...uri.pathSegments];
  final marker = segments.indexOf(invitationLinkSegment);
  if (marker < 0 || marker + 1 >= segments.length) return null;

  final code = segments[marker + 1];
  return _code.hasMatch(code) ? code : null;
}
