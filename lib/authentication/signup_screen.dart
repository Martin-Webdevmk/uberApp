import 'package:flutter/material.dart';
import 'package:users_app/authentication/login_screen.dart';
import 'package:users_app/methods/common_methods.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
{
  TextEditingController userNameTextEditingController = TextEditingController();
  TextEditingController userPhoneTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  CommonMethods cMethods = CommonMethods();

  checkIfNetworkIsAvailable()
  {
    cMethods.checkConnectivity(context);
    signUpFormValidation();

  }

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
      //register user
    }
  }



    @override
  Widget build(BuildContext context)
  {
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
                "Create a User\'s Account",
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
                          checkIfNetworkIsAvailable()
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

              //textbutton
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
