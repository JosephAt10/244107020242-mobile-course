/// Returns a validation message when a note title is missing or whitespace.
String? validateNoteTitle(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter a title';
  return null;
}
