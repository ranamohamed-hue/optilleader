import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/doctor/ui/screens/acadimic_data.dart';
import 'package:optialeader/feature/doctor/ui/screens/archievement_page.dart';
import 'package:optialeader/feature/doctor/ui/screens/career_info_page.dart';
import 'package:optialeader/feature/doctor/ui/screens/digital_archieve.dart';
import 'package:optialeader/feature/doctor/ui/screens/uploadfiles.dart';

final List<RouteBase> userSubRoutes = [
  GoRoute(
    path: 'acadiminData',
    builder: (context, state) => const DoctorProfileDataPage(),
  ),
  GoRoute(
    path: 'archievementPage',
    builder: (context, state) => const AchievementsLogPage(),
  ),
  GoRoute(
    path: 'careerInfo',
    builder: (context, state) => const CareerInfoPage(),
  ),
  GoRoute(
    path: 'digitalArchieve',
    builder: (context, state) => const DigitalArchivePage(),
  ),
  // ✅ [تعديل] استقبال الـ uid من الـ Query Parameters
  GoRoute(
    path: 'uploadFiles',
    builder: (context, state) {
      // بنجيب الـ uid من اللينك اللي جاي من الصفحة اللي فاتت
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return UploadFilePage(doctorUid: uid);
    },
  ),
];