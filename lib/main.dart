import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:medicineapp/Splashscreen.dart';
import 'package:medicineapp/appointments.dart';
import 'package:medicineapp/firebase_options.dart';

import 'package:medicineapp/warehouse.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'loginpage.dart'; // or your app's root widget
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();


// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // Handle background message here
//   print("📩 FCM background message: ${message.notification?.title}");
// }

// v
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android Initialization
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // Ensure this icon exists

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,

    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.actionId == 'approve_action') {
        // ✅ Call the function to approve the appointment
        await approveLatestAppointment();
      }
    },
  
  );

  // Ask for permission (Android 13+)
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform
 
);
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://vsvueqtgulraaczqnnvh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzdnVlcXRndWxyYWFjenFubnZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDAwNDQ5OTMsImV4cCI6MjAxNTYyMDk5M30.umGVRqypGULFtZUXemNtANCGns-a2o4E8zSbnrZbldg',
  );
   await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('es'), Locale('en')],
      path: 'assets/lang', 
      fallbackLocale: Locale('es'),
      child: MyApp(),
    ),
  );

  
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: context.locale,
  supportedLocales: context.supportedLocales,
  localizationsDelegates: context.localizationDelegates,
      title: 'MyClinicMD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial', // You can use a custom font if needed
      ),
      // home: const MyHomePage(),
      home: splashscreen(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 80,),
             Container(
              child: Image.asset(
                'assets/images/Group.png',
                height: 220,
              ),
            ),
            SizedBox(height: 70,),
            Text('MyClinic MD'.tr(),style: TextStyle(fontSize: 32,fontWeight: FontWeight.w900),),
            SizedBox(height: 20,),
            Text('A Comprehensive Clinic Care'.tr(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.grey),),
       
            Text('Management Services'.tr(),style: TextStyle(fontSize: 15,fontWeight: FontWeight.w500,color: Colors.grey),),
            // Container(
            //   child: Image.asset(
            //     'assets/images/medicineimage.png',
            //     height: 300,
            //   ),
            // ),

            SizedBox(height: 30),

            SizedBox(
  width: 350, // Set desired width
  height: 55, // Set desired height
  child:ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0057FF),
               
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child:  Text(
                "Let's Get In".tr(),
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),)
          ],
        ),
      ),
    );
  }
}

Future<void> approveLatestAppointment() async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) return;

  try {
    // 1. Get latest appointment (assuming by created_at)
    final latest = await supabase
        .from('Appoinments')
        .select('id,email_address, first_name, service')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (latest != null) {
      final appointmentId = latest['id'];
 final email = latest['email_address'];
      final name = latest['first_name'] ?? '';
      final service = latest['service'] ?? 'your appointment';

      // 2. Update isApproved
      await supabase
          .from('Appoinments')
          .update({'isApproved': true})
          .eq('id', appointmentId);

      print("✅ Appointment approved via notification.");
      final emailResponse = await supabase.functions.invoke(
        'send-email', // ← replace with your edge function name
        body: {
          "to": email,
          "subject": "Your Appointment is Approved",
          "html": """
            <p>Hi $name,</p>
            <p>Your appointment for <strong>$service</strong> has been approved.</p>
            <p>We look forward to seeing you!</p>
            <p>— The Clinic Team</p>
          """,
        },
      );

      print("📧 Email sent: ${emailResponse.data}");
    
    }
  } catch (e) {
    print("❌ Error approving appointment: $e");
  }
}
