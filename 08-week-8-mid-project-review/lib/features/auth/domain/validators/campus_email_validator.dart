/// Checks the basic email shape required by the Campus Notify demo login.
///
/// This is client-side validation only; a real authentication service must
/// still validate the account and credentials.
bool isValidCampusEmail(String email) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());
