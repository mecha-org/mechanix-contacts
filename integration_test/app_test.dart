import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mechanix_contacts/main.dart';
import 'package:mechanix_contacts/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:mechanix_contacts/features/contacts/presentation/screens/contact_form_screen.dart';
import 'package:mechanix_contacts/features/contacts/presentation/screens/contact_details_screen.dart';
import 'package:mechanix_contacts/features/contacts/data/repositories/contacts_repository.dart';
import 'package:mechanix_contacts/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:mechanix_contacts/features/contacts/blocs/contacts_bloc.dart';
import 'package:mechanix_contacts/l10n/app_localizations.dart';
import 'package:mechanix_contacts/objectbox.g.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Contacts Integration Tests', () {
    late Directory tempDir;
    late Store store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('contacts_integration_test_');
      store = openStore(directory: tempDir.path);
    });

    tearDown(() async {
      store.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    Widget createTestApp() {
      final repository = ContactsRepositoryImpl(store: store);

      return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ContactsRepository>.value(value: repository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ContactsBloc(context.read<ContactsRepository>()),
            ),
          ],
          child: const DialerApp(),
        ),
      );
    }

    testWidgets('Add, search, view details, and delete a contact', (WidgetTester tester) async {
      // 1. Launch the application
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Verify ContactsScreen is shown
      expect(find.byType(ContactsScreen), findsOneWidget);

      final BuildContext context = tester.element(find.byType(ContactsScreen));
      final l10n = AppLocalizations.of(context)!;

      // 2. Navigate to ContactFormScreen
      final addButton = find.byIcon(Icons.add);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.byType(ContactFormScreen), findsOneWidget);

      // 3. Fill in name and phone number
      final nameField = find.widgetWithText(TextFormField, l10n.enterName).first;
      expect(nameField, findsOneWidget);
      await tester.enterText(nameField, 'Alice Smith');
      await tester.pump();

      final phoneField = find.widgetWithText(TextFormField, l10n.enterPhoneNumber).first;
      expect(phoneField, findsOneWidget);
      await tester.enterText(phoneField, '9876543210');
      await tester.pump();

      // 4. Save the contact
      final saveButton = find.byIcon(Icons.check);
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify we are back on ContactsScreen and "Alice Smith" is listed
      expect(find.byType(ContactsScreen), findsOneWidget);
      expect(find.text('Alice Smith'), findsOneWidget);

      // 5. Test search functionality
      final searchField = find.widgetWithText(TextField, l10n.searchInContacts);
      expect(searchField, findsOneWidget);

      // Search for non-existent contact
      await tester.enterText(searchField, 'Bob');
      await tester.pumpAndSettle();
      expect(find.text('Alice Smith'), findsNothing);

      // Search for Alice
      await tester.enterText(searchField, 'Alice');
      await tester.pumpAndSettle();
      expect(find.text('Alice Smith'), findsOneWidget);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      expect(find.text('Alice Smith'), findsOneWidget);

      // 6. Navigate to ContactDetailsScreen
      await tester.tap(find.text('Alice Smith'));
      await tester.pumpAndSettle();

      expect(find.byType(ContactDetailsScreen), findsOneWidget);
      expect(find.text('Alice Smith'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);

      // 7. Open Actions Menu and edit contact
      final moreButton = find.byIcon(Icons.more_vert);
      expect(moreButton, findsOneWidget);
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Tap Edit contact from the options
      final editOption = find.text(l10n.editContact);
      expect(editOption, findsOneWidget);
      await tester.tap(editOption);
      await tester.pumpAndSettle();

      // Verify ContactFormScreen is shown for editing
      expect(find.byType(ContactFormScreen), findsOneWidget);

      // Enter new name and phone number
      final editNameField = find.widgetWithText(TextFormField, l10n.enterName).first;
      expect(editNameField, findsOneWidget);
      await tester.enterText(editNameField, 'Alice Cooper');
      await tester.pump();

      final editPhoneField = find.widgetWithText(TextFormField, l10n.enterPhoneNumber).first;
      expect(editPhoneField, findsOneWidget);
      await tester.enterText(editPhoneField, '111222333');
      await tester.pump();

      // Save edited details
      final saveEditButton = find.byIcon(Icons.check);
      expect(saveEditButton, findsOneWidget);
      await tester.tap(saveEditButton);
      await tester.pumpAndSettle();

      // Verify we are back on ContactDetailsScreen with updated details
      expect(find.byType(ContactDetailsScreen), findsOneWidget);
      expect(find.text('Alice Cooper'), findsOneWidget);
      expect(find.text('111222333'), findsOneWidget);

      // 8. Open Actions Menu and delete contact
      expect(moreButton, findsOneWidget);
      await tester.tap(moreButton);
      await tester.pumpAndSettle();

      // Tap Delete contact from the options
      final deleteOption = find.text(l10n.deleteContact);
      expect(deleteOption, findsOneWidget);
      await tester.tap(deleteOption);
      await tester.pumpAndSettle();

      // Tap Delete confirmation button in the bottom sheet
      final confirmDeleteButton = find.text(l10n.delete);
      expect(confirmDeleteButton, findsOneWidget);
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle();

      // Verify we are back on ContactsScreen and "Alice Cooper" is deleted
      expect(find.byType(ContactsScreen), findsOneWidget);
      expect(find.text('Alice Cooper'), findsNothing);
    });
  });
}
