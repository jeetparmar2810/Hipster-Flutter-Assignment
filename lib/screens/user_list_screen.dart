import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hipster_inc_assignment/utils/app_strings.dart';
import 'package:hipster_inc_assignment/widgets/no_data.dart';

import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import '../widgets/user_tile.dart';
import '../utils/app_loader.dart';
import '../repositories/user_repository.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    return BlocProvider(
      create: (context) =>
          UserBloc(context.read<UserRepository>())..add(FetchUsersEvent()),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            AppStrings.usersTitle,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0E403F), Color(0xFF1F7B78), Color(0xFF00B7C2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserLoading) {
                return const Center(child: AppLoader());
              } else if (state is UserLoaded) {
                final users = state.users;

                if (users.isEmpty) {
                  return Center(
                    child: NoDataWidget(
                      icon: Icons.group,
                      message: AppStrings.userNotFound,
                    ),
                  );
                }

                return RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: const Color(0xFF00B7C2),
                  onRefresh: () async {
                    context.read<UserBloc>().add(FetchUsersEvent());
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: topPadding + 8, bottom: 16),
                    itemCount: users.length,
                    itemBuilder: (context, i) => UserTile(user: users[i]),
                  ),
                );
              } else if (state is UserError) {
                return Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ),
      ),
    );
  }
}
