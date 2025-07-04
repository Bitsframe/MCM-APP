import 'package:flutter/material.dart';
import 'package:medicineapp/dashboard.dart';
import 'package:medicineapp/patientpage.dart';

class AppointmentsPage extends StatelessWidget {

  final List<String> days = ["MON", "Tue", "Wed", "Thr", "Fri", "Sat"];
  final List<String> dates = ["4", "5", "6", "7", "8", "9"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Image.asset('assets/images/medicineicon.png', height: 50),
              //     // Row(
              //     //   children: [
              //     //     Text(
              //     //       "Pasadena",
              //     //       style: TextStyle(decoration: TextDecoration.underline),
              //     //     ),
              //     //     SizedBox(width: 10),
              //     //     Icon(Icons.location_pin, size: 30),
              //     //     SizedBox(width: 10),
              //     //     Icon(Icons.person, size: 30),
              //     //   ],
              //     // ),
              //   ],
              // ),
              // SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DashboardPage(),
                        ),
                      );
                    },
                    child: Icon(Icons.arrow_back, size: 28),
                  ),
                  Text(
                    "Appointments",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.blue),
                        SizedBox(width: 4),
                        Text("Add New", style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF37474F),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      "Approved",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text("Need Approval"),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    "Select Date",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: days.length,
                  itemBuilder: (context, index) {
                    bool isSelected = index == 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  days[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Text(
                                  dates[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  scrollDirection:Axis.vertical,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Color(0xFFEAF4FB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Mr. Jack sparrow",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Ultra Sound",
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Text("Male"),
                              ],
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF37474F),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 6),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "22-Feb-2025",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            "5:00 PM",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {},
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PatientsPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey.shade300,
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              icon: Icon(Icons.medical_services_outlined),
              onPressed: () => AppointmentsPage(),
            ),
            label: "",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.contact_page), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.home, size: 34), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.podcasts), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: ""),
        ],
      ),
    );
  }
}
