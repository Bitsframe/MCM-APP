import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String?> showLocationBottomSheet(BuildContext context) async {
  final supabase = Supabase.instance.client;

  final response = await supabase.from('Locations').select('title');

  if (response == null || response.isEmpty) {
    return null;
  }

  List<String> locationTitles = response
      .map<String>((item) => item['title'] as String)
      .toList();

  // Step 2: Show bottom sheet
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Location",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(),

                // Step 3: Dynamically build list of locations
                ...locationTitles.map(
                  (title) => ListTile(
                    title: Text(title),
                    onTap: () async {
                      await AppData.setLocation(title);
                      AppData.selectedLocation = title;
                      Navigator.pop(context, title);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

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
