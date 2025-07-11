import 'package:flutter/material.dart';
import 'package:medicineapp/location.dart';
import 'package:medicineapp/navigationbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 4;
  String? selectedLocation;
  List<Map<String, String>> user = [];

  final supabase = Supabase.instance.client;

  Future<int?> getRoleIdFromRoleName(String roleName) async {
    final response = await supabase
        .from('roles')
        .select('id')
        .eq('name', roleName)
        .maybeSingle();

    return response?['id'] as int?;
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await supabase
          .from('profiles')
          .select('id,full_name, email,  roles(name)');
      print(response);
      if (response != null) {
        setState(() {
          user = response.map<Map<String, String>>((item) {
            return {
              'id': item['id'],
              'name': item['full_name'] ?? 'No name',
              'role': item['roles']['name'] ?? 'No role',
              'email': item['email'] ?? 'No name',
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching user profiles: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Top Logo and Profile Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset('assets/images/medicineicon.png', height: 80),
                  Row(
                    children: [
                      Text(
                        AppData.selectedLocation ?? 'No location selected',
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          final result = await showLocationBottomSheet(context);
                          if (result != null) {
                            setState(() {
                              selectedLocation = AppData.selectedLocation!;
                            });
                          }
                        },
                        child: const Icon(Icons.location_pin, size: 30),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.person, size: 30),
                    ],
                  ),
                ],
              ),

              // Title and Buttons Row
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
                        onPressed: () => Navigator.pop(context),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Users",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(3),

                    child: Row(
                      children: [
                        GestureDetector(
                          // onTap: () {
                          //   showDialog(
                          //     context: context,
                          //     builder: (BuildContext context) {
                          //       final TextEditingController nameController =
                          //           TextEditingController();
                          //       final TextEditingController genderController =
                          //           TextEditingController();
                          //       final TextEditingController emailController =
                          //           TextEditingController();

                          //       return AlertDialog(
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(16),
                          //         ),
                          //         title: Text(
                          //           "Add New Role",
                          //           style: TextStyle(
                          //             color: Colors.black,
                          //             fontWeight: FontWeight.bold,
                          //           ),
                          //         ),
                          //         content: SingleChildScrollView(
                          //           child: Column(
                          //             children: [
                          //               TextField(
                          //                 controller: nameController,
                          //                 decoration: InputDecoration(
                          //                   labelText: "Name",
                          //                   hintText: "Enter name",
                          //                 ),
                          //               ),
                          //               SizedBox(height: 12),

                          //               SizedBox(height: 12),
                          //               TextField(
                          //                 controller: emailController,
                          //                 decoration: InputDecoration(
                          //                   labelText: "Role",
                          //                   hintText: "Enter Role",
                          //                 ),
                          //               ),
                          //               SizedBox(height: 20),
                          //               ElevatedButton(
                          //                 onPressed: () {
                          //                   String name = nameController.text;
                          //                   String gender = genderController.text;
                          //                   String email = emailController.text;

                          //                   // TODO: You can now save or process these values

                          //                   Navigator.pop(
                          //                     context,
                          //                   ); // close dialog
                          //                 },
                          //                 style: ElevatedButton.styleFrom(
                          //                   backgroundColor: Colors.black,
                          //                   foregroundColor: Colors.white,
                          //                 ),
                          //                 child: Text("Add Role"),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       );
                          //     },
                          //   );
                          // },
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
                                SnackBar(
                                  content: Text("No permissions found."),
                                ),
                              );
                              return;
                            }

                            // Step 2: Build dynamic permissions map
                            final Map<String, bool> permissions = {
                              for (var item in response)
                                item['permission'] as String: false,
                            };

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
                                                onPressed: () {
                                                  // 👉 You can now save roleController.text and permissions map to your backend
                                                  Navigator.pop(context);
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
                              Icon(Icons.person_4_outlined, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(
                                "Add New Role",
                                style: TextStyle(color: Colors.blue),
                              ),
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
                                    .map<String>(
                                      (item) => item['name'] as String,
                                    )
                                    .toList();
                              });
                            }
                             final locResponse = await supabase.from('Locations').select('title');
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
                                        MediaQuery.of(
                                          context,
                                        ).viewInsets.bottom +
                                        20,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Top bar drag handle
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
                                        SizedBox(height: 16),

                                        Text(
                                          "Add New User",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 16),

                                        // Username
                                        TextField(
                                          controller: usernameController,

                                          decoration: InputDecoration(
                                            hintText: "Username",

                                            fillColor: Colors.grey.shade100,
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        SizedBox(height: 12),

                                        // Role Dropdown
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

                                        // Location (readonly or dropdown can be implemented)
                                          TextField(
                    controller: locationController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Select Locations",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setDialogState) {
                              return AlertDialog(
                                title: Text("Select Locations"),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: allLocations.map((location) {
                                      final isSelected = selectedLocations.contains(location);
                                      return CheckboxListTile(
                                        title: Text(location),
                                        value: isSelected,
                                        onChanged: (checked) {
                                          setDialogState(() {
                                            if (checked == true) {
                                              selectedLocations.add(location);
                                            } else {
                                              selectedLocations.remove(location);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        locationController.text = selectedLocations.join(", ");
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
                                                  // 1. Create new user in auth
                                                  final authResponse = await supabase
                                                      .auth
                                                      .admin
                                                      .createUser(
                                                        AdminUserAttributes(
                                                          email: emailController
                                                              .text
                                                              .trim(),
                                                          password:
                                                              passwordController
                                                                  .text
                                                                  .trim(),
                                                          emailConfirm: true,
                                                        ),
                                                      );

                                                  final newUser =
                                                      authResponse.user;

                                                  if (newUser == null)
                                                    throw Exception(
                                                      "Failed to create user",
                                                    );

                                                  // 2. Get the user's UUID
                                                  final uuid = newUser.id;

                                                  // 3. Map role name to role ID (you may already have a map or fetch it)
                                                  final roleId =
                                                      await getRoleIdFromRoleName(
                                                        selectedRole!,
                                                      );

                                                  // 4. Insert into `profiles` table
                                                  final profileResponse = await supabase
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
                                                        // 'role_id': roleId,
                                                        'role_id': 8,
                                                        'email': emailController
                                                            .text
                                                            .trim(),
                                                        // Add other optional fields if needed
                                                      });

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
                                                } catch (e) {
                                                  print(
                                                    "Error adding user: $e",
                                                  );
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

                                                // You can save all data here
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
                              Icon(
                                Icons.add_circle_outline,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 4),
                              Text(
                                "Add New User",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // User List
              Expanded(
                child: ListView.builder(
                  itemCount: user.length, // <- use the list’s length
                  itemBuilder: (context, index) {
                    final userData =
                        user[index]; // <- rename so it’s NOT the same name as the list

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F6FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          // blue accent strip
                          Container(
                            width: 6,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // profile info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userData['name'] ?? 'No name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userData['role'] ?? 'Role‑less',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  userData['email'] ?? '—',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Confirm Delete"),
                                  content: Text(
                                    "Are you sure you want to delete this user?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        final id = userData['id']!;
                                        await supabase
                                            .from('profiles')
                                            .delete()
                                            .eq('id', id);
                                        Navigator.pop(context);
                                        fetchUserProfile();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text("Delete"),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                     IconButton(
  icon: Icon(Icons.edit, color: Colors.blueAccent, size: 28),
  onPressed: () async {
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController locationController = TextEditingController();

    List<String> selectedLocations = [];
    List<String> allLocations = [];
    List<String> roles = [];
    String? selectedRole;

    final supabase = Supabase.instance.client;

    // Fetch roles
    final roleResponse = await supabase.from('roles').select('name');
    if (roleResponse != null) {
      roles = roleResponse
          .map<String>((item) => item['name'] as String)
          .toList();
    }

    // Fetch locations
    final locResponse = await supabase.from('Locations').select('title');
    allLocations = (locResponse as List<dynamic>)
        .map((e) => e['title'].toString())
        .toList();

    // SHOW BOTTOM SHEET
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("Edit User", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 12),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: "Username",
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
                    items: roles.map((role) => DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    )).toList(),
                    onChanged: (val) => setModalState(() => selectedRole = val),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),

                  /// LOCATIONS DROPDOWN WITH MULTI-SELECT
                  TextField(
                    controller: locationController,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Select Locations",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, setDialogState) {
                              return AlertDialog(
                                title: Text("Select Locations"),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: allLocations.map((location) {
                                      final isSelected = selectedLocations.contains(location);
                                      return CheckboxListTile(
                                        title: Text(location),
                                        value: isSelected,
                                        onChanged: (checked) {
                                          setDialogState(() {
                                            if (checked == true) {
                                              selectedLocations.add(location);
                                            } else {
                                              selectedLocations.remove(location);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      setModalState(() {
                                        locationController.text = selectedLocations.join(", ");
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

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      print("Username: ${usernameController.text}");
                      print("Email: ${emailController.text}");
                      print("Password: ${passwordController.text}");
                      print("Role: $selectedRole");
                      print("Locations: ${locationController.text}");
                      Navigator.pop(context); // Close bottom sheet here
                    },
                    child: Text("Edit User"),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  },
)
 
                       
                       
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigatorBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
