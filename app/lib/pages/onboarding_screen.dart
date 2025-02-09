import 'package:app/pages/signup.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      "text": "Welcome to DonorX, saving lives starts here!",
      "image":
          "https://cdni.iconscout.com/illustration/premium/thumb/blood-supply-support-illustration-download-in-svg-png-gif-file-formats--donation-awareness-lifesaving-contributions-global-drive-volunteer-donors-world-donor-day-pack-medical-equipment-illustrations-8778430.png"
    },
    {
      "text":
          "Find credible blood donors and recipients nearby \nwith just a few taps.",
      "image":
          "https://cdni.iconscout.com/illustration/premium/thumb/blood-donor-appreciation-illustration-download-in-svg-png-gif-file-formats--donation-awareness-lifesaving-contributions-global-drive-volunteer-donors-world-day-pack-medical-equipment-illustrations-8778431.png"
    },
    {
      "text":
          "Create a post to instantly connect with donors \nand save lives faster!",
      "image":
          "https://cdni.iconscout.com/illustration/premium/thumb/blood-donation-awareness-illustration-download-in-svg-png-gif-file-formats--lifesaving-contributions-global-drive-volunteer-donors-supply-support-donor-appreciation-world-day-pack-medical-equipment-illustrations-8778426.png?f=webp"
    },
    {
      "text":
          "Get automatic notifications when donors \nor recipients are available near you.",
      "image":
          "https://cdni.iconscout.com/illustration/premium/thumb/lifesaving-contributions-illustration-download-in-svg-png-gif-file-formats--blood-donation-awareness-global-drive-volunteer-donors-world-donor-day-pack-medical-equipment-illustrations-8778427.png"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Expanded(
                flex: 3,
                child: PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: splashData.length,
                  itemBuilder: (context, index) => SplashContent(
                    image: splashData[index]["image"],
                    text: splashData[index]['text'],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: <Widget>[
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          splashData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 5),
                            height: 6,
                            width: currentPage == index ? 20 : 6,
                            decoration: BoxDecoration(
                              color: currentPage == index
                                  ? const Color(0xFFE0313B)
                                  : const Color(0xFFD8D8D8),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Placeholder()));
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFFFFFFFF),
                          // backgroundColor: const Color(0xFFE0313B), RED
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: const RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black, width: 1.5),
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      SizedBox(
                        height: 8,
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
                          minimumSize: const Size(double.infinity, 48),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        child: const Text("Sign Up"),
                      ),
                      const Spacer(),
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

class SplashContent extends StatefulWidget {
  const SplashContent({
    super.key,
    this.text,
    this.image,
  });

  final String? text, image;

  @override
  State<SplashContent> createState() => _SplashContentState();
}

class _SplashContentState extends State<SplashContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Spacer(),
        const Text(
          "DonorX",
          style: TextStyle(
            fontSize: 32,
            color: Color(0xFFB80F19),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          widget.text!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const Spacer(flex: 2),
        Image.network(
          widget.image!,
          fit: BoxFit.cover,
          height: 265,
          width: 320,
        ),
      ],
    );
  }
}
