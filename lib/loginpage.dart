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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: BackButton(
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => MyHomePage()),
//             );
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             // ✅ Wrap everything in Form
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   child: Image.asset(
//                     'assets/images/medicineicon.png',
//                     height: 100,
//                   ),
//                 ),
//                 const SizedBox(height: 80),
//                 // Welcome back text
//                 const Text(
//                   'Welcome back!',
//                   style: TextStyle(
//                     fontSize: 30,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const Text(
//                   'Glad to see you, Again!',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.normal,
//                     color: Colors.black54,
//                   ),
//                 ),
//                 const SizedBox(height: 40),

//                 // Email field
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(
//                     labelText: 'Enter your email',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.email),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your email';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),

//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscure,
//                   decoration: InputDecoration(
//                     labelText: 'Enter your password',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.lock),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscure ? Icons.visibility_off : Icons.visibility,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscure = !_obscure; // Toggle visibility
//                         });
//                       },
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your password';
//                     }
//                     return null;
//                   },
//                 ),
//                 // Forgot password
//                 // Align(
//                 //   alignment: Alignment.centerRight,
//                 //   child: TextButton(
//                 //     onPressed: () {
//                 //       // Add forgot password logic
//                 //     },
//                 //     child: const Text('Forgot Password?'),
//                 //   ),
//                 // ),
//                 const SizedBox(height: 30),

//                 // Login button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () async {
//                       if (_formKey.currentState!.validate()) {
//                         final email = _emailController.text.trim();
//                         final password = _passwordController.text.trim();
//                         print(email);
//                         print(password);

//                         try {
//                           final response = await Supabase.instance.client.auth
//                               .signInWithPassword(
//                                 email: email,
//                                 password: password,
//                               );

//                           if (response.user != null) {
//                             final userId = response.user!.id;
//                             print(userId);

//                             final userEmail = email;

//                             print("User ID: $userId");
//                             print("User Email: $userEmail");

//                             // ✅ Send login email using Edge Function
//                             final emailResponse = await Supabase
//                                 .instance
//                                 .client
//                                 .functions
//                                 .invoke(
//                                   'send-email',
//                                  body: {
//   "to": userEmail,
//   "subject": "Welcome Back",
//   "html": "<p>Hello,</p><p>You have successfully logged in.</p>",
// },
                                    
//                                 );

//                             print("Email response: ${emailResponse.data}");

//                             saveFcmToken(userId);
                          
//                             final profileData = await Supabase.instance.client
//                                 .from('profiles')
//                                 .select()
//                                 .eq('id', userId)
//                                 .single();

//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => DashboardPage(
//                                   userId: userId,
//                                   // or profileData: profileData,
//                                 ),
//                               ),
//                             );
//                           } else {
//                             // ❌ Sign-in failed (user is null)
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   "Sign-in failed. Please check your credentials.",
//                                 ),
//                               ),
//                             );
//                           }
//                         } catch (error) {
//                           print(error);
//                           // ❌ Error during sign-in
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                 "Error: User Not found ${error.toString()}",
//                               ),
//                             ),
//                           );
//                         }
//                       }
//                     },

//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text(
//                       'Login',
//                       style: TextStyle(fontSize: 18, color: Colors.white),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Sign up option
//                 // Row(
//                 //   mainAxisAlignment: MainAxisAlignment.center,
//                 //   children: [
//                 //     const Text("Don't have an account?"),
//                 //     TextButton(
//                 //       onPressed: () {
//                 //         // Add navigation to sign up
//                 //       },
//                 //       child: const Text('Sign Up'),
//                 //     ),
//                 //   ],
//                 // ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
@override
  Widget build(BuildContext context) {

    return Scaffold(
     backgroundColor: const Color(0xFFF1F4F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F5FB),
        elevation: 0,
        // leading: Padding(
        //   padding: const EdgeInsets.only(left: 16.0),
         
        // ),
        toolbarHeight: 30,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            
              children: [

               Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
             
                // Logo on the left
                Image.asset(
                  'assets/images/medicineicon1.png',
                  height: 80,
                ),
SizedBox(width: 20,),
                // Back button on the right
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MyHomePage()),
                    );
                  },
                  icon: const Icon(Icons.arrow_back, color: const Color(0xFF0066FF),),
                  label: const Text("Back", style: TextStyle(color: const Color(0xFF0066FF),)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:const Color(0xFFF1F4F9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    
                    ),
                    side: BorderSide(color:const Color(0xFF0066FF),width: 1),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                   
                  ),
                ),
               
              ],
              
              
            ),
            
          
 const SizedBox(height: 50), 
Column(
  mainAxisAlignment: MainAxisAlignment.start,
  crossAxisAlignment: CrossAxisAlignment.start,
  
  children: [
SizedBox(height: 10,),
 
                // Welcome Text
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0057FF),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Glad to see you, Again!',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF79808B),
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'email@gmail.com',
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email, color:Color(0xFF4F4F4F),),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color:  Color(0xFF4F4F4F),),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFF4F4F4F),),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock,color: Color(0xFF4F4F4F),),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                       color: Color(0xFF4F4F4F),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFF4F4F4F),),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFF4F4F4F)),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter your password' : null,
                ),
                const SizedBox(height: 40),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();

                        try {
                          final response = await Supabase.instance.client.auth
                              .signInWithPassword(email: email, password: password);

                          if (response.user != null) {
                            final userId = response.user!.id;

                            await Supabase.instance.client.functions.invoke(
                              'send-email',
                              body: {
                                "to": email,
                                "subject": "Welcome Back",
                                "html": "<p>Hello,</p><p>You have successfully logged in.</p>",
                              },
                            );
                             //saveFcmToken(userId);

                            final profileData = await Supabase.instance.client
                                .from('profiles')
                                .select()
                                .eq('id', userId)
                                .single();

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardPage(userId: userId),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Sign-in failed. Please check your credentials."),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: ${e.toString()}")),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0057FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                 ],
)
              ],
            ),
          ),
        ),
      ),
    );
  }
}