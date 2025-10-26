import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/user/user_bloc.dart';
import '../blocs/user/user_event.dart';
import '../blocs/user/user_state.dart';
import '../repositories/user_repository.dart';
import '../widgets/user_tile.dart';
import '../widgets/no_data.dart';
import '../utils/app_colors.dart';
import '../utils/app_dimens.dart';
import '../utils/app_strings.dart';
import '../utils/app_loader.dart';

class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight;
    return BlocProvider(
      create: (context) => UserBloc(context.read<UserRepository>())..add(FetchUsersEvent()),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            AppStrings.usersTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gradientStart,
                AppColors.gradientMiddle,
                AppColors.gradientEnd,
              ],
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
                      iconColor: AppColors.textPrimary,
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.buttonPrimary,
                  backgroundColor: AppColors.primary,
                  onRefresh: () async {
                    context.read<UserBloc>().add(FetchUsersEvent());
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: topPadding + AppDimens.paddingSmall,
                      bottom: AppDimens.paddingMedium,
                    ),
                    itemCount: users.length,
                    itemBuilder: (context, i) => UserTile(user: users[i]),
                  ),
                );
              } else if (state is UserError) {
                return Center(
                  child: Text(
                    '${"${AppStrings.errorTitle} : "} ${state.message}',
                    style: const TextStyle(color: AppColors.textPrimary),
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
