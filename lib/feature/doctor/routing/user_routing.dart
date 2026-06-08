import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/doctor/ui/screens/acadimic_data.dart';
import 'package:optialeader/feature/doctor/ui/screens/announctments_datails_doctor_page.dart';
import 'package:optialeader/feature/doctor/ui/screens/archievement_page.dart';
import 'package:optialeader/feature/doctor/ui/screens/career_info_page.dart';
import 'package:optialeader/feature/doctor/ui/screens/digital_archieve.dart';
import 'package:optialeader/feature/doctor/ui/screens/uploadfiles.dart';
import 'package:optialeader/feature/doctor/ui/screens/add_research_paper_page.dart';
import 'package:optialeader/feature/doctor/ui/screens/add_activity_page.dart';
final List<RouteBase> userSubRoutes = [
  GoRoute(
    path: 'acadimicData',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return DoctorProfileDataPage(doctorUid: uid);
    },
  ),
  GoRoute(
    path: 'archievementPage',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return AchievementsLogPage(doctorUid: uid); 
    },
  ),
  GoRoute(
    path: 'careerInfo',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return CareerInfoPage(doctorUid: uid);
    },
  ),
  GoRoute(
    path: 'digitalArchieve',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return DigitalArchivePage(doctorUid: uid);
    },
  ),
  GoRoute(
    path: 'uploadFiles',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return UploadFilePage(doctorUid: uid);
    },
  ),
  GoRoute(
    path: 'addResearch',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return AddResearchPaperPage(doctorUid: uid);
    },
  ),
  GoRoute(
    path: 'addActivity',
    builder: (context, state) {
      final String uid = state.uri.queryParameters['uid'] ?? '';
      return AddActivityPage(doctorUid: uid);
    },
  ),
  GoRoute(
    path: 'announcementsDetailsDoctor',
    builder: (context, state) {
      // استقبال الـ ID من الرابط
      final String id = state.uri.queryParameters['id'] ?? '';
      return AnnouncementDetailsDoctorPage(announcementId: id);
    },
  ),
];