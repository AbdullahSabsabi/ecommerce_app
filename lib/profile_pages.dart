import 'package:clothesecommerce/constant.dart';
import 'package:clothesecommerce/core/models/user_model.dart';
import 'package:clothesecommerce/core/network/is_admin.dart';
import 'package:clothesecommerce/features/cart/presentaion/cubit/cart_cubit.dart';
import 'package:clothesecommerce/features/reports/presentaion/pages/reports_pages.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static String nameScreen = 'ProfilePage';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  User? currentUser;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    loadUser();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> loadUser() async {
    final user = await AuthHelper.getUserFromToken();
    setState(() {
      currentUser = user;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: context.watch<AppColors>().primaryColor,
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : currentUser == null
          ? const Center(
              child: Text(
                'لم يتم تسجيل الدخول',
                style: TextStyle(fontSize: 18),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // شعار دائري متحرك
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.watch<AppColors>().primaryColor,
                              Color.fromARGB(255, 254, 254, 254),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -60,
                        child: ScaleTransition(
                          scale: _animation,
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: context
                                  .watch<AppColors>()
                                  .primaryColor,
                              child: const Icon(
                                FontAwesomeIcons.user,
                                color: Colors.white,
                                size: 60,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // بيانات المستخدم
                        _buildProfileCard(
                          'اسم المستخدم',
                          currentUser!.userName,
                          FontAwesomeIcons.user,
                        ),
                        const SizedBox(height: 15),
                        _buildProfileCard(
                          'الايميل',
                          currentUser!.email,
                          FontAwesomeIcons.envelope,
                        ),
                        const SizedBox(height: 15),
                        _buildProfileCard(
                          'كلمة المرور',
                          '********',
                          FontAwesomeIcons.lock,
                        ),
                        const SizedBox(height: 15),
                        _buildProfileCard(
                          'نوع الحساب',
                          currentUser!.role == 1 ? 'مسؤول' : 'مستخدم',
                          FontAwesomeIcons.userShield,
                        ),
                        const SizedBox(height: 25),

                        // زر التقارير للأدمن فقط
                        FutureBuilder<bool>(
                          future: AuthHelper.isAdmin(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox();
                            }
                            if (snapshot.hasData && snapshot.data == true) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReportsPage(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    FontAwesomeIcons.chartBar,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'التقارير',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: context
                                        .watch<AppColors>()
                                        .primaryColor,
                                    minimumSize: const Size(
                                      double.infinity,
                                      55,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 6,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),

                        // اختيار لون التطبيق
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'اختر لون التطبيق:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Consumer<AppColors>(
                              builder: (context, appColors, _) {
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 5,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 1,
                                      ),
                                  itemCount: appColors.availableColors.length,
                                  itemBuilder: (context, index) {
                                    final color =
                                        appColors.availableColors[index];
                                    final isSelected =
                                        color.value ==
                                        appColors.primaryColor.value;
                                    return GestureDetector(
                                      onTap: () =>
                                          appColors.setPrimaryColor(color),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.transparent,
                                            width: 3,
                                          ),
                                          boxShadow: [
                                            if (isSelected)
                                              BoxShadow(
                                                color: color.withOpacity(0.6),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                          ],
                                        ),
                                        child: isSelected
                                            ? const Center(
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 28,
                                                ),
                                              )
                                            : null,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // زر تسجيل الخروج
                        ElevatedButton.icon(
                          onPressed: () async {
                            await CartCubit().clearCart();
                            await AuthHelper.logout();
                            setState(() {
                              currentUser = null;
                            });
                            Navigator.popUntil(
                              context,
                              (route) => route.isFirst,
                            );
                          },
                          icon: const Icon(
                            FontAwesomeIcons.arrowRightFromBracket,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: context
                                .watch<AppColors>()
                                .primaryColor,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 6,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard(String title, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: context.watch<AppColors>().primaryColor,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
