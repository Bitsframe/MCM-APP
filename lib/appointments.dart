import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:intl/intl.dart';
import 'package:medicineapp/dashboard.dart';
import 'package:medicineapp/location.dart';
import 'package:medicineapp/main.dart';
import 'package:medicineapp/navigationbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentPage extends StatefulWidget {
  final String userId;
  const AppointmentPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  bool isLoading = true;
  String? permissionError;

  int _selectedIndex = 1;
  String selectedLocation = "Pasadena";
  List<String> services = [];
  String? selectedTreatment;
  final supabase = Supabase.instance.client;
  bool showApproved = true;
  List<dynamic> appointments = [];

  final List<String> days = ["MON", "Tue", "Wed", "Thr", "Fri", "Sat"];
  final List<String> dates = ["4", "5", "6", "7", "8", "9"];
  List<dynamic> allAppointments = []; // All fetched appointments

  Future<List<String>> fetchServices() async {
    final supabase = Supabase.instance.client;
    final data = await supabase.from('services').select('title');

    // `data` comes back as `List<dynamic>`; convert to List<String>
    return data.map<String>((item) => item['title'] as String).toList();
  }

  void showAppointmentDrawer(BuildContext context, int appointmentId) {
    showDialog(
      context: context,
      builder: (context) {
        return Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 0.7, // Drawer width (70% of screen)
            child: Material(
              color: Colors.white,
              child: FutureBuilder(
                future: Supabase.instance.client
                    .from('Appoinments') // adjust table name
                    .select()
                    .eq('id', appointmentId)
                    .single(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final appointment = snapshot.data as Map<String, dynamic>;

                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Appointment Details",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(height: 16),
                          infoLabel("First Name", appointment['first_name']),
                          infoLabel("Last Name", appointment['last_name']),
                          infoLabel("Email", appointment['email_address']),
                          infoLabel("Sex", appointment['sex']),
                          infoLabel("Service", appointment['service']),
                          infoLabel(
                            "Locations",
                            appointment['location_id'].toString(),
                          ),
                          infoLabel("Phone number", appointment['phone']),
                          infoLabel("Address", appointment['address']),
                          infoLabel(
                            "Date of Birth",
                            appointment['dob'] ?? 'N/A',
                          ),
                          infoLabel(
                            "Date Slot",
                            appointment['date_slot'] ?? 'N/A',
                          ),
                          infoLabel(
                            "Time Slot",
                            appointment['date_and_time'] ?? 'N/A',
                          ),
                          infoLabel(
                            "Created at",
                            DateFormat(
                              'MMMM dd, yyyy h:mm a',
                            ).format(DateTime.parse(appointment['created_at'])),
                          ),
                          const SizedBox(height: 20),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     // TODO: implement update or edit logic
                          //   },
                          //   child: const Text("Edit Appointment"),
                          // ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget infoLabel(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Location check before proceeding
    Future.delayed(Duration.zero, () {
      if (mounted) {
        if (AppData.selectedLocationId == null) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Location Required"),
              content: const Text("Please select a location first."),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DashboardPage(userId: widget.userId),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          checkAndFetchAppointments();
        }
      }
    });
  }
  // FirebaseMessaging.onMessage.listen((payload) {
  //   final notification = payload.notification;
  //   print(notification);
  //   if (notification != null) {
  //     // Show Snackbar
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(notification.title ?? 'Notification')),
  //     );

  //     // Show local notification
  //     flutterLocalNotificationsPlugin.show(
  //       notification.hashCode,
  //       notification.title ?? 'New Appointment',
  //       notification.body ?? 'You have booked an appointment!',
  //       const NotificationDetails(
  //         android: AndroidNotificationDetails(
  //           'appointment_channel_id',
  //           'Appointments',
  //           channelDescription: 'For appointment notifications',
  //           importance: Importance.max,
  //           priority: Priority.high,
  //           icon: '@mipmap/ic_launcher',
  //         ),
  //       ),
  //     );
  //   }
  // });

  //fetchServices();

  // Future<void> fetchAppointments() async {
  //   final response = await supabase
  //       .from('Appoinments')
  //       .select()
  //       .eq('isApproved', showApproved);
  //   print(response);
  //   setState(() {
  //     appointments = response;
  //   });
  // }
  Future<int?> getUserRoleId() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await Supabase.instance.client
        .from('profiles')
        .select('role_id')
        .eq('id', userId)
        .maybeSingle();

    return response?['role_id'];
  }

  Future<void> checkAndFetchAppointments() async {
    try {
      final roleId = await getUserRoleId(); // Get role id of the current user
      print(roleId);
      if (roleId == null) {
        setState(() {
          permissionError = "No role assigned.";
          isLoading = false;
        });
        return;
      }

      // Fetch permissions for the role
      final permissionList = await Supabase.instance.client
          .from('user_permissions')
          .select('permissions(permission)')
          .eq('roles', roleId)
          .eq('permissions.permission', 'Appointment'); // will return List

      print("Permission list: $permissionList");

      final hasPermission = permissionList.any(
        (row) => row['permissions']?['permission'] == 'Appointment',
      );

      if (hasPermission) {
        await fetchAppointments();
        setState(() => isLoading = false);
      } else {
        setState(() {
          permissionError = "You cannot use this module.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        permissionError = "Error occurred: $e";
        isLoading = false;
      });
    }
  }

  Future<void> fetchAppointments() async {
    print('appointment ${AppData.selectedLocationId}');

    final response = await supabase
        .from('Appoinments')
        .select('*, location:Locations (title)') // ← JOIN + alias
        .eq('isApproved', showApproved)
        .eq('location_id', AppData.selectedLocationId!);

    if (mounted) {
      setState(() {
        allAppointments = response;
        appointments = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (permissionError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 5), () {
          Navigator.pop(context); // Or pushReplacement if needed
        });
      });
      return Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.white,
        child: Center(
          child: Text(
            permissionError!,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back, color: Colors.black),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   title: Text(
      //     "Appointments",
      //     style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      //   ),
      //   actions: [
      //     Row(
      //       children: [
      //         GestureDetector(
      //           onTap: () async {
      //             final result = await showLocationBottomSheet(
      //               context,
      //               widget.userId,
      //             );
      //             fetchAppointments();
      //             if (result != null) {
      //               setState(() {
      //                 selectedLocation = AppData.selectedLocation!;
      //               });
      //               // Text(AppData.selectedLocation ?? 'No location selected');
      //             }
      //           },
      //           child: Row(
      //             children: [
      //               Text(
      //                 AppData.selectedLocation ?? 'No location selected',
      //                 style: TextStyle(
      //                   decoration: TextDecoration.underline,
      //                   fontSize: 12,
      //                   color: Colors.black87,
      //                 ),
      //                 overflow: TextOverflow.ellipsis,
      //               ),
      //               SizedBox(width: 8),
      //               Icon(Icons.location_pin, size: 24, color: Colors.black),
      //             ],
      //           ),
      //         ),
      //       ],
      //     ),
      //     //           ElevatedButton(
      //     //   onPressed: () {
      //     //     flutterLocalNotificationsPlugin.show(
      //     //       0,
      //     //       'Test Notification',
      //     //       'If you see this, local notifications work!',
      //     //       const NotificationDetails(
      //     //         android: AndroidNotificationDetails(
      //     //           'appointment_channel_id',
      //     //           'Appointments',
      //     //           channelDescription: 'For appointment notifications',
      //     //           importance: Importance.max,
      //     //           priority: Priority.high,
      //     //           icon: '@mipmap/ic_launcher', // Must exist
      //     //         ),
      //     //       ),
      //     //     );
      //     //   },
      //     //   child: Text("Test Notification"),
      //     // ),
      //     // TextButton.icon(
      //     //   onPressed: () async {
      //     //     final services = await fetchServices(); // ⬅️ wait for the list
      //     //     if (mounted) {
      //     //       showAddAppointmentBottomSheet(context, services);
      //     //       fetchAppointments();
      //     //     }
      //     //   },
      //     //   icon: Icon(Icons.add_circle_outline, color: Colors.blue),
      //     //   label: Text("Add New", style: TextStyle(color: Colors.blue)),
      //     // ),
      //   ],

      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Colors.black,
                      ),

                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text('Back', style: TextStyle(color: Colors.black)),

                    SizedBox(width: 145),

                    // TextButton.icon(
                    //   onPressed: () async {
                    //     final services =
                    //         await fetchServices(); // ⬅️ wait for the list
                    //     if (mounted) {
                    //       showAddAppointmentBottomSheet(context, services);
                    //       fetchAppointments();
                    //     }
                    //   },

                    //   icon: Icon(Icons.add_circle_outline, color: Colors.blue),
                    //   label: Text(
                    //     "Add New",
                    //     style: TextStyle(color: Colors.blue),
                    //   ),
                    // ),
                    TextButton.icon(
                      onPressed: () async {
                        final services = await fetchServices();
                        if (mounted) {
                          showAddAppointmentBottomSheet(context, services);
                          fetchAppointments();
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F6FF),
                        side: BorderSide(
                          color: Colors.blue, // or any dynamic condition
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: Icon(Icons.add_circle_outline, color: Colors.blue),
                      label: Text(
                        "Add New",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),

                SizedBox(width: 10),
                Padding(
                  padding: EdgeInsets.all(3),

                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final supabase = Supabase.instance.client;
                          final TextEditingController roleController =
                              TextEditingController();

                          // Step 1: Fetch permissions from the Permissions table
                          final response = await supabase
                              .from('permissions')
                              .select('permission');

                          if (response == null || response.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("No permissions found.")),
                            );
                            return;
                          }

                          // Step 2: Build dynamic permissions map
                          final Map<String, bool> permissions = {
                            for (var item in response)
                              item['permission'] as String: false,
                          };
                          Future<void> saveRoleWithPermissions({
                            required String roleName,
                            required Map<String, bool> permissionToggles,
                          }) async {
                            final supabase = Supabase.instance.client;

                            if (roleName.trim().isEmpty) {
                              throw Exception('Role name cannot be empty');
                            }

                            final roleInsert = await supabase
                                .from('roles')
                                .insert({'name': roleName.trim()})
                                .select('id')
                                .single();

                            final int roleId = roleInsert['id'] as int;
                            print('roleid: $roleId');

                            final enabledLabels = permissionToggles.entries
                                .where((entry) => entry.value) // ON only
                                .map((entry) => entry.key)
                                .toList();
                            print(enabledLabels);
                            if (enabledLabels.isEmpty) {
                              // No permissions checked – nothing more to do
                              return;
                            }

                            final permsQuery = await supabase
                                .from('permissions')
                                .select('id, permission')
                                .inFilter('permission', enabledLabels);

                            final Map<String, int> labelToId = {
                              for (final row in permsQuery)
                                row['permission'] as String: row['id'] as int,
                            };

                            final rowsToInsert = <Map<String, dynamic>>[];
                            for (final label in enabledLabels) {
                              final permId = labelToId[label];
                              if (permId != null) {
                                rowsToInsert.add({
                                  'roles': roleId,
                                  'permissions': permId,
                                });
                              }
                            }
                            print(rowsToInsert);
                            await supabase
                                .from('user_permissions')
                                .upsert(
                                  rowsToInsert,
                                  onConflict: 'roles,permissions',
                                  ignoreDuplicates: true,
                                );
                          }

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            builder: (context) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(
                                    context,
                                  ).viewInsets.bottom,
                                  left: 16,
                                  right: 16,
                                  top: 24,
                                ),
                                child: StatefulBuilder(
                                  builder: (context, setState) {
                                    return SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Center(
                                            child: Container(
                                              width: 40,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[400],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20),
                                          Text(
                                            "Add New Role",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          TextField(
                                            controller: roleController,
                                            decoration: InputDecoration(
                                              labelText: "User roles",
                                              hintText: "Enter user role",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            "Permissions",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Column(
                                            children: permissions.keys.map((
                                              key,
                                            ) {
                                              return SwitchListTile(
                                                title: Text(key),
                                                value: permissions[key]!,
                                                onChanged: (val) {
                                                  setState(() {
                                                    permissions[key] = val;
                                                  });
                                                },
                                              );
                                            }).toList(),
                                          ),
                                          SizedBox(height: 12),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                try {
                                                  await saveRoleWithPermissions(
                                                    roleName:
                                                        roleController.text,
                                                    permissionToggles:
                                                        permissions,
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Role saved successfully!',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                  Navigator.pop(context);
                                                } catch (e) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Error: \$e',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.black,
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 14,
                                                ),
                                              ),
                                              child: Text("Add Role"),
                                            ),
                                          ),
                                          SizedBox(height: 12),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },

                        child: Column(
                          children: [
                            // Icon(Icons.person_4_outlined, color: Colors.blue),
                            // SizedBox(width: 4),
                            // Text(
                            //   "Add New Role",
                            //   style: TextStyle(color: Colors.blue),
                            // ),
                          ],
                        ),
                      ),
                      SizedBox(width: 5, height: 4),
                      GestureDetector(
                        onTap: () async {
                          final TextEditingController usernameController =
                              TextEditingController();
                          final TextEditingController emailController =
                              TextEditingController();
                          final TextEditingController passwordController =
                              TextEditingController();
                          final TextEditingController locationController =
                              TextEditingController();
                          List<String> roles = [];
                          List<String> selectedLocations = [];
                          List<String> allLocations = [];
                          String? selectedRole;
                          final supabase = Supabase.instance.client;

                          final response = await supabase
                              .from('roles')
                              .select('name');

                          if (response != null) {
                            setState(() {
                              roles = response
                                  .map<String>((item) => item['name'] as String)
                                  .toList();
                            });
                          }
                          final locResponse = await supabase
                              .from('Locations')
                              .select('title');
                          allLocations = (locResponse as List<dynamic>)
                              .map((e) => e['title'].toString())
                              .toList();

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            builder: (context) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 20,
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom +
                                      20,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Container(
                                          width: 40,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16),

                                      Text(
                                        "Add New User",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 16),

                                      TextField(
                                        controller: usernameController,

                                        decoration: InputDecoration(
                                          hintText: "Username",

                                          fillColor: Colors.grey.shade100,
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 12),

                                      DropdownButtonFormField<String>(
                                        value: selectedRole,
                                        decoration: InputDecoration(
                                          hintText: "Select Role",
                                          border: OutlineInputBorder(),
                                        ),
                                        items: roles
                                            .map(
                                              (role) =>
                                                  DropdownMenuItem<String>(
                                                    value: role,
                                                    child: Text(role),
                                                  ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          selectedRole = value;
                                        },
                                      ),
                                      SizedBox(height: 12),

                                      // Email
                                      TextField(
                                        controller: emailController,
                                        decoration: InputDecoration(
                                          hintText: "Email",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 12),

                                      // Password
                                      TextField(
                                        controller: passwordController,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          hintText: "Password",
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      SizedBox(height: 12),

                                      TextField(
                                        controller: locationController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: "Select Locations",
                                          border: OutlineInputBorder(),
                                          suffixIcon: Icon(
                                            Icons.arrow_drop_down,
                                          ),
                                        ),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return StatefulBuilder(
                                                builder: (context, setDialogState) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      "Select Locations",
                                                    ),
                                                    content: SizedBox(
                                                      width: double.maxFinite,
                                                      child: ListView(
                                                        shrinkWrap: true,
                                                        children: allLocations.map((
                                                          location,
                                                        ) {
                                                          final isSelected =
                                                              selectedLocations
                                                                  .contains(
                                                                    location,
                                                                  );
                                                          return CheckboxListTile(
                                                            title: Text(
                                                              location,
                                                            ),
                                                            value: isSelected,
                                                            onChanged: (checked) {
                                                              setDialogState(() {
                                                                if (checked ==
                                                                    true) {
                                                                  selectedLocations
                                                                      .add(
                                                                        location,
                                                                      );
                                                                } else {
                                                                  selectedLocations
                                                                      .remove(
                                                                        location,
                                                                      );
                                                                }
                                                              });
                                                            },
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                        child: Text("Cancel"),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          setState(() {
                                                            locationController
                                                                    .text =
                                                                selectedLocations
                                                                    .join(", ");
                                                          });
                                                        },
                                                        child: Text("Done"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),

                                      SizedBox(height: 24),

                                      // Buttons
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text("Cancel"),
                                          ),
                                          SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final supabase =
                                                  Supabase.instance.client;

                                              if (emailController
                                                      .text
                                                      .isEmpty ||
                                                  passwordController
                                                      .text
                                                      .isEmpty ||
                                                  selectedRole == null) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Please fill all fields.",
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }

                                              try {
                                                print('email:$emailController');
                                                print(
                                                  'password:$passwordController',
                                                );
                                                print('working');

                                                final signUpRes = await supabase
                                                    .auth
                                                    .signUp(
                                                      email: emailController
                                                          .text
                                                          .trim(),
                                                      password:
                                                          passwordController
                                                              .text
                                                              .trim(),

                                                      data: {
                                                        'full_name':
                                                            usernameController
                                                                .text
                                                                .trim(),
                                                      },
                                                    );
                                                print(signUpRes);
                                                Future<int?>
                                                getRoleIdFromRoleName(
                                                  String roleName,
                                                ) async {
                                                  final supabase =
                                                      Supabase.instance.client;

                                                  final response =
                                                      await supabase
                                                          .from('roles')
                                                          .select('id')
                                                          .eq('name', roleName)
                                                          .maybeSingle();
                                                  print(response);
                                                  if (response != null &&
                                                      response['id'] != null) {
                                                    return response['id']
                                                        as int;
                                                  }

                                                  return null;
                                                }

                                                final roleId =
                                                    await getRoleIdFromRoleName(
                                                      selectedRole!,
                                                    );
                                                print(roleId);
                                                if (signUpRes.user != null) {
                                                  final uuid =
                                                      signUpRes.user!.id;
                                                  print(uuid);
                                                  final profileResponse =
                                                      await supabase
                                                          .from('profiles')
                                                          .insert({
                                                            'id': uuid,
                                                            'active': false,
                                                            'profile_pictures':
                                                                'https://vsvueqtgulraaczqnnvh.supabase.co/storage/v1/object/public/profile-pictures//user.png',
                                                            'full_name':
                                                                usernameController
                                                                    .text
                                                                    .trim(),
                                                            'role_id': roleId,
                                                            'email':
                                                                emailController
                                                                    .text
                                                                    .trim(),
                                                          });

                                                  if (profileResponse.error !=
                                                      null) {
                                                    print(
                                                      "Error inserting profile: ${profileResponse.error!.message}",
                                                    );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          "Failed to insert profile",
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  // 👇 Insert into user_locations here
                                                  final locationIds =
                                                      locationController.text
                                                          .split(
                                                            ',',
                                                          ) // or however your app stores multiple IDs
                                                          .map(
                                                            (id) =>
                                                                int.tryParse(
                                                                  id.trim(),
                                                                ),
                                                          )
                                                          .where(
                                                            (id) => id != null,
                                                          )
                                                          .toList();

                                                  final locationEntries =
                                                      locationIds
                                                          .map(
                                                            (locationId) => {
                                                              'profile_id':
                                                                  uuid,
                                                              'location_id':
                                                                  locationId,
                                                            },
                                                          )
                                                          .toList();

                                                  final userLocationsRes =
                                                      await supabase
                                                          .from(
                                                            'user_locations',
                                                          )
                                                          .insert(
                                                            locationEntries,
                                                          );

                                                  if (userLocationsRes.error !=
                                                      null) {
                                                    print(
                                                      "Error inserting user_locations: ${userLocationsRes.error!.message}",
                                                    );
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          "Failed to insert user locations",
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        "User added successfully.",
                                                      ),
                                                    ),
                                                  );
                                                  Navigator.pop(context);
                                                }
                                              } catch (e) {
                                                print("Error adding user: $e");
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Failed to add user.",
                                                    ),
                                                  ),
                                                );
                                              }

                                              print(
                                                "Username: ${usernameController.text}",
                                              );
                                              print("Role: $selectedRole");
                                              print(
                                                "Email: ${emailController.text}",
                                              );
                                              print(
                                                "Password: ${passwordController.text}",
                                              );
                                              print(
                                                "Location: ${locationController.text}",
                                              );

                                              Navigator.pop(context);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.black,
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 24,
                                                vertical: 14,
                                              ),
                                            ),
                                            child: Text("Add User"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },

                        child: Column(
                          children: [
                            // Icon(
                            //   Icons.add_circle_outline,
                            //   color: Colors.blue,
                            // ),
                            // SizedBox(width: 4),
                            // Text(
                            //   "Add New User",
                            //   style: TextStyle(color: Colors.blue),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(width: 20),
            Center(
              child: Text(
                "Appointments",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatusChip("Approved", showApproved, true),
                SizedBox(width: 12),
                _buildStatusChip("Need Approval", showApproved, false),
              ],
            ),
            SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        appointments = allAppointments.where((appointment) {
                          final name =
                              appointment['first_name']?.toLowerCase() ?? '';
                          return name.contains(value.toLowerCase());
                        }).toList();
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search by first name',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),

                  // Text(
                  //   days[index],
                  //   style: TextStyle(
                  //     color: isSelected ? Colors.white : Colors.black,
                  //   ),
                  // ),
                  // Text(
                  //   dates[index],
                  //   style: TextStyle(
                  //     color: isSelected ? Colors.white : Colors.black,
                  //   ),
                  // ),
                ],
              ),
            ),

            SizedBox(height: 13),
            ListView.builder(
              itemCount: appointments.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                String raw = appointment['date_and_time'] ?? '';
                final match = RegExp(r'\|\s*(.*)').firstMatch(raw);
                String displayDate = match != null ? match.group(1)! : raw;
                return Card(
                  color: const Color(0xFFF1F6FF),
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
                              "${appointment['first_name']} ${appointment['last_name']}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${appointment['service']}",
                              style: TextStyle(color: Colors.blue),
                            ),
                            Text("${appointment['sex']}"),
                          ],
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              margin: EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0057FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 6),

                                  Text(
                                    displayDate,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(12),
                                    backgroundColor: Colors.white,
                                    elevation: 1,
                                  ),

                                  child: const Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    showAppointmentDrawer(
                                      context,
                                      appointment['id'],
                                    );
                                  },
                                ),

                                //                                 IconButton(
                                //                                   icon: Icon(Icons.delete, color: Colors.red),
                                //                                   onPressed: () {
                                //                                     showDialog(
                                //                                       context: context,
                                //                                       builder: (context) => AlertDialog(
                                //                                         title: Text("Confirm Delete"),
                                //                                         content: Text(
                                //                                           "Are you sure you want to delete this appointment?",
                                //                                         ),
                                //                                         actions: [
                                //                                           TextButton(
                                //                                             onPressed: () =>
                                //                                                 Navigator.of(context).pop(),
                                //                                             child: Text("Cancel"),
                                //                                           ),
                                //                                           ElevatedButton(
                                //                                             onPressed: () async {
                                //                                               final id = appointment['id'];
                                //                                               await supabase
                                //                                                   .from('Appoinments')
                                //                                                   .delete()
                                //                                                   .eq('id', id);
                                //                                               Navigator.pop(context);
                                //                                               fetchAppointments();
                                //                                             },
                                //                                             style: ElevatedButton.styleFrom(
                                //                                               backgroundColor: Colors.black,
                                //                                               foregroundColor: Colors.white,
                                //                                             ),
                                //                                             child: Text("Delete"),
                                //                                           ),
                                //                                         ],
                                //                                       ),
                                //                                     );
                                //                                   },
                                //                                 ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(12),
                                    backgroundColor: Colors.white,
                                    elevation: 1,
                                  ),
                                  child: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () async {
                                    showEditAppointmentBottomSheet(
                                      context,
                                      appointment,
                                    );
                                    await fetchAppointments(); // This will run after the bottom sheet is closed
                                  },
                                ),

                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(12),
                                    backgroundColor: Colors.white,
                                    elevation: 1,
                                  ),
                                  child: Icon(Icons.delete, color: Colors.red),

                                  onPressed: () async {
                                    final List<dynamic> reasons = await Supabase
                                        .instance
                                        .client
                                        .from('refusal_reasons')
                                        .select('reason');

                                    String? selectedReason;

                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, setState) => AlertDialog(
                                            title: Text("Confirm Delete"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  "Are you sure you want to delete this appointment?",
                                                ),
                                                SizedBox(height: 16),
                                                DropdownButtonFormField<String>(
                                                  decoration: InputDecoration(
                                                    labelText: 'Select reason',
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                  items: reasons
                                                      .map(
                                                        (r) =>
                                                            DropdownMenuItem<
                                                              String
                                                            >(
                                                              value:
                                                                  r['reason'],
                                                              child: Text(
                                                                r['reason'],
                                                              ),
                                                            ),
                                                      )
                                                      .toList(),
                                                  value: selectedReason,
                                                  onChanged: (val) => setState(
                                                    () => selectedReason = val,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                child: Text(
                                                  "Cancel",
                                                  style: TextStyle(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed:
                                                    selectedReason == null
                                                    ? null
                                                    : () async {
                                                        final id =
                                                            appointment['id'];
                                                        final name =
                                                            appointment['first_name'] ??
                                                            'User';
                                                        final email =
                                                            appointment['email_address'];
                                                        final service =
                                                            appointment['service'] ??
                                                            'the service';

                                                        // 1. Delete appointment
                                                        await Supabase
                                                            .instance
                                                            .client
                                                            .from('Appoinments')
                                                            .delete()
                                                            .eq('id', id);

                                                        // 2. Send email with reason
                                                        final emailResponse =
                                                            await Supabase
                                                                .instance
                                                                .client
                                                                .functions
                                                                .invoke(
                                                                  'send-email',
                                                                  body: {
                                                                    "to": email,
                                                                    "subject":
                                                                        "Appointment Cancelled",
                                                                    "html":
                                                                        """
                              <p>Hi $name,</p>
                              <p>Your appointment for <strong>$service</strong> has been cancelled.</p>
                              <p><strong>Reason:</strong> $selectedReason</p>
                              <p>If you have any questions, feel free to contact us.</p>
                              <p>— The Clinic Team</p>
                            """,
                                                                  },
                                                                );

                                                        print(
                                                          "📧 Email sent: ${emailResponse.data}",
                                                        );

                                                        Navigator.pop(context);
                                                        fetchAppointments();
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                    0xFFD0021B,
                                                  ),

                                                  foregroundColor: Colors.white,
                                                ),

                                                child: Text("Delete"),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 3),
                            if (!(appointment['isApproved'] ?? false))
                              Align(
                                alignment: Alignment.bottomRight,

                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await supabase
                                            .from('Appoinments')
                                            .update({'isApproved': true})
                                            .eq('id', appointment['id']);

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Appointment approved.",
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );

                                        // Refresh list after approval
                                        fetchAppointments();
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Failed to approve appointment.",
                                            ),
                                            backgroundColor: const Color(
                                              0xFFD0021B,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 6,
                                      ),
                                    ),
                                    child: Text("Approve"),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigatorBar(
        userId: widget.userId,

        currentIndex: 1,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildStatusChip(String label, bool current, bool match) {
    final isSelected = current == match;
    return GestureDetector(
      onTap: () {
        setState(() {
          showApproved = match;
          fetchAppointments();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F6FF) : Colors.grey.shade200,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

void showAddAppointmentBottomSheet(
  BuildContext context,
  List<String> services,
) {
  final supabase = Supabase.instance.client;
  print('bottom wali$services');
  String? visitType;
  String? patientType;
  String? selectedTreatment;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController zipcodeController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String? gender;

  String? selectedTimeSlot;
  String selectedState = "Alaska";
  String locationName = "Clinica San Miguel Fondren";
  Future<List<String>>? timeSlotsFuture;
  bool? inOfficePatient = false;
  bool? newPatient = false;

  final List<String> states = [
    "Alabama ",
    "Alaska",
    "Arizona ",
    "Arkansas ",
    "California ",
    "Colorado ",
    "Connecticut ",
    "Delaware ",
    "Florida ",
    "Georgia ",
    "Hawaii ",
    "Idaho ",
    "Illinois",
    "Indiana ",
    "Iowa ",
    "Kansas ",
    "Kentucky ",
    "Louisiana ",
    "Maine",
    "Maryland ",
    "Massachusetts",
    "Michigan ",
    "Minnesota ",
    "Mississippi ",
    "Missouri ",
    "Montana ",
    "Nebraska ",
    "Nevada ",
    "New Hampshire ",
    "New Jersey ",
    "New Mexico ",
    "New York ",
    "North Carolina ",
    "North Dakota ",
    "Ohio ",
    "Oklahoma ",
    "Oregon ",
    "Pennsylvania ",
    "Rhode Island",
    "South Carolina ",
    "South Dakota ",
    "Tennessee ",
    "Texas ",
    "Utah ",
    "Vermont ",
    "Virginia ",
    "Washington ",
    "West Virginia ",
    "Wisconsin ",
    "Wyoming ",
  ];

  Future<List<String>> fetchTodayTimeSlots(int locationId) async {
    final supabase = Supabase.instance.client;

    final Map<int, String> weekdayToColumn = {
      DateTime.monday: 'mon_timing',
      DateTime.tuesday: 'tuesday_timing',
      DateTime.wednesday: 'wednesday_timing',
      DateTime.thursday: 'thursday_timing',
      DateTime.friday: 'friday_timing',
      DateTime.saturday: 'saturday_timing',
      DateTime.sunday: 'sunday_timing',
    };

    final column = weekdayToColumn[DateTime.now().weekday]!;
    final timingRow = await supabase
        .from('Locations')
        .select(column)
        .eq('id', locationId)
        .single();

    final raw = timingRow[column] as String?;
    print('Raw timing string: "$raw"');

    if (raw == null ||
        raw.toLowerCase().contains('closed') ||
        !raw.contains('-')) {
      return [];
    }

    // Normalize and fix spacing/casing
    String normalizeTime(String input) {
      return input
          .trim()
          .replaceAll(
            RegExp(r'[^\x20-\x7E]'),
            '',
          ) // Remove non-visible characters
          .replaceAll(RegExp(r'\s+'), ' ') // Collapse whitespace
          .toUpperCase(); // Force AM/PM to be uppercase
    }

    try {
      final parts = raw.split('-');
      final startStr = normalizeTime(parts[0]);
      final endStr = normalizeTime(parts[1]);
      print('Normalized Start: "$startStr", End: "$endStr"');

      final timeFmt = DateFormat('h:mm a');
      final now = DateTime.now();

      DateTime start = timeFmt.parseLoose(startStr);
      DateTime end = timeFmt.parseLoose(endStr);

      // Fix the date context
      start = DateTime(now.year, now.month, now.day, start.hour, start.minute);
      end = DateTime(now.year, now.month, now.day, end.hour, end.minute);

      final List<String> timeSlots = [];
      while (start.isBefore(end)) {
        timeSlots.add(timeFmt.format(start));
        start = start.add(const Duration(minutes: 30));
      }

      print('✅ Time slots generated: $timeSlots');
      return timeSlots;
    } catch (e) {
      print('❌ Time parsing failed for "$raw". Error: $e');
      return [];
    }
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          if (timeSlotsFuture == null && AppData.selectedLocationId != null) {
            timeSlotsFuture = fetchTodayTimeSlots(AppData.selectedLocationId!);
            print('yes');
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Add an Appointment",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),

                  SizedBox(height: 4),
                  Text("Fill all the fields to continue"),
                  SizedBox(height: 16),

                  // Type of Visit and Patient Status
                  Text(
                    "Type of visit & Patient status",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 10,
                          children: [
                            ChoiceChip(
                              selectedColor: const Color(0xFF0057FF),
                              label: Text(
                                "Office visit",
                                style: TextStyle(
                                  color: visitType == "office"
                                      ? Colors.white
                                      : const Color(0xFF0057FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: visitType == "office",
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFF0057FF),
                              ),
                              onSelected: (_) =>
                                  setModalState(() => visitType = "office"),
                            ),
                            ChoiceChip(
                              selectedColor: const Color(0xFF0057FF),
                              label: Text(
                                "Virtual visit",
                                style: TextStyle(
                                  color: visitType == "virtual"
                                      ? Colors.white
                                      : const Color(0xFF0057FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: visitType == "virtual",
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFF0057FF),
                              ),
                              onSelected: (_) =>
                                  setModalState(() => visitType = "virtual"),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Wrap(
                          spacing: 10,
                          children: [
                            ChoiceChip(
                              selectedColor: const Color(0xFF0057FF),
                              label: Text(
                                "New",
                                style: TextStyle(
                                  color: patientType == "new"
                                      ? Colors.white
                                      : const Color(0xFF0057FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFF0057FF),
                              ),
                              selected: patientType == "new",
                              onSelected: (_) =>
                                  setModalState(() => patientType = "new"),
                            ),
                            ChoiceChip(
                              selectedColor: const Color(0xFF0057FF),
                              label: Text(
                                "Coming back",
                                style: TextStyle(
                                  color: patientType == "returning"
                                      ? Colors.white
                                      : const Color(0xFF0057FF),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFF0057FF),
                              ),
                              selected: patientType == "returning",
                              onSelected: (_) => setModalState(
                                () => patientType = "returning",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  //               Row(
                  //                 children: [
                  //                   Expanded(
                  //                     child: Wrap(
                  //                       spacing: 10,
                  //                       children: [
                  //                         ChoiceChip(
                  //                            selectedColor:  const Color(0xFF0057FF),
                  //                           label: Text("Office visit",style: TextStyle(
                  //   color: isSelected ? Colors.white : Colors.grey[800], // white when selected
                  //   fontWeight: FontWeight.bold,
                  // ),),
                  //                           selected: visitType == "office",
                  //                            side: BorderSide(
                  //                             width: 1,
                  //                             color: const Color(0xFF0057FF),
                  //                           ),
                  //                           onSelected: (_) =>
                  //                               setModalState(() => visitType = "office"),
                  //                         ),
                  //                         ChoiceChip(
                  //                            selectedColor:  const Color(0xFF0057FF),
                  //                           label: Text("Virtual visit",style: TextStyle(
                  //   color: isSelected ? Colors.white : Colors.grey[800], // white when selected
                  //   fontWeight: FontWeight.bold,
                  // ),),
                  //                           selected: visitType == "virtual",
                  //                            side: BorderSide(
                  //                             width: 1,
                  //                             color: const Color(0xFF0057FF),
                  //                           ),
                  //                           onSelected: (_) =>
                  //                               setModalState(() => visitType = "virtual"),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),

                  //                   SizedBox(width: 12),
                  //                   Expanded(
                  //                     child: Wrap(
                  //                       spacing: 10,
                  //                       children: [
                  //                         ChoiceChip(
                  //                           selectedColor:  const Color(0xFF0057FF),
                  //                           label: Text("New",style: TextStyle(
                  //   color: isSelected ? Colors.white : Colors.grey[800], // white when selected
                  //   fontWeight: FontWeight.bold,
                  // ),),
                  //                           side: BorderSide(
                  //                             width: 1,
                  //                             color: const Color(0xFF0057FF),
                  //                           ),
                  //                           selected: patientType == "new",
                  //                           onSelected: (_) =>
                  //                               setModalState(() => patientType = "new"),
                  //                         ),
                  //                         ChoiceChip(
                  //                            selectedColor:  const Color(0xFF0057FF),
                  //                           label: Text("Coming back",style: TextStyle(
                  //   color: isSelected ? Colors.white : Colors.grey[800], // white when selected
                  //   fontWeight: FontWeight.bold,
                  // ),),
                  //                           side: BorderSide(
                  //                             width: 1,
                  //                             color: const Color(0xFF0057FF),
                  //                           ),
                  //                           selected: patientType == "returning",
                  //                           onSelected: (_) => setModalState(
                  //                             () => patientType = "returning",
                  //                           ),
                  //                         ),
                  //                       ],
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  SizedBox(height: 16),

                  // Name Fields
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: firstNameController,
                          decoration: InputDecoration(
                            labelText: "First Name *",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: lastNameController,
                          decoration: InputDecoration(
                            labelText: "Last Name *",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Contact Fields
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Email Address *",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),

                  // DOB
                  TextField(
                    controller: dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Date of Birth",
                      hintText: "mm/dd/yyyy",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                             colorScheme: ColorScheme.light(
                                primary: Color(
                                  0xFF0057FF,
                                ), // blue header & button
                                onPrimary: Colors.white, // white text on header
                                onSurface: Colors.black, // black text for body
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF0057FF), // Button text color
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setModalState(() {
                          dobController.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                  SizedBox(height: 16),

                  // Gender
                  Text("Sex *", style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 10,

                    children: ["male", "female", "others"].map((val) {
                      return ChoiceChip(
                        selectedColor: const Color(0xFF0057FF),
                        side: const BorderSide(
                          width: 1,
                          color: Color(0xFF0057FF),
                        ),
                        label: Text(
                          val,
                          style: TextStyle(
                            color: gender == val
                                ? Colors.white
                                : const Color(0xFF0057FF),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: gender == val,
                        onSelected: (_) => setModalState(() => gender = val),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),

                  // State & Zipcode
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedState,
                          items: states
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (val) => setModalState(
                            () => selectedState = val ?? states.first,
                          ),
                          decoration: InputDecoration(
                            labelText: "State",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: zipcodeController,
                          decoration: InputDecoration(
                            labelText: "Zipcode",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Address
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: "Street Address",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Service
                  Text(
                    "Treatment *",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      hintText: "Select treatment type *",
                      border: OutlineInputBorder(),
                      fillColor: Colors.grey.shade100,
                    ),
                    value: selectedTreatment,
                    items: services
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) => selectedTreatment = value,
                  ),
                  SizedBox(height: 16),

                  // Appointment Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: "Date *",
                            suffixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                               builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                               colorScheme: ColorScheme.light(
                                primary: Color(
                                  0xFF0057FF,
                                ), // blue header & button
                                onPrimary: Colors.white, // white text on header
                                onSurface: Colors.black, // black text for body
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF0057FF), // Button text color
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      
                            );
                            if (picked != null) {
                              setModalState(() {
                                dateController.text =
                                    "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: FutureBuilder<List<String>>(
                          future: timeSlotsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return DropdownButtonFormField<String>(
                                items: [],
                                onChanged: null,
                                decoration: const InputDecoration(
                                  labelText: "Time *",
                                  border: OutlineInputBorder(),
                                ),
                                hint: const Text("Loading..."),
                              );
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return DropdownButtonFormField<String>(
                                items: [],
                                onChanged: null,
                                decoration: const InputDecoration(
                                  labelText: "Time *",
                                  border: OutlineInputBorder(),
                                ),
                                hint: const Text("No slots available"),
                              );
                            }

                            final slots = snapshot.data!;

                            return DropdownButtonFormField<String>(
                              value: selectedTimeSlot, // current selected value
                              items: slots
                                  .map(
                                    (slot) => DropdownMenuItem(
                                      value: slot,
                                      child: Text(slot),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setModalState(() {
                                  selectedTimeSlot = val;
                                });
                                print(
                                  "⏰ Time slot selected: $val",
                                ); // Debug print
                              },
                              decoration: const InputDecoration(
                                labelText: "Time *",
                                border: OutlineInputBorder(),
                              ),
                            );
                          },
                        ),
                      ),

                      //   Expanded(
                      //     child: DropdownButtonFormField<String>(
                      //       onTap: () => fetchTodayTimeSlots(AppData.selectedLocationId!),
                      //       value: selectedTimeSlot,
                      //       items: timeSlots
                      //           .map(
                      //             (t) =>
                      //                 DropdownMenuItem(value: t, child: Text(t)),
                      //           )
                      //           .toList(),
                      //       onChanged: (val) =>
                      //           setModalState(() => selectedTimeSlot = val),
                      //       decoration: InputDecoration(
                      //         labelText: "Time *",
                      //         border: OutlineInputBorder(),
                      //       ),
                      //     ),
                      //   ),
                      // ],
                    ],
                  ),
                  SizedBox(height: 16),

                  SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: const Color(0xFF0057FF)),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if ([
                            firstNameController.text,
                            lastNameController.text,
                            emailController.text,

                            dateController.text,
                            selectedTimeSlot,
                            gender,
                            selectedTreatment,
                          ].any(
                            (e) => e == null || (e is String && e.isEmpty),
                          )) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please fill the Required fields.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          try {
                            // Optional: You can still dynamically get location_id from the 'locations' table
                            // final locationResponse = await supabase
                            //     .from('locations')
                            //     .select('id')
                            //     .eq('name', locationName)
                            //     .maybeSingle();
                            // final locationId = locationResponse?['id'];
                            final rawDate = DateFormat('dd-MM-yyyy').format(
                              DateFormat(
                                'yyyy-MM-dd',
                              ).parse(dateController.text.trim()),
                            );
                            final userId =
                                Supabase.instance.client.auth.currentUser!.id;

                            final dateAndTime =
                                "$rawDate - ${selectedTimeSlot}";
                            final insertData = {
                              'first_name': firstNameController.text.trim(),
                              'last_name': lastNameController.text.trim(),
                              'email_address': emailController.text.trim(),
                              'phone': phoneController.text.trim(),
                              'dob': dobController.text.trim(),
                              'sex': gender,
                              // 'state': selectedState,
                              // 'zipcode': zipcodeController.text.trim(),
                              'address': addressController.text.trim(),
                              'service': selectedTreatment,
                              'date_and_time': dateAndTime,
                              'user_id': userId,
                              'in_office_patient': true,
                              'new_patient': true,
                              'isApproved': false,
                              'text_opt': true,
                              'email_opt': true,
                              'location_id': AppData
                                  .selectedLocationId, // You said this is correct
                              // 'type_of_visit': visitType,
                              // 'patient_status': patientType,
                            };

                            final response = await supabase
                                .from('Appoinments')
                                .insert(insertData);
                            print(response);

                            if (response == null) {
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Appointment added successfully.",
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              final userId =
                                  Supabase.instance.client.auth.currentUser!.id;

                              // 1. Fetch the current user's `notify` setting from the `profiles` table
                              final profileResponse = await Supabase
                                  .instance
                                  .client
                                  .from('profiles')
                                  .select('notify')
                                  .eq('id', userId)
                                  .maybeSingle();
                              print(profileResponse);

                              final shouldNotify =
                                  profileResponse?['notify'] == true;
                              print(shouldNotify);
                              if (response == null && shouldNotify) {
                                flutterLocalNotificationsPlugin.show(
                                  0,
                                  'Appointment Booked',
                                  "Dear ${firstNameController.text.trim()},Your appointment has been successfully booked!",
                                  const NotificationDetails(
                                    android: AndroidNotificationDetails(
                                      'appointment_channel_id',
                                      'Appointments',
                                      channelDescription:
                                          'For appointment notifications',
                                      importance: Importance.max,
                                      priority: Priority.high,
                                      icon: '@mipmap/ic_launcher', // Must exist
                                      actions: <AndroidNotificationAction>[
                                        AndroidNotificationAction(
                                          'approve_action',
                                          'Approve',
                                          showsUserInterface: true,
                                          cancelNotification: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }
                            ;
                          } catch (e) {
                            print("Supabase insert error: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to add appointment."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          "Add appointment",
                          style: TextStyle(color: const Color(0xFF0057FF)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void showEditAppointmentBottomSheet(
  BuildContext context,
  Map<String, dynamic> appointment,
) {
  final supabase = Supabase.instance.client;

  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  

  final List<String> timeSlots = [
    "09:00 AM",
    "9:30 AM",
    "10:00 AM",
    "10:30 AM",
    "11:00 AM",
    "11:30 AM",
    "12:00 PM",
    "12:30 PM",
    "1:00 PM",
    "1:30 PM",
    "2:00 PM",
    "2:30 PM",
    "3:00 PM",
    "3:30 PM",
    "4:00 PM",
    "4:30 PM",
    "5:00 PM",
    "5:30 PM",
    "6:00 PM",
    "6:30 PM",
    "7:00 PM",
    "7:30 PM",
    "8:00 PM",
    "8:30 PM",
    "9:00 PM",
    "9:30 PM",
    "10:00 PM",
    "10:30 PM",
    "11:00 PM",
    "11:30 PM",
    "12:00 PM",
  ];
  String? initialTimeValue = timeSlots.contains(timeController.text)
    ? timeController.text
    : null;

  final originalDateTime = appointment['date_and_time'] ?? '';

  if (originalDateTime.toString().contains(' - ')) {
    final split = originalDateTime.toString().split(' - ');
    dateController.text = split[0].trim();
    timeController.text = split[1].trim();
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Edit Appointment",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 25),
                  const Text(
                    'New Date',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),

                  /// Date Field
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    cursorColor: const Color(0xFF0057FF),
                    decoration: InputDecoration(
                      labelText: "New Date",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Color(
                                  0xFF0057FF,
                                ), // blue header & button
                                onPrimary: Colors.white, // white text on header
                                onSurface: Colors.black, // black text for body
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor: Color(
                                    0xFF0057FF,
                                  ), // Cancel & OK text
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (picked != null) {
                        final formatted = DateFormat(
                          'yyyy-MM-dd',
                        ).format(picked);
                        setModalState(() => dateController.text = formatted);
                      }
                    },
                  ),
                  SizedBox(height: 12),
                  const Text(
                    'New Time',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),

                  /// Time Dropdown
                  DropdownButtonFormField<String>(
                    value: initialTimeValue,
                        
                    items: timeSlots
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) =>
                        setModalState(() => timeController.text = val ?? ''),
                    decoration: InputDecoration(
                      labelText: "New Time",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  /// Submit Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: const Color(0xFF0057FF)),
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final newDate = dateController.text.trim();
                          final newTime = timeController.text.trim();
                          if (newDate.isEmpty || newTime.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please select both date and time.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final newDateTime = "$newDate - $newTime";

                          try {
                            await supabase
                                .from('Appoinments')
                                .update({'date_and_time': newDateTime})
                                .eq('id', appointment['id']);
                            // 2. Send Email Notification
                            final name = appointment['first_name'] ?? 'Patient';
                            final email = appointment['email_address'];
                            final service =
                                appointment['service'] ?? 'your service';

                            final emailResponse = await supabase.functions
                                .invoke(
                                  'send-email',
                                  body: {
                                    "to": email,
                                    "subject": "Updated Appointment Schedule",
                                    "html":
                                        """
          <p>Hi $name,</p>
          <p>Your appointment for <strong>$service</strong> has been rescheduled.</p>
          <p><strong>New Date & Time:</strong> $newDateTime</p>
          <p>If you have any questions, please contact us.</p>
          <p>— The Clinic Team</p>
        """,
                                  },
                                );

                            print("📧 Email sent: ${emailResponse.data}");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Appointment updated successfully.",
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            print("Error updating appointment: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Failed to update appointment."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          "Update Appointment",
                          style: TextStyle(color: const Color(0xFF0057FF)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
