import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: ShhhWhoIsItApp(),
    ),
  );
}

class ShhhWhoIsItApp extends ConsumerStatefulWidget {
  const ShhhWhoIsItApp({super.key});

  @override
  ConsumerState<ShhhWhoIsItApp> createState() => _ShhhWhoIsItAppState();
}

class _ShhhWhoIsItAppState extends ConsumerState<ShhhWhoIsItApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Shhh! Who Is It?',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
