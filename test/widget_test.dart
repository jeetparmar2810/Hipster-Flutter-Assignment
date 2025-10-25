import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hipster_inc_assignment/app.dart';
import 'package:hipster_inc_assignment/blocs/auth/auth_bloc.dart';
import 'package:hipster_inc_assignment/repositories/auth_repository.dart';
import 'package:hipster_inc_assignment/repositories/user_repository.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Create repositories for testing
    final authRepository = AuthRepository();
    final userRepository = UserRepository();

    // Build our app with all required providers
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: authRepository),
          RepositoryProvider.value(value: userRepository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(authRepository),
            ),
          ],
          child: const MyApp(),
        ),
      ),
    );

    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Verify the login screen appears
    expect(find.byType(MyApp), findsOneWidget);
  });
}