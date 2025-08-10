import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medicineapp/location.dart';
import 'package:medicineapp/navigationbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPage extends StatefulWidget {
  final String userId;
  const UserPage({Key? key, required this.userId}) : super(key: key);

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
       appBar: AppBar(
        leading: Row(
          children: [
            IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 28,
                          color: Colors.black,
                          
                        ),

                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      //  Text('Back', style: TextStyle(color: Colors.black,fontSize: 10)),
                     

          ],
        ),
        centerTitle: true,
          title: Text("Users".tr(), style: TextStyle(color: Colors.black,fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 1,),
      backgroundColor: const Color(0xFFF1F4F9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Top Logo and Profile Icon
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     // Image.asset('assets/images/medicineicon.png', height: 80),
              //     Row(
              //       // children: [
              //       //   Text(
              //       //     AppData.selectedLocation ?? 'No location selected',
              //       //     style: const TextStyle(
              //       //       decoration: TextDecoration.underline,
              //       //       fontSize: 12,
              //       //     ),
              //       //     overflow: TextOverflow.ellipsis,
              //       //   ),
              //       //   const SizedBox(width: 10),
              //       //   GestureDetector(
              //       //     onTap: () async {
              //       //       final result = await showLocationBottomSheet(
              //       //         context,
              //       //         widget.userId,
              //       //       );
              //       //       if (result != null) {
              //       //         setState(() {
              //       //           selectedLocation = AppData.selectedLocation!;
              //       //         });
              //       //       }
              //       //     },
              //       //     child: const Icon(Icons.location_pin, size: 30),
              //       //   ),
              //       //   const SizedBox(width: 10),
              //       //   const Icon(Icons.person, size: 30),
              //       // ],
              //     ),
              //   ],
              // ),

              // Title and Buttons Row
            //   Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Row(
            //         children: [
            //           IconButton(
            //             icon: Icon(
            //               Icons.arrow_back,
            //               size: 28,
            //               color: Colors.black,
            //             ),

            //             onPressed: () {
            //               Navigator.pop(context);
            //             },
            //           ),
            //           Text('Back'.tr(), style: TextStyle(color: Colors.black)),
            //           SizedBox(width: 80),
            //            Center(
            //   child: Text(
            //     "Users".tr(),
            //     textAlign: TextAlign.center,
            //     style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            //   ),
            // ),
            //         ],
            //       ),
            //       Padding(
            //         padding: EdgeInsets.all(3),

            //         child: Row(
            //           children: [
            //             GestureDetector(
            //               onTap: () async {
            //                 final supabase = Supabase.instance.client;
            //                 final TextEditingController roleController =
            //                     TextEditingController();

            //                 // Step 1: Fetch permissions from the Permissions table
            //                 final response = await supabase
            //                     .from('permissions')
            //                     .select('permission');

            //                 if (response == null || response.isEmpty) {
            //                   ScaffoldMessenger.of(context).showSnackBar(
            //                     SnackBar(
            //                       content: Text("No permissions found."),
            //                     ),
            //                   );
            //                   return;
            //                 }

            //                 // Step 2: Build dynamic permissions map
            //                 final Map<String, bool> permissions = {
            //                   for (var item in response)
            //                     item['permission'] as String: false,
            //                 };
            //                 Future<void> saveRoleWithPermissions({
            //                   required String roleName,
            //                   required Map<String, bool> permissionToggles,
            //                 }) async {
            //                   final supabase = Supabase.instance.client;

            //                   if (roleName.trim().isEmpty) {
            //                     throw Exception('Role name cannot be empty');
            //                   }

            //                   final roleInsert = await supabase
            //                       .from('roles')
            //                       .insert({'name': roleName.trim()})
            //                       .select('id')
            //                       .single();

            //                   final int roleId = roleInsert['id'] as int;
            //                   print('roleid: $roleId');

            //                   final enabledLabels = permissionToggles.entries
            //                       .where((entry) => entry.value) // ON only
            //                       .map((entry) => entry.key)
            //                       .toList();
            //                   print(enabledLabels);
            //                   if (enabledLabels.isEmpty) {
            //                     // No permissions checked – nothing more to do
            //                     return;
            //                   }

            //                   final permsQuery = await supabase
            //                       .from('permissions')
            //                       .select('id, permission')
            //                       .inFilter('permission', enabledLabels);

            //                   final Map<String, int> labelToId = {
            //                     for (final row in permsQuery)
            //                       row['permission'] as String: row['id'] as int,
            //                   };

            //                   final rowsToInsert = <Map<String, dynamic>>[];
            //                   for (final label in enabledLabels) {
            //                     final permId = labelToId[label];
            //                     if (permId != null) {
            //                       rowsToInsert.add({
            //                         'roles': roleId,
            //                         'permissions': permId,
            //                       });
            //                     }
            //                   }
            //                   print(rowsToInsert);
            //                   await supabase
            //                       .from('user_permissions')
            //                       .upsert(
            //                         rowsToInsert,
            //                         onConflict: 'roles,permissions',
            //                         ignoreDuplicates: true,
            //                       );
            //                 }

            //                 showModalBottomSheet(
            //                   context: context,
            //                   isScrollControlled: true,
            //                   shape: const RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.vertical(
            //                       top: Radius.circular(24),
            //                     ),
            //                   ),
            //                   builder: (context) {
            //                     return Padding(
            //                       padding: EdgeInsets.only(
            //                         bottom: MediaQuery.of(
            //                           context,
            //                         ).viewInsets.bottom,
            //                         left: 16,
            //                         right: 16,
            //                         top: 24,
            //                       ),
            //                       child: StatefulBuilder(
            //                         builder: (context, setState) {
            //                           return SingleChildScrollView(
            //                             child: Column(
            //                               crossAxisAlignment:
            //                                   CrossAxisAlignment.start,
            //                               children: [
            //                                 Center(
            //                                   child: Container(
            //                                     width: 40,
            //                                     height: 6,
            //                                     decoration: BoxDecoration(
            //                                       color: Colors.grey[400],
            //                                       borderRadius:
            //                                           BorderRadius.circular(8),
            //                                     ),
            //                                   ),
            //                                 ),
            //                                 SizedBox(height: 20),
            //                                 Text(
            //                                   "Add New Role",
            //                                   style: TextStyle(
            //                                     fontSize: 20,
            //                                     fontWeight: FontWeight.bold,
            //                                   ),
            //                                 ),
            //                                 SizedBox(height: 16),
            //                                 TextField(
            //                                   controller: roleController,
            //                                   decoration: InputDecoration(
            //                                     labelText: "User roles",
            //                                     hintText: "Enter user role",
            //                                     border: OutlineInputBorder(),
            //                                   ),
            //                                 ),
            //                                 SizedBox(height: 16),
            //                                 Text(
            //                                   "Permissions",
            //                                   style: TextStyle(
            //                                     fontWeight: FontWeight.w600,
            //                                     fontSize: 16,
            //                                   ),
            //                                 ),
            //                                 SizedBox(height: 8),
            //                                 Column(
            //                                   children: permissions.keys.map((
            //                                     key,
            //                                   ) {
            //                                     return SwitchListTile(
            //                                       title: Text(key),
            //                                       value: permissions[key]!,
            //                                       onChanged: (val) {
            //                                         setState(() {
            //                                           permissions[key] = val;
            //                                         });
            //                                       },
            //                                     );
            //                                   }).toList(),
            //                                 ),
            //                                 SizedBox(height: 12),
            //                                 SizedBox(
            //                                   width: double.infinity,
            //                                   child: ElevatedButton(
            //                                     onPressed: () async {
            //                                       try {
            //                                         await saveRoleWithPermissions(
            //                                           roleName:
            //                                               roleController.text,
            //                                           permissionToggles:
            //                                               permissions,
            //                                         );
            //                                         ScaffoldMessenger.of(
            //                                           context,
            //                                         ).showSnackBar(
            //                                           const SnackBar(
            //                                             content: Text(
            //                                               'Role saved successfully!',
            //                                               style: TextStyle(
            //                                                 color: Colors.black,
            //                                               ),
            //                                             ),
            //                                             backgroundColor:
            //                                                 Colors.green,
            //                                           ),
            //                                         );
            //                                         Navigator.pop(context);
            //                                       } catch (e) {
            //                                         ScaffoldMessenger.of(
            //                                           context,
            //                                         ).showSnackBar(
            //                                           SnackBar(
            //                                             content: Text(
            //                                               'Error: \$e',
            //                                             ),
            //                                           ),
            //                                         );
            //                                       }
            //                                     },
            //                                     style: ElevatedButton.styleFrom(
            //                                       backgroundColor: Colors.black,
            //                                       foregroundColor: Colors.white,
            //                                       padding: EdgeInsets.symmetric(
            //                                         vertical: 14,
            //                                       ),
            //                                     ),
            //                                     child: Text("Add Role"),
            //                                   ),
            //                                 ),
            //                                 SizedBox(height: 12),
            //                               ],
            //                             ),
            //                           );
            //                         },
            //                       ),
            //                     );
            //                   },
            //                 );
            //               },

            //               child: Column(
            //                 children: [
            //                   // Icon(Icons.person_4_outlined, color: Colors.blue),
            //                   // SizedBox(width: 4),
            //                   // Text(
            //                   //   "Add New Role",
            //                   //   style: TextStyle(color: Colors.blue),
            //                   // ),
            //                 ],
            //               ),
            //             ),
            //             SizedBox(width: 5, height: 4),
            //             GestureDetector(
            //               onTap: () async {
            //                 final TextEditingController usernameController =
            //                     TextEditingController();
            //                 final TextEditingController emailController =
            //                     TextEditingController();
            //                 final TextEditingController passwordController =
            //                     TextEditingController();
            //                 final TextEditingController locationController =
            //                     TextEditingController();
            //                 List<String> roles = [];
            //                 List<String> selectedLocations = [];
            //                 List<String> allLocations = [];
            //                 String? selectedRole;
            //                 final supabase = Supabase.instance.client;

            //                 final response = await supabase
            //                     .from('roles')
            //                     .select('name');

            //                 if (response != null) {
            //                   setState(() {
            //                     roles = response
            //                         .map<String>(
            //                           (item) => item['name'] as String,
            //                         )
            //                         .toList();
            //                   });
            //                 }
            //                 final locResponse = await supabase
            //                     .from('Locations')
            //                     .select('title');
            //                 allLocations = (locResponse as List<dynamic>)
            //                     .map((e) => e['title'].toString())
            //                     .toList();

            //                 showModalBottomSheet(
            //                   context: context,
            //                   isScrollControlled: true,
            //                   shape: RoundedRectangleBorder(
            //                     borderRadius: BorderRadius.vertical(
            //                       top: Radius.circular(24),
            //                     ),
            //                   ),
            //                   builder: (context) {
            //                     return Padding(
            //                       padding: EdgeInsets.only(
            //                         left: 16,
            //                         right: 16,
            //                         top: 20,
            //                         bottom:
            //                             MediaQuery.of(
            //                               context,
            //                             ).viewInsets.bottom +
            //                             20,
            //                       ),
            //                       child: SingleChildScrollView(
            //                         child: Column(
            //                           crossAxisAlignment:
            //                               CrossAxisAlignment.start,
            //                           children: [
            //                             Center(
            //                               child: Container(
            //                                 width: 40,
            //                                 height: 6,
            //                                 decoration: BoxDecoration(
            //                                   color: Colors.grey[400],
            //                                   borderRadius:
            //                                       BorderRadius.circular(8),
            //                                 ),
            //                               ),
            //                             ),
            //                             SizedBox(height: 16),

            //                             Text(
            //                               "Add New User",
            //                               style: TextStyle(
            //                                 fontSize: 20,
            //                                 fontWeight: FontWeight.bold,
            //                               ),
            //                             ),
            //                             SizedBox(height: 16),

            //                             TextField(
            //                               controller: usernameController,

            //                               decoration: InputDecoration(
            //                                 hintText: "Username",

            //                                 fillColor: Colors.grey.shade100,
            //                                 border: OutlineInputBorder(),
            //                               ),
            //                             ),
            //                             SizedBox(height: 12),

            //                             DropdownButtonFormField<String>(
            //                               value: selectedRole,
            //                               decoration: InputDecoration(
            //                                 hintText: "Select Role",
            //                                 border: OutlineInputBorder(),
            //                               ),
            //                               items: roles
            //                                   .map(
            //                                     (role) =>
            //                                         DropdownMenuItem<String>(
            //                                           value: role,
            //                                           child: Text(role),
            //                                         ),
            //                                   )
            //                                   .toList(),
            //                               onChanged: (value) {
            //                                 selectedRole = value;
            //                               },
            //                             ),
            //                             SizedBox(height: 12),

            //                             // Email
            //                             TextField(
            //                               controller: emailController,
            //                               decoration: InputDecoration(
            //                                 hintText: "Email",
            //                                 border: OutlineInputBorder(),
            //                               ),
            //                             ),
            //                             SizedBox(height: 12),

            //                             // Password
            //                             TextField(
            //                               controller: passwordController,
            //                               obscureText: true,
            //                               decoration: InputDecoration(
            //                                 hintText: "Password",
            //                                 border: OutlineInputBorder(),
            //                               ),
            //                             ),
            //                             SizedBox(height: 12),

            //                             TextField(
            //                               controller: locationController,
            //                               readOnly: true,
            //                               decoration: InputDecoration(
            //                                 hintText: "Select Locations",
            //                                 border: OutlineInputBorder(),
            //                                 suffixIcon: Icon(
            //                                   Icons.arrow_drop_down,
            //                                 ),
            //                               ),
            //                               onTap: () {
            //                                 showDialog(
            //                                   context: context,
            //                                   builder: (context) {
            //                                     return StatefulBuilder(
            //                                       builder: (context, setDialogState) {
            //                                         return AlertDialog(
            //                                           title: Text(
            //                                             "Select Locations",
            //                                           ),
            //                                           content: SizedBox(
            //                                             width: double.maxFinite,
            //                                             child: ListView(
            //                                               shrinkWrap: true,
            //                                               children: allLocations.map((
            //                                                 location,
            //                                               ) {
            //                                                 final isSelected =
            //                                                     selectedLocations
            //                                                         .contains(
            //                                                           location,
            //                                                         );
            //                                                 return CheckboxListTile(
            //                                                   title: Text(
            //                                                     location,
            //                                                   ),
            //                                                   value: isSelected,
            //                                                   onChanged: (checked) {
            //                                                     setDialogState(() {
            //                                                       if (checked ==
            //                                                           true) {
            //                                                         selectedLocations
            //                                                             .add(
            //                                                               location,
            //                                                             );
            //                                                       } else {
            //                                                         selectedLocations
            //                                                             .remove(
            //                                                               location,
            //                                                             );
            //                                                       }
            //                                                     });
            //                                                   },
            //                                                 );
            //                                               }).toList(),
            //                                             ),
            //                                           ),
            //                                           actions: [
            //                                             TextButton(
            //                                               onPressed: () =>
            //                                                   Navigator.pop(
            //                                                     context,
            //                                                   ),
            //                                               child: Text("Cancel"),
            //                                             ),
            //                                             ElevatedButton(
            //                                               onPressed: () {
            //                                                 Navigator.pop(
            //                                                   context,
            //                                                 );
            //                                                 setState(() {
            //                                                   locationController
            //                                                           .text =
            //                                                       selectedLocations
            //                                                           .join(
            //                                                             ", ",
            //                                                           );
            //                                                 });
            //                                               },
            //                                               child: Text("Done"),
            //                                             ),
            //                                           ],
            //                                         );
            //                                       },
            //                                     );
            //                                   },
            //                                 );
            //                               },
            //                             ),

            //                             SizedBox(height: 24),

            //                             // Buttons
            //                             Row(
            //                               mainAxisAlignment:
            //                                   MainAxisAlignment.end,
            //                               children: [
            //                                 TextButton(
            //                                   onPressed: () =>
            //                                       Navigator.pop(context),
            //                                   child: Text("Cancel"),
            //                                 ),
            //                                 SizedBox(width: 10),
            //                                 ElevatedButton(
            //                                   onPressed: () async {
            //                                     final supabase =
            //                                         Supabase.instance.client;

            //                                     if (emailController
            //                                             .text
            //                                             .isEmpty ||
            //                                         passwordController
            //                                             .text
            //                                             .isEmpty ||
            //                                         selectedRole == null) {
            //                                       ScaffoldMessenger.of(
            //                                         context,
            //                                       ).showSnackBar(
            //                                         SnackBar(
            //                                           content: Text(
            //                                             "Please fill all fields.",
            //                                           ),
            //                                         ),
            //                                       );
            //                                       return;
            //                                     }

            //                                     try {
            //                                       print(
            //                                         'email:$emailController',
            //                                       );
            //                                       print(
            //                                         'password:$passwordController',
            //                                       );
            //                                       print('working');

            //                                       final signUpRes =
            //                                           await supabase.auth.signUp(
            //                                             email: emailController
            //                                                 .text
            //                                                 .trim(),
            //                                             password:
            //                                                 passwordController
            //                                                     .text
            //                                                     .trim(),

            //                                             data: {
            //                                               'full_name':
            //                                                   usernameController
            //                                                       .text
            //                                                       .trim(),
            //                                             },
            //                                           );
            //                                       print(signUpRes);
            //                                       Future<int?>
            //                                       getRoleIdFromRoleName(
            //                                         String roleName,
            //                                       ) async {
            //                                         final supabase = Supabase
            //                                             .instance
            //                                             .client;

            //                                         final response =
            //                                             await supabase
            //                                                 .from('roles')
            //                                                 .select('id')
            //                                                 .eq(
            //                                                   'name',
            //                                                   roleName,
            //                                                 )
            //                                                 .maybeSingle();
            //                                         print(response);
            //                                         if (response != null &&
            //                                             response['id'] !=
            //                                                 null) {
            //                                           return response['id']
            //                                               as int;
            //                                         }

            //                                         return null;
            //                                       }

            //                                       final roleId =
            //                                           await getRoleIdFromRoleName(
            //                                             selectedRole!,
            //                                           );
            //                                       print(roleId);
            //                                       if (signUpRes.user != null) {
            //                                         final uuid =
            //                                             signUpRes.user!.id;
            //                                         print(uuid);
            //                                         final profileResponse = await supabase
            //                                             .from('profiles')
            //                                             .insert({
            //                                               'id': uuid,
            //                                               'active': false,
            //                                               'profile_pictures':
            //                                                   'https://vsvueqtgulraaczqnnvh.supabase.co/storage/v1/object/public/profile-pictures//user.png',
            //                                               'full_name':
            //                                                   usernameController
            //                                                       .text
            //                                                       .trim(),
            //                                               'role_id': roleId,
            //                                               'email':
            //                                                   emailController
            //                                                       .text
            //                                                       .trim(),
            //                                             });

            //                                         if (profileResponse.error !=
            //                                             null) {
            //                                           print(
            //                                             "Error inserting profile: ${profileResponse.error!.message}",
            //                                           );
            //                                           ScaffoldMessenger.of(
            //                                             context,
            //                                           ).showSnackBar(
            //                                             SnackBar(
            //                                               content: Text(
            //                                                 "Failed to insert profile",
            //                                               ),
            //                                             ),
            //                                           );
            //                                           return;
            //                                         }

            //                                         // 👇 Insert into user_locations here
            //                                         final locationIds =
            //                                             locationController.text
            //                                                 .split(
            //                                                   ',',
            //                                                 ) // or however your app stores multiple IDs
            //                                                 .map(
            //                                                   (id) =>
            //                                                       int.tryParse(
            //                                                         id.trim(),
            //                                                       ),
            //                                                 )
            //                                                 .where(
            //                                                   (id) =>
            //                                                       id != null,
            //                                                 )
            //                                                 .toList();

            //                                         final locationEntries =
            //                                             locationIds
            //                                                 .map(
            //                                                   (locationId) => {
            //                                                     'profile_id':
            //                                                         uuid,
            //                                                     'location_id':
            //                                                         locationId,
            //                                                   },
            //                                                 )
            //                                                 .toList();

            //                                         final userLocationsRes =
            //                                             await supabase
            //                                                 .from(
            //                                                   'user_locations',
            //                                                 )
            //                                                 .insert(
            //                                                   locationEntries,
            //                                                 );

            //                                         if (userLocationsRes
            //                                                 .error !=
            //                                             null) {
            //                                           print(
            //                                             "Error inserting user_locations: ${userLocationsRes.error!.message}",
            //                                           );
            //                                           ScaffoldMessenger.of(
            //                                             context,
            //                                           ).showSnackBar(
            //                                             SnackBar(
            //                                               content: Text(
            //                                                 "Failed to insert user locations",
            //                                               ),
            //                                             ),
            //                                           );
            //                                           return;
            //                                         }

            //                                         ScaffoldMessenger.of(
            //                                           context,
            //                                         ).showSnackBar(
            //                                           SnackBar(
            //                                             content: Text(
            //                                               "User added successfully.",
            //                                             ),
            //                                           ),
            //                                         );
            //                                         Navigator.pop(context);
            //                                       }
            //                                     } catch (e) {
            //                                       print(
            //                                         "Error adding user: $e",
            //                                       );
            //                                       ScaffoldMessenger.of(
            //                                         context,
            //                                       ).showSnackBar(
            //                                         SnackBar(
            //                                           content: Text(
            //                                             "Failed to add user.",
            //                                           ),
            //                                         ),
            //                                       );
            //                                     }

            //                                     print(
            //                                       "Username: ${usernameController.text}",
            //                                     );
            //                                     print("Role: $selectedRole");
            //                                     print(
            //                                       "Email: ${emailController.text}",
            //                                     );
            //                                     print(
            //                                       "Password: ${passwordController.text}",
            //                                     );
            //                                     print(
            //                                       "Location: ${locationController.text}",
            //                                     );

            //                                     Navigator.pop(context);
            //                                   },
            //                                   style: ElevatedButton.styleFrom(
            //                                     backgroundColor: Colors.black,
            //                                     foregroundColor: Colors.white,
            //                                     padding: EdgeInsets.symmetric(
            //                                       horizontal: 24,
            //                                       vertical: 14,
            //                                     ),
            //                                   ),
            //                                   child: Text("Add User"),
            //                                 ),
            //                               ],
            //                             ),
            //                           ],
            //                         ),
            //                       ),
            //                     );
            //                   },
            //                 );
            //               },

            //               child: Column(
            //                 children: [
            //                   // Icon(
            //                   //   Icons.add_circle_outline,
            //                   //   color: Colors.blue,
            //                   // ),
            //                   // SizedBox(width: 4),
            //                   // Text(
            //                   //   "Add New User",
            //                   //   style: TextStyle(color: Colors.blue),
            //                   // ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),

            //   SizedBox(height: 16),

              // User List
              Expanded(
                child: ListView.builder(
                  itemCount: user.length,
                  itemBuilder: (context, index) {
                    final userData = user[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                              size: 28,
                            ),
                            onPressed: () async {
                              final TextEditingController usernameController =
                                  TextEditingController();
                              final TextEditingController emailController =
                                  TextEditingController();
                              final TextEditingController passwordController =
                                  TextEditingController();
                              final TextEditingController locationController =
                                  TextEditingController();

                              List<String> selectedLocations = [];
                              List<String> allLocations = [];
                              List<String> roles = [];
                              String? selectedRole;

                              final supabase = Supabase.instance.client;

                              // Fetch roles
                              final roleResponse = await supabase
                                  .from('roles')
                                  .select('name');
                              if (roleResponse != null) {
                                roles = roleResponse
                                    .map<String>(
                                      (item) => item['name'] as String,
                                    )
                                    .toList();
                              }

                              // Fetch locations
                              final locResponse = await supabase
                                  .from('Locations')
                                  .select('title');
                              allLocations = (locResponse as List<dynamic>)
                                  .map((e) => e['title'].toString())
                                  .toList();

                              // SHOW BOTTOM SHEET
                              showModalBottomSheet(

                                context: context,
                                isScrollControlled: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                builder: (context) {
                                  return StatefulBuilder(
                                    builder: (context, setModalState) {
                                      return Padding(
                                        padding: EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          top: 20,
                                       
  
    bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                                        ),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              
                                               Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edit user",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                IconButton(
  onPressed: () {
    Navigator.pop(context);
  },
  padding: EdgeInsets.zero, // removes extra padding
  constraints: const BoxConstraints(), // keeps size compact
  icon: Container(
    width: 24,
    height: 24,
    decoration: const BoxDecoration(
      color: Color(0xFFE8EAF6), // light grey circle background
      shape: BoxShape.circle,
    ),
    child: const Icon(
      Icons.close,
      size: 16,
      color: Colors.black54, // X color
    ),
  ),
)

              ],
            ),
            const Divider(),
            const SizedBox(height: 25),
                                             Text('Username'.tr(),textAlign: TextAlign.left,style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),),
                                              TextField(
                                                controller: usernameController,
                                                decoration: InputDecoration(
                                                  hintText: "Enter name".tr(),
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                            Text('Role'.tr(),textAlign: TextAlign.left,style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),),
                                              DropdownButtonFormField<String>(
                                                value: selectedRole,
                                                decoration: InputDecoration(
                                                  hintText: "Select Role".tr(),
                                                  border: OutlineInputBorder(),
                                                ),
                                                items: roles
                                                    .map(
                                                      (role) =>
                                                          DropdownMenuItem(
                                                            value: role,
                                                            child: Text(role),
                                                          ),
                                                    )
                                                    .toList(),
                                                onChanged: (val) =>
                                                    setModalState(
                                                      () => selectedRole = val,
                                                    ),
                                              ),
                                              SizedBox(height: 12),
                                              Text('Email'.tr(),textAlign: TextAlign.left,style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),),
                                              TextField(
                                                controller: emailController,
                                                decoration: InputDecoration(
                                                  hintText: "Enter Email".tr(),
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              SizedBox(height: 12),
                                               Text('Password'.tr(),textAlign: TextAlign.left,style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),),
                                              TextField(
                                                controller: passwordController,
                                                obscureText: true,
                                                decoration: InputDecoration(
                                                  hintText: "Enter Password".tr(),
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              SizedBox(height: 12),

                                              /// LOCATIONS DROPDOWN WITH MULTI-SELECT
                                             Text('location'.tr(),textAlign: TextAlign.left,style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),),
                                              TextField(
                                                controller: locationController,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  hintText: "select_locations".tr(),
                                                  border: OutlineInputBorder(),
                                                  suffixIcon: Icon(
                                                    Icons.arrow_drop_down,
                                                  ),
                                                ),
                                              //   onTap: () {
                                              //     showDialog(
                                              //       context: context,
                                              //       builder: (context) {
                                              //         return StatefulBuilder(
                                              //           builder: (context, setDialogState) {
                                                          
                                              //             return AlertDialog(
                                              //               title: Text(
                                              //                 "Select Locations",style: TextStyle(fontWeight: FontWeight.w800)
                                              //               ),
                                              //               content: SizedBox(
                                              //                 width: double
                                              //                     .maxFinite,
                                              //                 child: ListView(
                                              //                   shrinkWrap:
                                              //                       true,
                                              //                   children: allLocations.map((
                                              //                     location,
                                              //                   ) {
                                              //                     final isSelected =
                                              //                         selectedLocations
                                              //                             .contains(
                                              //                               location,
                                              //                             );
                                              //                     return CheckboxListTile(
                                              //                       tileColor: Colors.blue,
                                              //                       activeColor: Colors.blue,
                                              //                       title: Text(
                                              //                         location,
                                              //                       ),
                                              //                       value:
                                              //                           isSelected,
                                              //                       onChanged: (checked) {
                                              //                         setDialogState(() {
                                              //                           if (checked ==
                                              //                               true) {
                                              //                             selectedLocations.add(
                                              //                               location,
                                              //                             );
                                              //                           } else {
                                              //                             selectedLocations.remove(
                                              //                               location,
                                              //                             );
                                              //                           }
                                              //                         });
                                              //                       },
                                              //                     );
                                              //                   }).toList(),
                                              //                 ),
                                              //               ),
                                              //               actions: [
                                              //                 TextButton(
                                              //                   onPressed: () =>
                                              //                       Navigator.pop(
                                              //                         context,
                                              //                       ),
                                              //                   child: Text(
                                              //                     "Cancel",style: TextStyle(color: Colors.blue),
                                              //                   ),
                                              //                 ),
                                              //                 ElevatedButton(
                                              //                   onPressed: () {
                                              //                     Navigator.pop(
                                              //                       context,
                                              //                     );
                                              //                     setModalState(() {
                                              //                       locationController
                                              //                           .text = selectedLocations
                                              //                           .join(
                                              //                             ", ",
                                              //                           );
                                              //                     });
                                              //                   },
                                              //                   child: Text(
                                              //                     "Done",style: TextStyle(color: Colors.blue)
                                              //                   ),
                                              //                 ),
                                              //               ],
                                              //             );
                                              //           },
                                              //         );
                                              //       },
                                              //     );
                                              //   },
                                              onTap: () {
  showDialog(
    context: context,
    builder: (context) {
      // Local state for search query and filtered list
      String searchQuery = '';
      List<String> filteredLocations = List.from(allLocations);

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(
              "select_locations".tr(),
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔍 Search bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'search_locations'.tr(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        searchQuery = value.toLowerCase();
                        filteredLocations = allLocations
                            .where((location) => location
                                .toLowerCase()
                                .contains(searchQuery))
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  const Divider(),

                  // 📄 List of filtered checkboxes
                  Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: filteredLocations.map((location) {
                        final isSelected =
                            selectedLocations.contains(location);
                        return CheckboxListTile(
                         activeColor: const Color(0xFF0057FF),
                    
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
                  
                ],
                
              ),
            ),
             actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                      context,
                                                                    ),
                                                                child: Text(
                                                                  "Cancel".tr(),style: TextStyle(color: const Color(0xFF0057FF),)
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                    context,
                                                                  );
                                                                  setModalState(() {
                                                                    locationController
                                                                        .text = selectedLocations
                                                                        .join(
                                                                          ", ",
                                                                        );
                                                                  });
                                                                },
                                                                child: Text(
                                                                  "Done".tr(),style: TextStyle(color: const Color(0xFF0057FF),)
                                                                ),
                                                              ),
                                                            ],
          );
        },
        
      );
    },
  );
},

                                              ),

                                              SizedBox(height: 20,width: 200,),

                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
SizedBox(width: 220,),
ElevatedButton(
                                                onPressed: () async {
                                                  print(
                                                    "Username: ${usernameController.text}",
                                                  );
                                                  print(
                                                    "Email: ${emailController.text}",
                                                  );
                                                  print(
                                                    "Password: ${passwordController.text}",
                                                  );
                                                  print("Role: $selectedRole");
                                                  print(
                                                    "Locations: ${locationController.text}",
                                                  );

                                                  if (usernameController.text
                                                          .trim()
                                                          .isEmpty ||
                                                      emailController.text
                                                          .trim()
                                                          .isEmpty ||
                                                      selectedRole == null) {
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          'Please fill all the mandatory fields',
                                                        ),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  final supabase =
                                                      Supabase.instance.client;

                                                  try {
                                                    // ── 2. Resolve role name -> role_id ──────────────────────────────────────
                                                    final roleRow =
                                                        await supabase
                                                            .from('roles')
                                                            .select('id')
                                                            .eq(
                                                              'name',
                                                              selectedRole!,
                                                            )
                                                            .maybeSingle();

                                                    if (roleRow == null) {
                                                      throw Exception(
                                                        'Role “$selectedRole” not found',
                                                      );
                                                    }
                                                    final int roleId =
                                                        roleRow['id'] as int;

                                                    final id = userData['id']!;
                                                    // ── 3. Update the record in `profiles` ───────────────────────────────────
                                                    await supabase
                                                        .from('profiles')
                                                        .update({
                                                          'full_name':
                                                              usernameController
                                                                  .text
                                                                  .trim(),
                                                          'email':
                                                              emailController
                                                                  .text
                                                                  .trim(),
                                                          'role_id': roleId,
                                                        })
                                                        .eq('id', id);

                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Profile updated successfully',
                                                          ),
                                                        ),
                                                      );
                                                      Navigator.pop(context);
                                                    }
                                                  } catch (e) {
                                                    debugPrint(
                                                      'Error updating profile: $e',
                                                    );
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(
                                                        context,
                                                      ).showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            'Failed to update profile: $e',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  }

                                                  Navigator.pop(
                                                    context,
                                                  ); // Close bottom sheet here
                                                },
                                                child: Text("Edit User".tr(),style: TextStyle(color: const Color(0xFF0057FF),),),
                                              ),
                                              

                                                ],
                                              )
                                                      ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              );
                            },
                          ),

                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),

                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Confirm Delete",style: TextStyle(fontWeight: FontWeight.w800),),
                                  content: Text(
                                    "Are you sure you want to delete this user?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                      child: Text(
                                        "Cancel".tr(),
                                        style: TextStyle(color: Colors.blue),
                                      ),
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
                                        backgroundColor:const Color.fromARGB(255, 211, 55, 44),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text("Delete".tr()),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
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
}
