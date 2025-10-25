import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hipster_inc_assignment/app.dart';
import 'package:hipster_inc_assignment/blocs/auth/auth_bloc.dart';
import 'package:hipster_inc_assignment/repositories/auth_repository.dart';
import 'package:hipster_inc_assignment/repositories/user_repository.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    final authRepository = AuthRepository();
    final userRepository = UserRepository();

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

    await tester.pump();
    expect(find.byType(MyApp), findsOneWidget);
  });
}
