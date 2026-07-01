/// Lightweight date formatting (no intl dependency) for the mobile UI.
String formatDate(DateTime date) {
  final d = date.toLocal();
  return '${d.month}/${d.day}/${d.year}';
}

String formatDateTime(DateTime date) {
  final d = date.toLocal();
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.month}/${d.day}/${d.year} $hh:$mm';
}

/// "yyyy-MM-dd" for the follow-up payload's date field (backend parses ISO).
String toApiDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
