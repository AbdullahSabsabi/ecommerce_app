import 'package:clothesecommerce/features/reports/data/api/report_api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  final ReportApi reportApi;

  ReportCubit(this.reportApi) : super(ReportInitial());

  Future<void> fetchDailySales() async {
    emit(ReportLoading());
    try {
      final report = await reportApi.getDailySales();
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> fetchWeeklySales() async {
    emit(ReportLoading());
    try {
      final report = await reportApi.getWeeklySales();
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> fetchMonthlySales() async {
    emit(ReportLoading());
    try {
      final report = await reportApi.getMonthlySales();
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> fetchYearlySales() async {
    emit(ReportLoading());
    try {
      final report = await reportApi.getYearlySales();
      emit(ReportLoaded(report));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
