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
  int _selectedIndex = 2;
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
    if (lastUpdatedTime == null) return "Refresh";

    final now = DateTime.now();
    final difference = now.difference(lastUpdatedTime!);

    if (difference.inMinutes < 1) return "Just now";
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
          title: Text('Change Password'),
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
              child: Text('Cancel'),
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
              child: Text('Save'),
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
                  const Text(
                    "Account Settings",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Notification toggle
                  SwitchListTile(
                    value: notificationsEnabled,
                    onChanged: (value) {
                      _updatePreference(value);
                    },
                    title: const Text("Notifications"),
                    secondary: const Icon(Icons.notifications),
                  ),
                  const SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: () => _showChangePasswordDialog(context),
                    child: const Text('Change Password'),
                  ),
                  const SizedBox(height: 8),

                  // Logout button
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Logout",
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
      backgroundColor: Colors.white,
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
                        Image.asset(
                          'assets/images/medicineicon.png',
                          height: 100,
                        ),
                        GestureDetector(
                          onTap: () async {
                            final result = await showLocationBottomSheet(
                              context,
                              widget.userId,
                            );
                            if (result != null) {
                              setState(() {
                                selectedLocation = AppData.selectedLocation!;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                AppData.selectedLocation ??
                                    'No location selected',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontSize: 10,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.location_pin,
                                size: 24,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 12),
                              IconButton(
                                icon: const Icon(
                                  Icons.person,
                                  color: Colors.black,
                                ),
                                onPressed: () => _showProfileOptions(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Welcome text and user name
                    Text("Hello,", style: TextStyle(fontSize: 24)),
                    isLoading
                        ? CircularProgressIndicator()
                        : Text(
                            userName,
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                    SizedBox(height: 16),

                    // New Location Multi-Select Button
                    ElevatedButton.icon(
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
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: 16,
                                      right: 16,
                                      top: 16,
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom +
                                          16,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          "Select Locations",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Divider(),

                                        CheckboxListTile(
                                          title: const Text("Select All"),
                                          value: selectAll,
                                          onChanged: (value) {
                                            setModalState(() {
                                              selectAll = value ?? false;
                                              if (selectAll) {
                                                tempSelected = locations
                                                    .map<int>(
                                                      (loc) => loc['id'] as int,
                                                    )
                                                    .toList();
                                              } else {
                                                tempSelected.clear();
                                              }
                                            });
                                          },
                                        ),

                                        ...locations.map((location) {
                                          final int locId = location['id'];
                                          final String title =
                                              location['title'];

                                          return CheckboxListTile(
                                            title: Text(title),
                                            value: tempSelected.contains(locId),
                                            onChanged: (bool? value) {
                                              setModalState(() {
                                                if (value == true) {
                                                  tempSelected.add(locId);
                                                } else {
                                                  tempSelected.remove(locId);
                                                }
                                                selectAll =
                                                    tempSelected.length ==
                                                    locations.length;
                                              });
                                            },
                                          );
                                        }).toList(),

                                        SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () async {
                                            setState(() {
                                              selectedLocationIds = List.from(
                                                tempSelected,
                                              );
                                            });
                                            await fetchAppointmentsCount();
                                            await fetchPatientsCount();
                                            await fetchInventoryQuantity();
                                            await fetchTotalSalesAmount();
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Done"),
                                        ),
                                      ],
                                    ),
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
                      icon: Icon(Icons.list),
                      label: Text("Select Locations"),
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
                                child: Icon(Icons.refresh),
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
                          label: "Patients",
                          icon: Icons.groups,
                          value: "$patientsCount",
                          color: Colors.pink.shade50,
                          textColor: Colors.pink,
                          onTap: () => _onTileTapped("Patients"),
                        ),
                        _buildDashboardTile(
                          label: "Sales",
                          icon: Icons.point_of_sale,
                          value: "\$ ${formatNumberCompact(totalSalesAmount)}",
                          // value: "\$ ${totalSalesAmount.toStringAsFixed(1)}",
                          color: Colors.purple.shade50,
                          textColor: Colors.purple,
                          onTap: () => _onTileTapped("Sales"),
                        ),
                        _buildDashboardTile(
                          label: "Appointments",
                          icon: Icons.calendar_month,
                          value: "$appointmentsCount",
                          color: Colors.cyan.shade50,
                          textColor: Colors.teal,
                          onTap: () => _onTileTapped("Appointments"),
                        ),
                        _buildDashboardTile(
                          label: "Products",
                          icon: Icons.inventory,
                          value:
                              "\$ ${formatNumberCompact(totalInventoryQuantity)}",
                          // value: "$totalInventoryQuantity",
                          color: Colors.blue.shade50,
                          textColor: Colors.blue,
                          onTap: () => _onTileTapped("Products"),
                        ),
                      ],
                    ),
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
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: textColor),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
