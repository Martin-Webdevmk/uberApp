import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:users_app/authentication/signup_screen.dart';
import 'package:users_app/global/global_var.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/widgets/loading_dialog.dart';

import '../pages/home_page.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
{
  // Controllers for text fields (email & password inputs)
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  // Instance of CommonMethods (for snackbars, connectivity checks, etc.)
  CommonMethods cMethods = CommonMethods();

  // Step 1: Check if device has internet before logging in
  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context); // Calls method to check internet
    signInFormValidation(); //After that, validate form

  }

  // Step 2: Validate the form (email & password)
  signInFormValidation()
  {

    if(!emailTextEditingController.text.contains("@"))
    {
      cMethods.displaySnackBar("Please write valid email.", context);
    }
    else if(passwordTextEditingController.text.trim().length < 5)
    {
      cMethods.displaySnackBar("Your password must be atleast 6 or more characters.", context);
    }
    else {
       signInUser(); // If everything is valid → attempt login
    }
  }


  signInUser() async {
    // prikazuva dijalog за вчитување додека се врши регистрацијата
    showDialog(
      context: context,
      barrierDismissible: false,// Не дозволува затворање на дијалогот додека не заврши регистрацијата
      builder: (BuildContext context) => LoadingDialog(messageText: "Allowing you to Login..."),
    );

    // Создавање нов корисник со емаил и лозинка користејќи Firebase Authentication
    //final User? userFirebase = ...: Го чува новиот создаден Firebase корисник во променливата userFirebase
    final User? userFirebase = (
        await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(), //Го зема емаил податокот внесени од корисникот
        password: passwordTextEditingController.text.trim(),
    ).catchError((errorMsg) //If error occurs during login
    {
    Navigator.pop(context);// Го затвора LoadingDialog.
    cMethods.displaySnackBar(errorMsg.toString(), context); // Show error in snack bar;
    })
    ).user; // If successful, get the Firebase User object

    // Close loading dialog once login attempt finished
    if(!context.mounted) return;
    Navigator.pop(context);

    // If user successfully logged in (userFirebase != null)
    if(userFirebase != null)
    {
      // Check if user exists in "users" node in Firebase Realtime DB
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase.uid);
      usersRef.once().then((snap)
      {
        if(snap.snapshot.value != null) //If user data exists in DB
          {
          // Check if user is not blocked
          if ((snap.snapshot.value as Map)["blockedStatus"] == "no")
            {
              // Save user name globally
              userName = (snap.snapshot.value as Map)["name"];
              // Navigate to HomePage
              Navigator.push(context, MaterialPageRoute(builder: (c)=> HomePage()));
            }
            else //If user is blocked
            {
              FirebaseAuth.instance.signOut(); // Force logout
              cMethods.displaySnackBar("you are blocked.Contact admin: info@webdevmk.com ", context);
            }
          }


        else //if user not found in database;
          {
            FirebaseAuth.instance.signOut(); // Force logout
            cMethods.displaySnackBar("your record do not exists as a User", context);
          }

      });
    }
  }


  // ----------- BUILD METHOD -----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView( // Scroll in case of small screen
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              Image.asset(
                  "assets/images/logo.png" // App logo
              ),

              Text(
                "Login as a user", // Title
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // ---------- Text Fields ----------
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children:  [
                    // Email input
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "User Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),
                    // Password input
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true, // hide password
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Password",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32,),

                    // ---------- Login Button ----------

                    ElevatedButton(
                      onPressed:()
                      {
                        checkIfNetworkIsAvailable(); // First function when login button clicked
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10,)

                      ),
                      child: const Text(
                          "Login"
                      ),
                    ),


                  ],
                ),
              ),
              const SizedBox(height: 22,),

              // ---------- Redirect to Sign Up ----------
              TextButton(
                onPressed: ()
                {
                  Navigator.push(context, MaterialPageRoute(builder: (c)=> SignUpScreen()));
                },
                child: Text(
                  "Dont\'t have an Account? Register Here",
                  style: TextStyle(
                      color: Colors.grey
                  ),
                ),
              ),
            ],

          ),
        ),
      ),
    );
  }
}
