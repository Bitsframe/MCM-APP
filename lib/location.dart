import 'package:flutter/material.dart';

Future<String?> showLocationBottomSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true, // Allow scrolling on small screens
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
              mainAxisSize: MainAxisSize.min, // Wrap content height
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Location",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(),

                ListTile(
                  title: const Text("Clinica San Miguel Fondren"),
                  onTap: () => Navigator.pop(context, "Clinica San Miguel Fondren"),
                ),
                ListTile(
                  title: const Text("Houston Central"),
                  onTap: () => Navigator.pop(context, "Houston Central"),
                ),
                ListTile(
                  title: const Text("Pasadena"),
                  onTap: () => Navigator.pop(context, "Pasadena"),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
