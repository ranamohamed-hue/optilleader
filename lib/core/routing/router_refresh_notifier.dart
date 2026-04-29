import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:optialeader/feature/auth/logic/cubits/auth_cubit.dart';


class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(AuthCubit authCubit) {
    authCubit.stream.listen((_) {
      notifyListeners(); //  لما الحالة تتغير → اعمل refresh للراوتر
    });
  }
}