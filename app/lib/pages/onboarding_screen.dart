import 'package:app/pages/signin.dart';
import 'package:app/pages/signup.dart';
import 'package:app/widgets/onboarding_carousel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<Map<String, String>> splashData = [
    {
      "text": "Welcome to DonorX, saving lives starts here!",
      "image":
          "https://cdni.iconscout.com/illustration/premium/thumb/blood-supply-support-illustration-download-in-svg-png-gif-file-formats--donation-awareness-lifesaving-contributions-global-drive-volunteer-donors-world-donor-day-pack-medical-equipment-illustrations-8778430.png"
    },
    {
      "text":
          "Find credible blood donors and recipients nearby in just a few taps.",
      "image":
          "https://cdni.iconscout.com/illustration/premium/thumb/blood-donor-appreciation-illustration-download-in-svg-png-gif-file-formats--donation-awareness-lifesaving-contributions-global-drive-volunteer-donors-world-day-pack-medical-equipment-illustrations-8778431.png"
    },
    {
      "text":
          "Create a post to instantly connect with donors and save lives faster!",
      "image":
          "https://cdni.iconscout.com/illustration/premium/thumb/blood-donation-awareness-illustration-download-in-svg-png-gif-file-formats--lifesaving-contributions-global-drive-volunteer-donors-supply-support-donor-appreciation-world-day-pack-medical-equipment-illustrations-8778426.png?f=webp"
    },
    {
      "text": "Get notified when donors or recipients are available near you.",
      "image":
          "https://cdni.iconscout.com/illustration/premium/thumb/lifesaving-contributions-illustration-download-in-svg-png-gif-file-formats--blood-donation-awareness-global-drive-volunteer-donors-world-donor-day-pack-medical-equipment-illustrations-8778427.png"
    }
  ];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double verticalPadding = screenSize.height * 0.05;
    final double horizontalPadding = screenSize.width * 0.1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: screenSize.height * 0.03,
              ),
              Expanded(
                flex: 3,
                child: OnboardingCarousel(
                  pages: splashData,
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: verticalPadding * 0.5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFFFFFFF),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: screenSize.height * 0.02,
                          ),
                          minimumSize:
                              Size(double.infinity, screenSize.height * 0.06),
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenSize.width * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: screenSize.height * 0.015,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignupPage()));
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFB80F19),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: screenSize.height * 0.02,
                          ),
                          minimumSize:
                              Size(double.infinity, screenSize.height * 0.06),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: screenSize.width * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(height: screenSize.height * 0.02),
                    ],
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
