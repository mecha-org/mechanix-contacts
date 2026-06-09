import 'package:mechanix_contacts/core/utils/enums.dart';
import 'package:mechanix_contacts/l10n/app_localizations.dart';

String getInitials(String name) {
  if (name.isEmpty) return "";
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length > 1) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return name[0].toUpperCase();
}

String? validateEmail(AppLocalizations l10n, String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }

  final email = value.trim();

  const pattern = r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';

  if (!RegExp(pattern).hasMatch(email)) {
    return l10n.invalidEmail;
  }

  return null;
}

String getErrorMessage(AppLocalizations l10n, ContactsError error) {
  switch (error) {
    case ContactsError.loadFailed:
      return l10n.failedToLoadContacts;

    case ContactsError.saveFailed:
      return l10n.failedToSaveContact;

    case ContactsError.deleteFailed:
      return l10n.failedToDeleteContact;

    case ContactsError.updateFailed:
      return l10n.failedToUpdateContact;

    case ContactsError.storeUnavailable:
      return l10n.contactsDatabaseUnavailable;

    case ContactsError.unknown:
      return l10n.somethingWentWrong;

    case ContactsError.searchFailed:
      return l10n.failedToSearchContact;
  }
}
