import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:medicineapp/dashboard.dart';
import 'package:medicineapp/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> saveFcmToken(userId) async {
    final token = await FirebaseMessaging.instance.getToken();
    print(token);
    if (token != null && userId != null) {
      await Supabase.instance.client
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            // ✅ Wrap everything in Form
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Image.asset(
                    'assets/images/medicineicon.png',
                    height: 100,
                  ),
                ),
                const SizedBox(height: 80),
                // Welcome back text
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  'Glad to see you, Again!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.normal,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Enter your password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure; // Toggle visibility
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                // Forgot password
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton(
                //     onPressed: () {
                //       // Add forgot password logic
                //     },
                //     child: const Text('Forgot Password?'),
                //   ),
                // ),
                const SizedBox(height: 30),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        print(email);
                        print(password);

                        try {
                          final response = await Supabase.instance.client.auth
                              .signInWithPassword(
                                email: email,
                                password: password,
                              );

                          if (response.user != null) {
                            final userId = response.user!.id;
                            print(userId);

                            final userEmail = email;

                            print("User ID: $userId");
                            print("User Email: $userEmail");

                            // ✅ Send login email using Edge Function
                            final emailResponse = await Supabase
                                .instance
                                .client
                                .functions
                                .invoke(
                                  'send-email',
                                 body: {
  "to": userEmail,
  "subject": "Welcome Back",
  "html": "<p>Hello,</p><p>You have successfully logged in.</p>",
},
                                    
                                );

                            print("Email response: ${emailResponse.data}");

                            saveFcmToken(userId);
                          
                            final profileData = await Supabase.instance.client
                                .from('profiles')
                                .select()
                                .eq('id', userId)
                                .single();

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardPage(
                                  userId: userId,
                                  // or profileData: profileData,
                                ),
                              ),
                            );
                          } else {
                            // ❌ Sign-in failed (user is null)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Sign-in failed. Please check your credentials.",
                                ),
                              ),
                            );
                          }
                        } catch (error) {
                          print(error);
                          // ❌ Error during sign-in
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Error: User Not found ${error.toString()}",
                              ),
                            ),
                          );
                        }
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign up option
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     const Text("Don't have an account?"),
                //     TextButton(
                //       onPressed: () {
                //         // Add navigation to sign up
                //       },
                //       child: const Text('Sign Up'),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
