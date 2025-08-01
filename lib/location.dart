import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String?> showLocationBottomSheet(
  BuildContext context,
  String userId,
) async {
  final supabase = Supabase.instance.client;

  try {
    final userLocationResponse = await supabase
        .from('user_locations')
        .select('location_id')
        .eq('profile_id', userId);

    if (userLocationResponse == null || userLocationResponse.isEmpty) {
      return null;
    }

    List<int> locationIds = userLocationResponse
        .map<int>((item) => item['location_id'] as int)
        .toList();

    final locationResponse = await supabase
        .from('Locations')
        .select('title')
        .inFilter('id', locationIds);

    if (locationResponse == null || locationResponse.isEmpty) {
      return null;
    }

    List<String> locationTitles = locationResponse
        .map<String>((item) => item['title'] as String)
        .toList();

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? selectedLocation = AppData.selectedLocation;
        TextEditingController searchController = TextEditingController();
        ValueNotifier<List<String>> filteredList = ValueNotifier(
          locationTitles,
        );

        return StatefulBuilder(
          builder: (context, setState) {
            void filterLocations(String query) {
              filteredList.value = locationTitles
                  .where(
                    (title) =>
                        title.toLowerCase().contains(query.toLowerCase()),
                  )
                  .toList();
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          "Select Location",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                       IconButton(
                          
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), // Search Bar
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search location...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  filterLocations('');
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        filterLocations(value);
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 10),

                    // Location List with Radio
                    ValueListenableBuilder<List<String>>(
                      valueListenable: filteredList,
                      builder: (context, titles, _) {
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: titles.length,
                          separatorBuilder: (context, index) =>
                              const Divider(thickness: 2),
                          itemBuilder: (context, index) {
                            final title = titles[index];
                            return RadioListTile<String>(
                              value: title,
                              groupValue: selectedLocation,
                              title: Text(title),
                              onChanged: (value) async {
                                if (value != null) {
                                  await AppData.setLocation(value);
                                  AppData.selectedLocation = value;
                                   Navigator.pop(context, value);
                                }
                              },
                              activeColor:
                                  const Color(0xFF0057FF), // Selected radio button color
                              controlAffinity: ListTileControlAffinity
                                  .trailing, // Radio on the right
                            );
                          },
                        );
                      },
                    ),
                    const Divider(),
                  ],
                  
                ),
              ),
            );
          },
        );
      },
    );
  } catch (e) {
    print('Error fetching locations: $e');
    return null;
  }
}

//
// Future<String?> showLocationBottomSheet(BuildContext context, String userId) async {
//   final supabase = Supabase.instance.client;

//   try {
//     // Step 1: Fetch location_ids from user_locations for the given userId
//     final userLocationResponse = await supabase
//         .from('user_locations')
//         .select('location_id')
//         .eq('profile_id', userId);

//     if (userLocationResponse == null || userLocationResponse.isEmpty) {
//       return null;
//     }

//     // Step 2: Extract location_ids into a list
//     List<int> locationIds = userLocationResponse
//         .map<int>((item) => item['location_id'] as int)
//         .toList();

//     // Step 3: Fetch location titles from Locations where id in locationIds
//     final locationResponse = await supabase
//         .from('Locations')
//         .select('title')
//         .inFilter('id', locationIds);

//     if (locationResponse == null || locationResponse.isEmpty) {
//       return null;
//     }

//     // Step 4: Extract titles
//     List<String> locationTitles = locationResponse
//         .map<String>((item) => item['title'] as String)
//         .toList();

//     // Step 5: Show bottom sheet to select one location
//     return showModalBottomSheet<String>(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Padding(
//             padding: EdgeInsets.only(
//               left: 16,
//               right: 16,
//               top: 16,
//               bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//             ),
//             child: SingleChildScrollView(
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Select Location",
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   const Divider(),

//                   // Show list of locations
//                   ...locationTitles.map(
//                     (title) => ListTile(
//                       title: Text(title),
//                       onTap: () async {
//                         await AppData.setLocation(title);
//                         AppData.selectedLocation = title;
//                         Navigator.pop(context, title); // return selected
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   } catch (e) {
//     print('Error fetching locations: $e');
//     return null;
//   }
// }

// app_data.dart
class AppData {
  static int? selectedLocationId;
  static String? selectedLocation;
  static Future<void> setLocation(String title) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('Locations')
        .select('id')
        .eq('title', title)
        .maybeSingle();

    selectedLocationId = response?['id'] as int?;
    print(selectedLocationId);
  }
}
