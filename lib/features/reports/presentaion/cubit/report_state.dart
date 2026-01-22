import 'package:clothesecommerce/features/reports/data/models/report_model.dart';

abstract class ReportState {}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final ReportModel report;
  ReportLoaded(this.report);
}

class ReportError extends ReportState {
  final String message;
  ReportError(this.message);
}
