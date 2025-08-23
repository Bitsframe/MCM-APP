import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medicineapp/location.dart';
import 'package:medicineapp/loginpage.dart';
import 'package:medicineapp/main.dart';
import 'package:medicineapp/navigationbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  final String userId;

  const DashboardPage({Key? key, required this.userId}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  String selectedLocation = "Pasadena";
  String userName = "Mack";
  bool isLoading = true;
  num totalSalesAmount = 0;
  int appointmentsCount = 0;
  // New list to store selected location IDs
  List<int> selectedLocationIds = [];
  int patientsCount = 0;
  int totalInventoryQuantity = 0;
  DateTime? lastUpdatedTime;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    fetchPatientsCount();
  }

  String getTimeAgoText() {
    if (lastUpdatedTime == null) return "refresh".tr();

    final now = DateTime.now();
    final difference = now.difference(lastUpdatedTime!);

    if (difference.inMinutes < 1) return "just_now".tr();
    if (difference.inMinutes < 10) return "${difference.inMinutes} mins ago";
    if (difference.inHours < 24) return "${difference.inHours} hours ago";

    return "${difference.inDays} days ago";
  }

  Future<void> fetchTotalSalesAmount() async {
    try {
      final supabase = Supabase.instance.client;

      // Step 1: Get patient_ids based on selected location_ids
      final patientResponse = await supabase
          .from('allpatients')
          .select('id, locationid')
          .inFilter('locationid', selectedLocationIds);

      if (patientResponse == null || patientResponse.isEmpty) {
        setState(() {
          totalSalesAmount = 0;
        });
        return;
      }

      final List<int> patientIds = patientResponse
          .map<int>((item) => item['id'] as int)
          .toList();

      // Step 2: Get orders based on patient_ids
      final orderResponse = await supabase
          .from('orders')
          .select('paid_amount, patient_id')
          .inFilter('patient_id', patientIds);

      // Step 3: Sum the paid_amounts
      num total = 0;
      for (final order in orderResponse) {
        final amount = order['paid_amount'];
        if (amount is num) {
          total += amount;
        }
      }

      setState(() {
        totalSalesAmount = total;
      });
    } catch (e) {
      print('Error fetching total sales: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch total sales')));
    }
  }

  Future<void> fetchPatientsCount() async {
    if (selectedLocationIds.isEmpty) {
      setState(() {
        patientsCount = 0;
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('allpatients') // replace with actual table name if different
          .select('id')
          .inFilter('locationid', selectedLocationIds);

      if (response != null) {
        setState(() {
          patientsCount = response.length;
        });
      }
    } catch (e) {
      print('Error fetching patients count: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to fetch patients count')));
    }
  }

  Future<void> _fetchUserProfile() async {
    final response = await Supabase.instance.client
        .from('profiles')
        .select('full_name')
        .eq('id', widget.userId)
        .single();

    if (response != null) {
      setState(() {
        userName = response['full_name'] ?? 'Mack';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to load user data')));
    }
  }

  Future<void> fetchAppointmentsCount() async {
    if (selectedLocationIds.isEmpty) {
      setState(() {
        appointmentsCount = 0;
      });
      return;
    }

    try {
      print('selected locations: $selectedLocationIds');
      final response = await Supabase.instance.client
          .from('Appoinments') // or whatever your table is called
          .select('id')
          .inFilter('location_id', selectedLocationIds);

      if (response != null) {
        setState(() {
          appointmentsCount = response.length;
        });
      }
    } catch (e) {
      print('Error fetching appointments count: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch appointments count')),
      );
    }
  }

  Future<void> fetchInventoryQuantity() async {
    if (selectedLocationIds.isEmpty) {
      setState(() {
        totalInventoryQuantity = 0;
      });
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('inventory') // Replace with your actual inventory table name
          .select('quantity, location_id') // Adjust field names if needed
          .inFilter('location_id', selectedLocationIds);

      if (response != null) {
        int total = 0;
        for (final item in response) {
          final quantity = item['quantity'];

          // Ensure it's a number and cast it safely
          if (quantity is num) {
            total += quantity.toInt();
          }
        }
        setState(() {
          totalInventoryQuantity = total;
        });
      }
    } catch (e) {
      print('Error fetching inventory: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch inventory quantity')),
      );
    }
  }

  void _onTileTapped(String type) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$type clicked!")));
  }

  Future<void> _refreshDashboardData() async {
    setState(() => isLoading = true);

    await fetchAppointmentsCount();
    await fetchPatientsCount();
    await fetchInventoryQuantity();
    await fetchTotalSalesAmount();

    setState(() {
      lastUpdatedTime = DateTime.now();
      isLoading = false;
    });
  }

  String formatNumberCompact(num number) {
    if (number >= 1000000000) {
      return "${(number / 1000000000).toStringAsFixed(1)}B";
    } else if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(1)}M";
    } else if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}K";
    } else {
      return number.toStringAsFixed(0);
    }
  }

  void _showProfileOptions(BuildContext context) {
    bool notificationsEnabled = false;
    bool isLoaded = false;
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();

    void _showChangePasswordDialog(BuildContext context) {
      final currentPasswordController = TextEditingController();
      final newPasswordController = TextEditingController();

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Change Password',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Current Password'),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: const Color(0xFF0057FF)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = Supabase.instance.client.auth.currentUser?.email;
                final currentPassword = currentPasswordController.text.trim();
                final newPassword = newPasswordController.text.trim();

                if (email == null ||
                    currentPassword.isEmpty ||
                    newPassword.isEmpty) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill in all fields.")),
                  );
                  return;
                }

                try {
                  // Re-authenticate
                  final res = await Supabase.instance.client.auth
                      .signInWithPassword(
                        email: email,
                        password: currentPassword,
                      );

                  if (res.user == null) {
                    throw Exception("Incorrect current password.");
                  }

                  // Update password
                  final updateRes = await Supabase.instance.client.auth
                      .updateUser(UserAttributes(password: newPassword));

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Password changed successfully.")),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },
              child: Text(
                'Save',
                style: TextStyle(color: const Color(0xFF0057FF)),
              ),
            ),
          ],
        ),
      );
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _loadPreference() async {
              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId == null) return;

              final response = await Supabase.instance.client
                  .from('profiles')
                  .select('notify')
                  .eq('id', userId)
                  .maybeSingle();

              print("Supabase notify response: $response");

              if (response != null && response['notify'] != null) {
                setState(() {
                  notificationsEnabled = response['notify'] as bool;
                  isLoaded = true;
                });
              }
            }

            Future<void> _updatePreference(bool value) async {
              final userId = Supabase.instance.client.auth.currentUser?.id;
              if (userId == null) return;

              setState(() {
                notificationsEnabled = value;
              });

              await Supabase.instance.client
                  .from('profiles')
                  .update({'notify': value})
                  .eq('id', userId);

              print("Updated notify to: $value");
            }

            if (!isLoaded) {
              _loadPreference();
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.drag_handle, color: Colors.grey),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Account Settings".tr(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        padding: EdgeInsets.zero, // removes extra padding
                        constraints:
                            const BoxConstraints(), // keeps size compact
                        icon: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(
                              0xFFE8EAF6,
                            ), // light grey circle background
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.black54, // X color
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 25),

                  // Notification toggle
                  SwitchListTile(
                    value: notificationsEnabled,
                    activeColor: const Color(0xFF0057FF),
                    onChanged: (value) {
                      _updatePreference(value);
                    },
                    title: Text("Notifications".tr()),
                    secondary: const Icon(
                      Icons.notifications,
                      color: const Color(0xFF0057FF),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    onTap: () => _showChangePasswordDialog(context),
                    title: Text('Change Password'.tr()),
                    leading: Icon(
                      Icons.lock_open,
                      color: const Color(0xFF0057FF),
                    ),
                  ),

                  // ElevatedButton(
                  //   onPressed: () => _showChangePasswordDialog(context),
                  //   child: const Text('Change Password'),
                  // ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: Text('Select Language'.tr()),
                    leading: Icon(
                      Icons.language,
                      color: const Color(0xFF0066FF),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      TextButton.icon(
                        onPressed: () {
                          context.setLocale(const Locale('en'));
                        },
                        icon: context.locale.languageCode == 'en'
                            ? const Icon(
                                Icons.check,
                                color: Colors.green,
                              ) // ✅ shows selected
                            : const SizedBox.shrink(), // empty space if not selected
                        label: Text(
                          'English',
                          style: TextStyle(
                            fontWeight: context.locale.languageCode == 'en'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: context.locale.languageCode == 'en'
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          context.setLocale(const Locale('es'));
                        },
                        icon: context.locale.languageCode == 'es'
                            ? const Icon(Icons.check, color: Colors.green)
                            : const SizedBox.shrink(),
                        label: Text(
                          'Español',
                          style: TextStyle(
                            fontWeight: context.locale.languageCode == 'es'
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: context.locale.languageCode == 'es'
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Logout button
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: Text(
                      "logout".tr(),
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Bar Row with logo and location button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "hello".tr(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            isLoading
                                ? CircularProgressIndicator()
                                : Text(
                                    userName,
                                    style: TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ],
                        ),
                        // Image.asset(
                        //   'assets/images/medicineicon1.png',
                        //   height: 100,
                        // ),
                        GestureDetector(
                          onTap: () async {
                            final result = await showLocationBottomSheet(
                              context,
                              widget.userId,
                            );

                            if (result != null) {
                              setState(() {
                                selectedLocation = AppData.selectedLocation!;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DashboardPage(userId: widget.userId),
                                  ),
                                );
                              });
                            }
                          },

                          child: Row(
                            children: [
                              // Text(
                              //   AppData.selectedLocation ??
                              //       'No location selected',
                              //   overflow: TextOverflow.ellipsis,
                              //   style: TextStyle(
                              //     decoration: TextDecoration.underline,
                              //     fontSize: 10,
                              //     color: Colors.black87,
                              //   ),
                              // ),
                              SizedBox(width: 8),
                              // Container(
                              //   padding: const EdgeInsets.all(3),
                              //   decoration: BoxDecoration(
                              //     color: Colors.white,
                              //     border: Border.all(
                              //       color: Color(0xFF0057FF),
                              //       width: 1,
                              //     ),
                              //     borderRadius: BorderRadius.circular(8),
                              //     // boxShadow: [
                              //     //   BoxShadow(
                              //     //     color: Colors.blue.withOpacity(0.2),
                              //     //     blurRadius: 6,
                              //     //     offset: Offset(0, 4),
                              //     //   ),
                              //     // ],
                              //   ),
                              //   child: Icon(
                              //     Icons.location_on_outlined,
                              //     size: 24,
                              //     color: Color(0xFF0057FF),
                              //   ),
                              // ),
                              // Icon(
                              //   Icons.location_pin,
                              //   size: 24,
                              //   color:  const Color(0xFF0057FF),
                              // ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () => _showProfileOptions(context),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Color(0xFF0057FF),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    // boxShadow: [
                                    //   BoxShadow(
                                    //     color: Colors.blue.withOpacity(0.2),
                                    //     blurRadius: 6,
                                    //     offset: Offset(0, 4),
                                    //   ),
                                    // ],
                                  ),
                                  child: Icon(
                                    Icons.person_outline,
                                    color: Color(0xFF0057FF),
                                  ),
                                ),
                              ),

                              // IconButton(
                              //   icon: const Icon(
                              //     Icons.person,
                              //     color:  const Color(0xFF0057FF),
                              //   ),
                              //   onPressed: () => _showProfileOptions(context),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Welcome text and user name
                    // Text("Hello,", style: TextStyle(fontSize: 24)),
                    // isLoading
                    //     ? CircularProgressIndicator()
                    //     : Text(
                    //         userName,
                    //         style: TextStyle(
                    //           fontSize: 40,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    // SizedBox(height: 16),
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 16.0,
                    //     vertical: 12.0,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(20),
                    //     color: const Color(0xFFF1F6FF),
                    //   ),
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       // Custom Icon Stack
                    //       Padding(
                    //         padding: const EdgeInsets.only(top: 4.0),
                    //         child: Column(
                    //           children: [
                    //             IconButton(
                    //               icon: Icon(
                    //                 Icons.location_on_outlined,
                    //                 size: 24,
                    //                 color: Color(0xFF0057FF),
                    //               ),
                    //               onPressed: () async {
                    //                 final result =
                    //                     await showLocationBottomSheet(
                    //                       context,
                    //                       widget.userId,
                    //                     );

                    //                 if (result != null) {
                    //                   setState(() {
                    //                     selectedLocation =
                    //                         AppData.selectedLocation!;
                    //                     Navigator.pushReplacement(
                    //                       context,
                    //                       MaterialPageRoute(
                    //                         builder: (context) => DashboardPage(
                    //                           userId: widget.userId,
                    //                         ),
                    //                       ),
                    //                     );
                    //                   });
                    //                 }
                    //               },
                    //             ),
                    //             // This is a simple way to create the horizontal line below the icon
                    //             Container(
                    //               height: 2,
                    //               width: 16,
                    //               color: const Color(0xFF0057FF),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       const SizedBox(width: 12),

                    //       // Text Column
                    //       Expanded(
                    //         child: Column(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Row(
                    //               children: [
                    //                 Text(
                    //                   "Current Location".tr(),
                    //                   style: const TextStyle(
                    //                     fontWeight: FontWeight.w500,
                    //                     fontSize: 14,
                    //                     color: Colors.black54,
                    //                   ),
                    //                 ),
                    //                 const Icon(
                    //                   Icons.keyboard_arrow_down,
                    //                   size: 20,
                    //                   color: Colors.black54,
                    //                 ),
                    //               ],
                    //             ),
                    //             const SizedBox(height: 4),
                    //             Text(
                    //               AppData.selectedLocation ??
                    //                   'no_location_selected'.tr(),
                    //               style: const TextStyle(
                    //                 fontWeight: FontWeight.bold,
                    //                 fontSize: 16,
                    //                 color: Colors.black,
                    //               ),
                    //               textAlign: TextAlign.left,
                    //               maxLines: 1,
                    //               overflow: TextOverflow.ellipsis,
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    // Container(
                    //   width: double.infinity,
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(20),
                    //     color: const Color(0xFFF1F6FF),
                    //   ),

                    //   /// LOCATION
                    //   child: Column(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Row(
                    //         children: [
                    //           const SizedBox(width: 3),

                    //           Icon(
                    //             Icons.location_on,
                    //             size: 25,
                    //             color: const Color(0xFF0057FF),
                    //           ),
                    //           SizedBox(width: 4),
                    //           Text(
                    //             "location".tr(),

                    //             style: TextStyle(fontWeight: FontWeight.w600),
                    //           ),
                    //         ],
                    //       ),
                    //       const SizedBox(width: 4),
                    //       Text(' '),
                    //       Text(
                    //         AppData.selectedLocation ??
                    //             'no_location_selected'.tr(),
                    //         style: const TextStyle(fontWeight: FontWeight.bold),
                    //         textAlign: TextAlign.left,
                    //       ),
                    //       SizedBox(height: 3),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 16),

                    // New Location Multi-Select Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: const Color(0xFF0057FF)),
                      ),
                      onPressed: () async {
                        final supabase = Supabase.instance.client;

                        try {
                          final userLocationResponse = await supabase
                              .from('user_locations')
                              .select('location_id')
                              .eq('profile_id', widget.userId);

                          if (userLocationResponse == null ||
                              userLocationResponse.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'No locations found for this user.',
                                ),
                              ),
                            );
                            return;
                          }

                          List<int> locationIds = userLocationResponse
                              .map<int>((item) => item['location_id'] as int)
                              .toList();

                          final locationResponse = await supabase
                              .from('Locations')
                              .select('id, title')
                              .inFilter('id', locationIds);

                          if (locationResponse == null ||
                              locationResponse.isEmpty)
                            return;

                          List<Map<String, dynamic>> locations =
                              List<Map<String, dynamic>>.from(locationResponse);
                          List<int> tempSelected = List.from(
                            selectedLocationIds,
                          );

                          await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) {
                              bool selectAll =
                                  tempSelected.length == locations.length;

                              return StatefulBuilder(
                                builder: (context, setModalState) {
                                  return DraggableScrollableSheet(
                                    expand: false,
                                    initialChildSize:
                                        0.7, // 70% of screen height
                                    minChildSize: 0.4,
                                    maxChildSize: 0.95,
                                    builder: (_, scrollController) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          top: 20,
                                          bottom:
                                              MediaQuery.of(
                                                context,
                                              ).viewInsets.bottom +
                                              16,
                                        ),
                                        child: Column(
                                          children: [
                                            // HEADER
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  "select_locations".tr(),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  icon: Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Color(
                                                            0xFFE8EAF6,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 16,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(),

                                            // 🧭 MAIN CONTENT INSIDE SCROLL
                                            Expanded(
                                              child: ListView(
                                                controller: scrollController,
                                                children: [
                                                  const SizedBox(height: 16),
                                                  CheckboxListTile(
                                                    title: Text(
                                                      "select_all".tr(),
                                                    ),
                                                    value: selectAll,
                                                    onChanged: (value) {
                                                      setModalState(() {
                                                        selectAll =
                                                            value ?? false;
                                                        if (selectAll) {
                                                          tempSelected = locations
                                                              .map<int>(
                                                                (loc) =>
                                                                    loc['id']
                                                                        as int,
                                                              )
                                                              .toList();
                                                        } else {
                                                          tempSelected.clear();
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  ...locations.map((location) {
                                                    final int locId =
                                                        location['id'];
                                                    final String title =
                                                        location['title'];

                                                    return CheckboxListTile(
                                                      title: Text(title),
                                                      value: tempSelected
                                                          .contains(locId),
                                                      onChanged: (bool? value) {
                                                        setModalState(() {
                                                          if (value == true) {
                                                            tempSelected.add(
                                                              locId,
                                                            );
                                                          } else {
                                                            tempSelected.remove(
                                                              locId,
                                                            );
                                                          }
                                                          selectAll =
                                                              tempSelected
                                                                  .length ==
                                                              locations.length;
                                                        });
                                                      },
                                                      activeColor: const Color(
                                                        0xFF0057FF,
                                                      ),
                                                      controlAffinity:
                                                          ListTileControlAffinity
                                                              .trailing,
                                                    );
                                                  }).toList(),
                                                ],
                                              ),
                                            ),

                                            // ✅ ACTION BUTTON
                                            const SizedBox(height: 16),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  setState(() {
                                                    selectedLocationIds =
                                                        List.from(tempSelected);
                                                  });
                                                  await fetchAppointmentsCount();
                                                  await fetchPatientsCount();
                                                  await fetchInventoryQuantity();
                                                  await fetchTotalSalesAmount();
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "done".tr(),
                                                  style: const TextStyle(
                                                    color: Color(0xFF0057FF),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          );
                        } catch (e) {
                          print('Error fetching locations: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to fetch locations'),
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        Icons.location_on_outlined,
                        color: const Color(0xFF0057FF),
                      ),
                      label: Text(
                        "select_locations".tr(),
                        style: TextStyle(color: const Color(0xFF0057FF)),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Row(
                    //   children: [
                    //     Icon(Icons.error_outline, color: Colors.amber),
                    //     SizedBox(width: 8),
                    //     Expanded(
                    //       child: Text(
                    //         "You have unattended appointments.",
                    //         style: TextStyle(color: Colors.grey.shade700),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 24),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Text(
                    //       "30 mins ago",
                    //       style: TextStyle(fontWeight: FontWeight.bold),
                    //     ),
                    //     Icon(Icons.refresh),
                    //   ],
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          getTimeAgoText(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : GestureDetector(
                                onTap: _refreshDashboardData,
                                child: Icon(
                                  Icons.refresh,
                                  color: const Color(0xFF0057FF),
                                ),
                              ),
                      ],
                    ),

                    SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildDashboardTile(
                          label: "Patients".tr(),
                          icon: Icons.person_outline,
                          value: "$patientsCount",
                          onTap: () => _onTileTapped("Patients"),
                          backgroundColor: Color(0xFFFFEBEE), // light pink
                          textColor: Color(0xFFD32F2F), // dark red
                        ),

                        _buildDashboardTile(
                          label: "Sales".tr(),
                          icon: Icons.attach_money,
                          value: "\$ ${formatNumberCompact(totalSalesAmount)}",
                          onTap: () => _onTileTapped("Sales"),
                          backgroundColor: Color(0xFFF3E5F5), // light purple
                          textColor: Color(0xFF7B1FA2), // purple
                        ),

                        _buildDashboardTile(
                          label: "Appointments".tr(),
                          icon: Icons.calendar_today_outlined,
                          value: "$appointmentsCount",
                          onTap: () => _onTileTapped("Appointments"),
                          backgroundColor: Color(0xFFE0F7FA), // light cyan
                          textColor: Color(0xFF00838F), // teal
                        ),

                        _buildDashboardTile(
                          label: "Products".tr(),
                          icon: Icons.shopping_basket_outlined,
                          value:
                              "${formatNumberCompact(totalInventoryQuantity)}",
                          onTap: () => _onTileTapped("Products"),
                          backgroundColor: Color(0xFFE3F2FD), // light blue
                          textColor: Color(0xFF1565C0), // blue
                        ),
                      ],
                    ),

                    // GridView.count(
                    //   crossAxisCount: 2,
                    //   crossAxisSpacing: 16,
                    //   mainAxisSpacing: 16,
                    //   shrinkWrap: true,
                    //   physics: NeverScrollableScrollPhysics(),
                    //   children: [
                    //     _buildDashboardTile(
                    //       label: "Patients",
                    //       icon: Icons.groups,
                    //       value: "$patientsCount",
                    //       color: Colors.pink.shade50,
                    //       textColor: Colors.pink,
                    //       onTap: () => _onTileTapped("Patients"),
                    //     ),
                    //     _buildDashboardTile(
                    //       label: "Sales",
                    //       icon: Icons.point_of_sale,
                    //       value: "\$ ${formatNumberCompact(totalSalesAmount)}",
                    //       // value: "\$ ${totalSalesAmount.toStringAsFixed(1)}",
                    //       color: Colors.purple.shade50,
                    //       textColor: Colors.purple,
                    //       onTap: () => _onTileTapped("Sales"),
                    //     ),
                    //     _buildDashboardTile(
                    //       label: "Appointments",
                    //       icon: Icons.calendar_month,
                    //       value: "$appointmentsCount",
                    //       color: Colors.cyan.shade50,
                    //       textColor: Colors.teal,
                    //       onTap: () => _onTileTapped("Appointments"),
                    //     ),
                    //     _buildDashboardTile(
                    //       label: "Products",
                    //       icon: Icons.inventory,
                    //       value:
                    //           "\$ ${formatNumberCompact(totalInventoryQuantity)}",
                    //       // value: "$totalInventoryQuantity",
                    //       color: Colors.blue.shade50,
                    //       textColor: Colors.blue,
                    //       onTap: () => _onTileTapped("Products"),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigatorBar(
        userId: widget.userId,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildDashboardTile({
    required String label,
    required IconData icon,
    required String value,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor, // Custom background
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 148, 149, 150).withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: textColor, // Custom text color
              ),
            ),
            Spacer(),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//   Widget _buildDashboardTile({
//     required String label,
//     required IconData icon,
//     required String value,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Color(0xFFEAF2FD), // Soft pastel blue background
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: const Color.fromARGB(255, 148, 149, 150).withOpacity(0.2),
//               blurRadius: 6,
//               offset: Offset(0, 1),
//             ),
//           ],
//         ),
//         child: Stack(
//           clipBehavior: Clip.none,
//           children: [
//             // Positioned Icon at top-right
//             Positioned(
//               top: -16, // move upward by 10px
//               right: -15,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: const Color.fromARGB(255, 175, 205, 246),
//                   borderRadius: BorderRadius.circular(250),
//                 ),
//                 child: IconButton(
//                   icon: Icon(icon, color: Color(0xFF0A4DD5), size: 24),
//                   onPressed: () {},
//                 ),
//               ),
//             ),

//             // Main content
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     color: Color(0xFF0A4DD5),
//                   ),
//                 ),
//                 Spacer(),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFF0A4DD5),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//   Widget _buildDashboardTile({
//     required String label,
//     required IconData icon,
//     required String value,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Color(0xFFEAF2FD), // Soft pastel blue background
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.2),
//               blurRadius: 6,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     value,
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.w800,
//                       color: Color(0xFF0A4DD5), // Strong blue
//                     ),
//                   ),
//                 ),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(
//                       255,
//                       175,
//                       205,
//                       246,
//                     ), // Blue background
//                     borderRadius: BorderRadius.circular(250), // Rounded corners
//                   ),
//                   child: IconButton(
//                     icon: Icon(icon, color: Color(0xFF0A4DD5), size: 24),

//                     onPressed: () {},
//                   ),
//                 ),
//               ],
//             ),
//             Spacer(),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF0A4DD5),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//   Widget _buildDashboardTile({
//     required String label,
//     required IconData icon,
//     required String value,
//     required Color color,
//     required Color textColor,
//     required VoidCallback onTap,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, color: textColor),
//                 SizedBox(width: 8),
//                 Text(
//                   label,
//                   style: TextStyle(
//                     color: textColor,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             Spacer(),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: 28,
//                 color: textColor,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
