import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import 'package:optialeader/core/theming/app_color.dart';
import 'package:optialeader/core/routing/routes.dart';
import 'package:optialeader/feature/auth/data/models/user_model.dart';
import 'package:optialeader/feature/database_admin/logic/search/search_cubit.dart';
import 'package:optialeader/feature/database_admin/logic/search/search_state.dart';

class EmployeeSearchScreen extends StatefulWidget {
  const EmployeeSearchScreen({super.key});

  @override
  State<EmployeeSearchScreen> createState() => _EmployeeSearchScreenState();
}

class _EmployeeSearchScreenState extends State<EmployeeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchField = 'username'; // افتراضياً بالاسم

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    context.read<SearchCubit>().searchUsers(
      query: _searchController.text,
      searchField: _searchField,
      role: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("employee_search.title".tr()),
        backgroundColor: AppColors.navyDark,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // خيارات البحث
            Row(
              children: [
                ChoiceChip(
                  label: Text("employee_search.by_name".tr()),
                  selected: _searchField == 'username',
                  selectedColor: AppColors.darkGold,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() => _searchField = 'username');
                      _performSearch();
                    }
                  },
                ),
                SizedBox(width: 10.w),
                ChoiceChip(
                  label: Text("employee_search.by_id".tr()),
                  selected: _searchField == 'employee_id',
                  selectedColor: AppColors.darkGold,
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() => _searchField = 'employee_id');
                      _performSearch();
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 15.h),

            // حقل البحث
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _searchField == 'username'
                    ? "employee_search.hint_name".tr()
                    : "employee_search.hint_id".tr(),
                prefixIcon: Icon(Icons.search, color: AppColors.navyDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.navyDark),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColors.darkGold, width: 2),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SearchCubit>().searchUsers(
                      query: '',
                      searchField: _searchField,
                    );
                  },
                ),
              ),
              onSubmitted: (_) => _performSearch(),
              onChanged: (value) {
                if (value.length >= 2) {
                  _performSearch();
                }
              },
            ),
            SizedBox(height: 20.h),

            // عرض النتائج
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.darkGold,
                      ),
                    );
                  } else if (state is SearchError) {
                    // ✅ ترجمة كود الخطأ القادم من الـ Cubit
                    String errorMessage = state.message;
                    if (state.message == "ERROR_SEARCH_FAILED") {
                      errorMessage = "employee_search.error".tr();
                    }
                    return Center(
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  } else if (state is SearchSuccess) {
                    // ✅ معالجة حالة القائمة الفارغة
                    if (state.users.isEmpty) {
                      return Center(
                        child: Text(
                          "employee_search.no_users".tr(),
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return _buildUserCard(user);
                      },
                    );
                  }
                  return Center(
                    child: Text(
                      "employee_search.start_searching".tr(),
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // كارت عرض الموظف
  Widget _buildUserCard(UserModel user) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.navyDark,
          child: Icon(Icons.person, color: AppColors.darkGold, size: 24.sp),
        ),
        title: Text(
          user.username,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navyDark,
          ),
        ),
        subtitle: Text(
          "employee_search.employee_id_label".tr(args: [user.employeeId]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                user.roleString,
                style: TextStyle(color: Colors.white, fontSize: 10.sp),
              ),
              backgroundColor: AppColors.navyLight,
            ),
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.navyDark),
              tooltip: "employee_search.edit".tr(),
              onPressed: () {
                String targetRoute;
                if (user.role == UserRole.user) {
                  targetRoute = Routes.addDoctorPage;
                } else if (user.role == UserRole.admin) {
                  targetRoute = Routes.addAdminPage;
                } else if (user.role == UserRole.judge) {
                  targetRoute = Routes.addJudgePage;
                } else {
                  return;
                }

                context.push(targetRoute, extra: user.uid);
              },
            ),
          ],
        ),
      ),
    );
  }
}
