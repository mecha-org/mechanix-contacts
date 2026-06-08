import 'package:mechanix_contacts/features/contacts/data/models/contacts.dart';
import 'package:mechanix_contacts/features/contacts/data/models/sim_card.dart';

abstract class ContactsRepository {
  Future<List<ContactEntity>> getAll();

  Future<ContactEntity?> getById(int id);

  Future<void> save(
    ContactEntity contact,
    List<String> numbers,
    List<String>? emails,
  );

  Future<void> delete(int id);

  Future<List<ContactEntity>> search(String query);

  Future<List<SimCardEntity>> getSimCards();
}
