import 'package:mechanix_contacts/core/utils/enums.dart';
import 'package:mechanix_contacts/features/contacts/data/models/contacts.dart';
import 'package:equatable/equatable.dart';

class ContactsState extends Equatable {
  final List<ContactEntity> contacts;
  final ContactsStatus status;
  final ContactsError? error;

  const ContactsState({
    this.contacts = const [],
    this.status = ContactsStatus.initial,
    this.error,
  });

  ContactsState copyWith({
    List<ContactEntity>? contacts,
    ContactsStatus? status,
    ContactsError? error,
  }) {
    return ContactsState(
      contacts: contacts ?? this.contacts,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [contacts, status, error];
}
