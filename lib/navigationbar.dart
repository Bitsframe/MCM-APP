// import 'package:flutter/material.dart';
// import 'package:convex_bottom_bar/convex_bottom_bar.dart';
// import 'package:medicineapp/appointments.dart';
// import 'package:medicineapp/dashboard.dart';
// import 'package:medicineapp/emailbroadcast.dart';
// import 'package:medicineapp/patientpage.dart';
// import 'package:medicineapp/userspage.dart';
// import 'package:medicineapp/warehouse.dart';

// class NavigatorBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;
//   final String userId;

//   const NavigatorBar({
//     Key? key,
//     required this.currentIndex,
//     required this.onTap,
//     required this.userId,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ConvexAppBar(
//       style: TabStyle.react, // cool ripple/floating animation
//       backgroundColor: Colors.grey.shade300,
//       activeColor: Colors.black,
//       color: Colors.grey.shade700,
//       items: const [
//         TabItem(icon: Icons.medical_services_outlined),
//         TabItem(icon: Icons.contact_page),
//         TabItem(icon: Icons.home),
//         TabItem(icon: Icons.podcasts),
//         TabItem(icon: Icons.group),
//          TabItem(icon: Icons.inventory),
//       ],
//       initialActiveIndex: currentIndex,
//       onTap: (index) {
//         // Navigation logic
//         if (index == 0) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => AppointmentPage(userId: userId)),
//           );
//         } else if (index == 1) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => PatientsPage(userId: userId)),
//           );
//         } else if (index == 2) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => DashboardPage(userId: userId)),
//           );
//         } else if (index == 3) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => EmailTemplateScreen(userId: userId),
//             ),
//           );
//         } else if (index == 4) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => UserPage(userId: userId)),
//           );
//         } else if (index == 5) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => WarehousePage(userId: userId)),
//           );
//         }

//         onTap(index);
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
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
    final List<IconData> icons = [
      Icons.home,
      Icons.medical_services_outlined,
      Icons.contact_page,
     
      Icons.podcasts,
      Icons.group,
      Icons.inventory,
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final bool isActive = index == currentIndex;
          return GestureDetector(
            onTap: () {
              if (index == 0) {
                Navigator.push(
                  context,
                   MaterialPageRoute(builder: (_) => DashboardPage(userId: userId)),
                
                );
              } else if (index == 1) {
                Navigator.push(
                  context,
                    MaterialPageRoute(builder: (_) => AppointmentPage(userId: userId)),
                 
                );
              } else if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PatientsPage(userId: userId)),
                );
              } else if (index == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EmailTemplateScreen(userId: userId)),
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
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: isActive
                  ? BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    )
                  : null,
              child: Icon(
                icons[index],
                color: isActive ? const Color(0xFF0057FF) : Colors.grey,
                size: 28,
              ),
            ),
          );
        }),
      ),
    );
  }
}
