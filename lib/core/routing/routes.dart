class Routes {
  static const login = '/login';
  static const register = '/register';
  static const databaseAdmin = '/databaseAdmin';
  static const admin = '/admin';
  static const judge = '/judge';
  static const user = '/user';
  static const changePassword = '/change-password';
  static const settings = '/settings';

  //صفحات الادمن الاساسية الخاصه بالشريط الجانبي
  static const announcements = '/admin/announcements';
  static const ordersList = '/admin/orders-list';
  static const userSearch = '/admin/user-search';
  static const fullemployeereports = '/admin/fullemployeereports';
  //صفحات مرتبطة بصفحة الاعلانات
  static const announcementDetails = '/admin/announcements/details';
  static const editAnnountmentPage = '/admin/announcements/edit';
  //صفحات خاصه بادارة الطلبات 
  static const fullEmployeeReport='/admin/orders-list/fullEmployeeReport';
  //صفحات خاصه بأدمن قاعدة البيانات
  static const addDoctorPage = '/databaseAdmin/addDoctorPage';
  static const addAdminPage = '/databaseAdmin/addAdminPage';
  static const addJudgePage = '/databaseAdmin/addJudgePage';
  static const searchPage='/databaseAdmin/searchPage';
  //صفحات خاصه بالمحكم
  static const judgeEvaluation = '/judge/evaluationScreen';
  //صفخات خاصه
  static const acadiminData = '/user/acadimicData';
  static const archievementPage = '/user/archievementPage';
  static const careerInfo = '/user/careerInfo';
  static const digitalArchieve = '/user/digitalArchieve';
  static const uploadFiles = '/user/uploadFiles';

  // \ مسارات صفحات رفع الأبحاث والأنشطة
  static const addResearch = '/user/addResearch';
  static const addActivity = '/user/addActivity';
  static const notification = '/notification';
}