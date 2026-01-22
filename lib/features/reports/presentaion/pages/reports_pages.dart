import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/features/reports/data/models/report_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/report_cubit.dart';
import '../cubit/report_state.dart';

class ReportsPage extends StatefulWidget {
  static const String routeName = "/reports";
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<ReportCubit>().fetchDailySales();
  }

  void _onTabChanged(int index) {
    final cubit = context.read<ReportCubit>();
    switch (index) {
      case 0:
        cubit.fetchDailySales();
        break;
      case 1:
        cubit.fetchWeeklySales();
        break;
      case 2:
        cubit.fetchMonthlySales();
        break;
      case 3:
        cubit.fetchYearlySales();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.watch<AppColors>().primaryColor,
              context.watch<AppColors>().primaryColor.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                controller: _tabController,
                onTap: _onTabChanged,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                tabs: const [
                  Tab(text: "يومي"),
                  Tab(text: "أسبوعي"),
                  Tab(text: "شهري"),
                  Tab(text: "سنوي"),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BlocBuilder<ReportCubit, ReportState>(
                  builder: (context, state) {
                    if (state is ReportLoading) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (state is ReportLoaded) {
                      return _buildReportContent(state.report);
                    } else if (state is ReportError) {
                      return Center(
                        child: Text(
                          "⚠️ خطأ: ${state.message}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      );
                    }
                    return const Center(
                      child: Text(
                        "اختر نوع التقرير",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent(ReportModel report) {
    // معالجة إذا ما في بيانات
    if (report.totalOrders == 0 && report.totalSales == 0) {
      return const Center(
        child: Text(
          "لا يوجد بيانات لعرضها 📉",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    final maxValue = (report.totalOrders > report.totalSales
        ? report.totalOrders
        : report.totalSales);
    final safeMax = maxValue == 0 ? 1 : maxValue;

    // نحسب interval بشكل آمن
    final interval = (safeMax / 5).ceilToDouble();
    final safeInterval = interval == 0 ? 1.0 : interval;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  color: Colors.orangeAccent,
                  icon: Icons.attach_money_sharp,
                  label: "المبيعات",
                  value: "${report.totalSales} ل.س",
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  color: Colors.lightBlueAccent,
                  icon: Icons.shopping_cart,
                  label: "الطلبات",
                  value: "${report.totalOrders}",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // فترة التقرير
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 6,
            color: Colors.white.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "📅 الفترة: ${report.reportPeriod}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Bar Chart
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (safeMax * 1.2).toDouble(),
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: safeInterval, // ✅ آمن
                      getTitlesWidget: (value, meta) {
                        String formatted;
                        if (value >= 1000000) {
                          formatted =
                              "${(value / 1000000).toStringAsFixed(1)}M";
                        } else if (value >= 1000) {
                          formatted = "${(value / 1000).toStringAsFixed(1)}k";
                        } else {
                          formatted = value.toInt().toString();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: Text(
                            formatted,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ["المبيعات", "الطلبات"];
                        if (value.toInt() < labels.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(
                              labels[value.toInt()],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const Text("");
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: safeInterval, // ✅ آمن
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.2),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: report.totalSales.toDouble(),
                        color: Colors.orangeAccent,
                        width: 40,
                        borderRadius: BorderRadius.circular(8),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: safeMax.toDouble(),
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: report.totalOrders.toDouble(),
                        color: Colors.lightBlueAccent,
                        width: 40,
                        borderRadius: BorderRadius.circular(8),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: safeMax.toDouble(),
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required Color color,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      color: Colors.white.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.3),
              radius: 25,
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
