import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repo;

  UserBloc(this.repo) : super(UserInitial()) {
    on<FetchUsersEvent>((event, emit) async {
      emit(UserLoading());
      try {
        final users = await repo.fetchUsers();
        emit(UserLoaded(users));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
  }
}
