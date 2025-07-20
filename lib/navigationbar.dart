import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:medicineapp/appointments.dart';
import 'package:medicineapp/dashboard.dart';
import 'package:medicineapp/emailbroadcast.dart';
import 'package:medicineapp/patientpage.dart';
import 'package:medicineapp/userspage.dart';
import 'package:medicineapp/warehouse.dart';

class NavigatorBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final String userId;

  const NavigatorBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.react, // cool ripple/floating animation
      backgroundColor: Colors.grey.shade300,
      activeColor: Colors.black,
      color: Colors.grey.shade700,
      items: const [
        TabItem(icon: Icons.medical_services_outlined),
        TabItem(icon: Icons.contact_page),
        TabItem(icon: Icons.home),
        TabItem(icon: Icons.podcasts),
        TabItem(icon: Icons.group),
         TabItem(icon: Icons.inventory),
      ],
      initialActiveIndex: currentIndex,
      onTap: (index) {
        // Navigation logic
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AppointmentPage(userId: userId)),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PatientsPage(userId: userId)),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DashboardPage(userId: userId)),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EmailTemplateScreen(userId: userId),
            ),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserPage(userId: userId)),
          );
        } else if (index == 5) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => WarehousePage(userId: userId)),
          );
        }

        onTap(index);
      },
    );
  }
}
