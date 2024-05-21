import '../entities/api_response.dart';
import '../entities/dashboard/dashboard_response.dart';

abstract class DashboardRepo{
  Future<ApiResponse<DashboardResponse?>> getDashboardData();
}