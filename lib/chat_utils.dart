/// Builds a deterministic private chat id from two user ids.
///
/// The ids are sorted first so both participants always resolve to the same
/// Firestore path (`uidA_uidB`), regardless of who opens the chat first.
String buildPrivateChatId(String uid1, String uid2) {
  final sorted = [uid1, uid2]..sort();
  return '${sorted[0]}_${sorted[1]}';
}

String buildAvatarInitial(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return trimmed.substring(0, 1).toUpperCase();
}

String buildDisplayName(Map<String, dynamic> userData) {
  final name = (userData['username'] as String?)?.trim();
  if (name != null && name.isNotEmpty) {
    return name;
  }
  return (userData['email'] as String?) ?? 'Unknown user';
}
