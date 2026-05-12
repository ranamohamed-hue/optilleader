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
      // لو عايز تفلتر لدكاترة بس خليها role: 'user'
      // لو عايز كل الناس خليها role: null
      role: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("بحث عن موظفين"),
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
                  label: Text("البحث بالاسم"),
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
                  label: Text("البحث بالرقم الوظيفي"),
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
                    ? "اكتب اسم الموظف..."
                    : "اكتب الرقم الوظيفي...",
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
                  // يبدأ يبحث بعد حرفين
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
                    return Center(
                      child: Text(
                        state.message,
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  } else if (state is SearchSuccess) {
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
                      "ابدأ بكتابة الاسم أو الرقم الوظيفي",
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
        subtitle: Text("الرقم الوظيفي: ${user.employeeId}"),
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
              // 🟢 هنا بنوجهه للصفحة الصح وبنبعت الـ UID
              onPressed: () {
                String targetRoute;
                if (user.role == UserRole.user) {
                  targetRoute =
                      Routes.addDoctorPage; // لو الدكتور عنده role = user
                } else if (user.role == UserRole.admin) {
                  targetRoute = Routes.addAdminPage;
                } else if (user.role == UserRole.judge) {
                  targetRoute = Routes.addJudgePage;
                } else {
                  return; // لو نوع تاني ماتعملش حاجة
                }

                // بنوديه لصفحة الإضافة وبنبعت الـ UID كـ Argument
                context.push(targetRoute, extra: user.uid);
              },
            ),
          ],
        ),
      ),
    );
  }
}
