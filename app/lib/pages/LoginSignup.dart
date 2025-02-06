import 'package:flutter/material.dart';

// LOGIN AND SIGNUP PAGE
class LoginSignup extends StatefulWidget {
  const LoginSignup({super.key});

  @override
  Assignment1TState createState() => Assignment1TState();
}

class Assignment1TState extends State<LoginSignup> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Column(
          children: [
            // LOGO
            Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(20),
                  // border: Border(top: BorderSide(width: 2)),
                  image: DecorationImage(
                    image: AssetImage("assets/images/bloodLogo.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // BUTTONS OPTION PANEL
            Container(
              // color: Colors.white,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.white),
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.all(20),
              width: screenWidth * 0.8,
              child: Row(
                children: [
                  buildToggleButton("Login", isLogin, () {
                    setState(() {
                      isLogin = true;
                    });
                  }),
                  buildToggleButton("Signup", !isLogin, () {
                    setState(() {
                      isLogin = false;
                    });
                  }),
                ],
              ),
            ),

            // FORM
            Stack(clipBehavior: Clip.none, children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    EdgeInsets.only(left: 25, right: 25, top: 25, bottom: 50),
                // height: 275,
                width: screenWidth * 0.8,
                // color: Colors.white70,
                child: Column(
                  children: isLogin ? buildLoginFields() : buildSignupFields(),
                ),
              ),
              Positioned(
                bottom: -22.5,
                left: 100,
                right: 100,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  ),
                  onPressed: () {},
                  child: Text(
                    isLogin ? "Sign In" : "Sign Up",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              )
            ]),

            // LOGIN OPTIONS
            isLogin
                ? Container(
                    margin: EdgeInsets.symmetric(vertical: 45),
                    child: Column(
                      children: [
                        Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox.fromSize(
                          size: Size(10, 5),
                        ),
                        Text(
                          "---- OR ----",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w900),
                        ),
                        SizedBox.fromSize(
                          size: Size(10, 5),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            socialLoginButton(
                                "https://cdn4.iconfinder.com/data/icons/logos-brands-7/512/google_logo-google_icongoogle-512.png"),
                            SizedBox.fromSize(
                              size: Size.square(8),
                            ),
                            socialLoginButton(
                                "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/2023_Facebook_icon.svg/768px-2023_Facebook_icon.svg.png"),
                          ],
                        )
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.red[900] : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildSignupFields() {
    List<Widget> signupFields = [
      buildTextField("Username", Icons.person),
      buildTextField("Email", Icons.mail_outline),
      buildTextField("Password", Icons.lock_outline, isPassword: true),
      buildTextField("Confirm Password", Icons.lock_outline, isPassword: true),
    ];

    return signupFields;
  }

  List<Widget> buildLoginFields() {
    List<Widget> loginFields = [
      buildTextField("Username", Icons.person),
      buildTextField("Password", Icons.lock_outline, isPassword: true),
    ];

    return loginFields;
  }

  Widget buildTextField(String hintText, IconData icon,
      {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: Icon(icon, color: Colors.black87),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget socialLoginButton(String url) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(url),
      ),
    );
  }
}
