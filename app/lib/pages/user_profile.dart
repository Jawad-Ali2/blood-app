import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red[600],
        toolbarHeight: 70,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, "edit-profile");
            },
          ),
          IconButton(
            padding: EdgeInsets.only(right: 8),
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(context, "settings");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const ProfilePic(
                image: "https://randomuser.me/api/portraits/women/2.jpg"),
            Text(
              "Jane Smith",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 25,
              ),
            ),
            StatsBar(
              bloodType: "A+",
              donations: 5,
              requests: 3,
            ),
            const Info(
              infoKey: "Location",
              info: "New York, NYC",
            ),
            const Info(
              infoKey: "Phone",
              info: "(239) 555-0108",
            ),
            const Info(
              infoKey: "CNIC",
              info: "34221-405-80006",
            ),
            const Info(
              infoKey: "Email",
              info: "jane@gmail.com",
            ),
            const Info(
              infoKey: "DOB",
              info: "08/01/2004",
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    super.key,
    required this.image,
    this.isShowPhotoUpload = false,
  });

  final String image;
  final bool isShowPhotoUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.only(top: 16.0),
      child: CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage(image),
      ),
    );
  }
}

class Info extends StatelessWidget {
  const Info({
    super.key,
    required this.infoKey,
    required this.info,
  });

  final String infoKey, info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              infoKey,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            Text(info),
          ],
        ),
      ),
    );
  }
}

class StatsBar extends StatelessWidget {
  final int donations;
  final int requests;
  final String bloodType;

  const StatsBar({
    super.key,
    required this.donations,
    required this.requests,
    required this.bloodType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatCard(
                title: "Group",
                bloodGroup: bloodType,
              ),
              StatCard(
                title: "Donated",
                count: donations,
              ),
              StatCard(
                title: "Requests",
                count: requests,
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "Last Donated: 20/01/2025",
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          )
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final int? count;
  final String? bloodGroup;

  const StatCard({
    super.key,
    required this.title,
    this.count,
    this.bloodGroup,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            bloodGroup ?? "$count",
            style: TextStyle(
              fontSize: 25,
              height: 1.1,
              fontWeight: FontWeight.bold,
              color: Colors.red[900],
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
