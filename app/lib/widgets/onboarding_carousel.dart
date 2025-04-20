import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingCarousel extends StatefulWidget {
  final List<Map<String, String>> pages;
  int currentPage = 0;

  OnboardingCarousel({
    super.key,
    required this.pages,
  });

  @override
  _OnboardingCarouselState createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  @override
  void initState() {
    super.initState();
  }

  void _onPageChanged(int index) {
    setState(() {
      widget.currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            itemCount: widget.pages.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return SplashContent(
                image: widget.pages[index]['image'],
                text: widget.pages[index]['text'],
              );
            },
          ),
        ),
        const SizedBox(height: 30),
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.pages.length,
              (index) => buildDot(index: index),
            ),
          ),
        ),
      ],
    );
  }

  Container buildDot({int? index}) {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: widget.currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: widget.currentPage == index
            ? const Color(0xFFB80F19)
            : const Color(0xFFE0313B),
        borderRadius: BorderRadius.circular(3),
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
        Text(
          "DonorX",
          style: GoogleFonts.dmSans(
            fontSize: 32,
            color: Color(0xFFB80F19),
            fontWeight: FontWeight.bold,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            widget.text!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        // const Spacer(flex: 2),
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
