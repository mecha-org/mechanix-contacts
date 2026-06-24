import 'dart:io';

import 'package:mechanix_contacts/core/theme/app_theme.dart';
import 'package:mechanix_contacts/features/contacts/data/repositories/contacts_repository.dart';
import 'package:mechanix_contacts/features/contacts/data/repositories/contacts_repository_impl.dart';
import 'package:mechanix_contacts/features/contacts/blocs/contacts_bloc.dart';
import 'package:mechanix_contacts/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:mechanix_contacts/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:show_fps/show_fps.dart';

void main() {
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ContactsRepository>(
          create: (_) => ContactsRepositoryImpl(),
        ),
      ],

      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                ContactsBloc(context.read<ContactsRepository>()),
          ),
        ],

        child: const DialerApp(),
      ),
    ),
  );
}

class DialerApp extends StatelessWidget {
  const DialerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final showFps = Platform.environment['SHOW_FPS'] == 'true';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: showFps
          ? (context, child) {
              return ShowFPS(visible: showFps, showChart: false, child: child!);
            }
          : null,
      theme: AppTheme.darkTheme,
      home: const ContactsScreen(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
