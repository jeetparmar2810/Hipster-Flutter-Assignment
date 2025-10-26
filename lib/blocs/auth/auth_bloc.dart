import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import '../../utils/app_strings.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final success = await repository.login(event.email, event.password);
        if (success) {
          emit(AuthSuccess());
        } else {
          emit(AuthFailure(AppStrings.invalidCredentials));
        }
      } catch (e) {
        emit(AuthFailure(AppStrings.loginFailed));
      }
    });
  }
}
