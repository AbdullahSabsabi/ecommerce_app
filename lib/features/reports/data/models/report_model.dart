class ReportModel {
  final double totalSales;
  final int totalOrders;
  final String reportPeriod;

  ReportModel({
    required this.totalSales,
    required this.totalOrders,
    required this.reportPeriod,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      totalSales: (json['totalSales'] as num).toDouble(),
      totalOrders: json['totalOrders'] as int,
      reportPeriod: json['reportPeriod'] as String,
    );
  }
}
