import 'package:flutter/material.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:medicineapp/appointments.dart';
import 'package:medicineapp/dashboard.dart';
import 'package:medicineapp/patientpage.dart';
import 'package:medicineapp/userspage.dart';


class NavigatorBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NavigatorBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.react,  // cool ripple/floating animation
      backgroundColor: Colors.grey.shade300,
      activeColor: Colors.black,
      color: Colors.grey.shade700,
      items: const [
        TabItem(icon: Icons.medical_services_outlined),
        TabItem(icon: Icons.contact_page),
        TabItem(icon: Icons.home),
        TabItem(icon: Icons.podcasts),
        TabItem(icon: Icons.group),
      ],
      initialActiveIndex: currentIndex,
      onTap: (index) {
        // Navigation logic
        if (index == 0) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentPage()));
          // showModalBottomSheet(
          //   context: context,
          //   isScrollControlled: true,
          //   shape: const RoundedRectangleBorder(
          //     borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          //   ),
          //   builder: (context) => DraggableScrollableSheet(
          //     expand: false,
          //     builder: (context, scrollController) =>
          //         AppointmentPage(scrollController: scrollController),
          //   ),
          // );
        } else if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PatientsPage()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardPage()));
        } else if (index == 4) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => UserPage()));
        }
        onTap(index);
      },
    );
  }
}
