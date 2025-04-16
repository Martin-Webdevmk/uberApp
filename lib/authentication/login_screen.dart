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
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);
    signInFormValidation();

  }

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
       signInUser();
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
    ).catchError((errorMsg)
    {
    Navigator.pop(context);// Го затвора LoadingDialog доколку има некој ерор.
    cMethods.displaySnackBar(errorMsg.toString(), context);
    })
    ).user;

    //If succesfully user is registered close the dialog.
    if(!context.mounted) return;
    Navigator.pop(context);

    if(userFirebase != null)
    {
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child("users").child(userFirebase.uid);
      usersRef.once().then((snap)
      {
        if(snap.snapshot.value != null)
          {
            if ((snap.snapshot.value as Map)["blockedStatus"] == "no")
            {
              userName = (snap.snapshot.value as Map)["name"];
              Navigator.push(context, MaterialPageRoute(builder: (c)=> HomePage()));
            }
            else
            {
              FirebaseAuth.instance.signOut();
              cMethods.displaySnackBar("you are blocked.Contact admin: info@webdevmk.com ", context);
            }
          }


        else
          {
            FirebaseAuth.instance.signOut();
            cMethods.displaySnackBar("your record do not exists as a User", context);
          }

      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              Image.asset(
                  "assets/images/logo.png"
              ),

              Text(
                "Login as a user",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              //Text Fields
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children:  [

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

                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: true,
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

                    ElevatedButton(
                      onPressed:()
                      {
                        checkIfNetworkIsAvailable();
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

              //textbutton
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
