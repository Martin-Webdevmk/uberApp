import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/methods/common_methods.dart';
import 'package:users_app/pages/home_page.dart';
import 'package:users_app/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';


// ----------- SignUpScreen WIDGET -----------
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
// ----------- STATE CLASS -----------
class _SignUpScreenState extends State<SignUpScreen>
{
  // Controllers for the text fields
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  // Instance of your helper class
  CommonMethods cMethods = CommonMethods();

  // Step 1: Check internet connection before signup
  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context); // Internet check
    signUpFormValidation(); // If ok, validate the form

  }

  // Step 2: Validate the form
  signUpFormValidation()

  {
    if (userNameTextEditingController.text.trim().length <3)
    {
      cMethods.displaySnackBar("your name must be at least 4 or more characters", context);
    }
    else if(userPhoneTextEditingController.text.trim().length <10)
    {
      cMethods.displaySnackBar("your phone must be Correct", context);
    }

    else if(!emailTextEditingController.text.contains("@"))
    {
      cMethods.displaySnackBar("Please write valid email.", context);
    }
    else if(passwordTextEditingController.text.trim().length < 5)
    {
      cMethods.displaySnackBar("Your password must be atleast 6 or more characters.", context);
    }
    else {
      registerNewUser();  // If valid → proceed to register
    }
  }

  // Step 3: Register new user in Firebase
  registerNewUser() async
  {
    // prikazuva dijalog за вчитување додека се врши регистрацијата
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing dialog manually
      builder: (BuildContext context) => LoadingDialog(messageText: "Registering your account..."),
    );

    // Создавање нов корисник со емаил и лозинка користејќи Firebase Authentication
    //final User? userFirebase = ...: Го чува новиот создаден Firebase корисник во променливата userFirebase
    final User? userFirebase = (
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextEditingController.text.trim(), //Го зема емаил податокот внесени од корисникот
          password: passwordTextEditingController.text.trim(),
        ).catchError((errorMsg) // If error occurs
        {

          Navigator.pop(context);// Го затвора LoadingDialog доколку има некој ерор.
          cMethods.displaySnackBar(errorMsg.toString(), context);
        })
    ).user; // If successful, get Firebase User object

    //If succesfully user is registered close the dialog.
    if(!context.mounted) return;
    Navigator.pop(context);

    // Save extra user data in Firebase Database
    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);

    Map userDataMap = {
      "name": userNameTextEditingController.text.trim(),
      "email": emailTextEditingController.text.trim(),
      "phone": userPhoneTextEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockedStatus": "no", // By default user is active
    };

    usersRef.set(userDataMap); //It will save the data to the database. || Save data under "users/{uid}"

    Navigator.push(context, MaterialPageRoute(builder: (c)=> HomePage()));  // After successful signup → navigate to HomePage
  }



  // ----------- BUILD UI -----------
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SingleChildScrollView( // Scroll in case of small screen
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

            Image.asset(
              "assets/images/logo.png"  // App logo
            ),
            
              Text(
                "Create a User\'s Account",
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

                      // User Name input
                      TextField(
                          controller: userNameTextEditingController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: "User Name",
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

                      // Phone input
                      TextField(
                        controller: userPhoneTextEditingController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "User Phone",
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
                        obscureText: true, // Hide password
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

                      // ---------- Sign Up Button ----------

                      ElevatedButton(
                        onPressed:()
                        {
                          checkIfNetworkIsAvailable() // First function called when button pressed
;                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: EdgeInsets.symmetric(horizontal: 80, vertical: 10,)

                        ),
                        child: const Text(
                          "Sign Up"
                        ),
                      ),
                    ],
                  ),
              ),

              // ---------- Redirect to Login ----------
              TextButton(
                onPressed: ()
                {
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> LoginScreen()));
                },
                  child: Text(
                    "Already have an Account? Login Here",
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
