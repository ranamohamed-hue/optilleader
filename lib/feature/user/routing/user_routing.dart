
import 'package:go_router/go_router.dart';
import 'package:optialeader/feature/user/ui/screens/acadimic_data.dart';
import 'package:optialeader/feature/user/ui/screens/archievement_page.dart';
import 'package:optialeader/feature/user/ui/screens/career_info_page.dart';
import 'package:optialeader/feature/user/ui/screens/digital_archieve.dart';
import 'package:optialeader/feature/user/ui/screens/uploadfiles.dart';


final List<RouteBase>userSubRoutes=[
   
  GoRoute(path: 'acadiminData',
  builder: (context, state) => DoctorProfileDataPage(),),
  GoRoute(path: 'archievementPage',
builder: (context, state) => AchievementsLogPage(),),
GoRoute(path: 'careerInfo',
builder: (context, state) => CareerInfoPage(),),
GoRoute(path: 'digitalArchieve',
builder: (context, state) => DigitalArchivePage(),),
GoRoute(path: 'uploadFiles',
builder: (context, state) => UploadFilePage(),)
];