import 'package:dio/dio.dart';
import '../models/report_model.dart';

class ReportApi {
  final Dio dio;

  ReportApi(this.dio);

  Future<ReportModel> getDailySales() async {
    final response = await dio.get("/Reports/DailySales");
    return ReportModel.fromJson(response.data);
  }

  Future<ReportModel> getWeeklySales() async {
    final response = await dio.get("/Reports/WeeklySales");
    return ReportModel.fromJson(response.data);
  }

  Future<ReportModel> getMonthlySales() async {
    final response = await dio.get("/Reports/MonthlySales");
    return ReportModel.fromJson(response.data);
  }

  Future<ReportModel> getYearlySales() async {
    final response = await dio.get("/Reports/YearlySales");
    return ReportModel.fromJson(response.data);
  }
}
