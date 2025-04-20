import 'package:app/core/enums/app_routes.dart';
import 'package:app/core/storage/secure_storage.dart';
import 'package:app/services/auth_services.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:app/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class DonorHomePage extends StatelessWidget {
  DonorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BloodAppBar(),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HomeHeader(),
            DonorBanner(),

            // Quick Actions Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ViewRequestsButton(
                            screenWidth: screenWidth / 2 - 24),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: UpdateStatusButton(
                            screenWidth: screenWidth / 2 - 24),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Nearby Requests Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: NearbyRequestsCard(),
            ),

            // Active Donations Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Active Donation",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      // TextButton(
                      //   onPressed: () {
                      //     // Navigate to all active donations
                      //     context.push('/active-donations');
                      //   },
                      //   child: Text(
                      //     "View All",
                      //     style: TextStyle(
                      //       color: Colors.red[600],
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  ActiveDonationsList(),
                ],
              ),
            ),

            // My Donations Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "My Donations",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to all donations
                          context.push('/donor-history');
                        },
                        child: Text(
                          "View All",
                          style: TextStyle(
                            color: Colors.red[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  MyDonationsList(),
                ],
              ),
            ),

            DonorStatsBar(),
            const SizedBox(height: 12),

            // Donation Tips Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: DonationTipsCard(),
            ),

            SizedBox(height: 60), // Space for FAB
          ],
        ),
      ),

      // FLOATING BUTTON
      floatingActionButton: NavBarFloatingButton(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,

      // BOTTOM BAR
      bottomNavigationBar: BloodNavBar(),
    );
  }
}

// Donor-specific buttons
class ViewRequestsButton extends StatelessWidget {
  const ViewRequestsButton({super.key, required this.screenWidth});

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(screenWidth, 50),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 0.1),
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      onPressed: () {
        context.push(AppRoutes.bloodRequests.path);
      },
      icon: Icon(Icons.bloodtype),
      label: const Text(
        "View Requests",
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

class UpdateStatusButton extends StatelessWidget {
  const UpdateStatusButton({super.key, required this.screenWidth});

  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(screenWidth, 50),
        backgroundColor: Colors.white,
        foregroundColor: Colors.red[600],
        side: BorderSide(color: Colors.red.shade600, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      onPressed: () {
        // Navigate to update availability status
        context.push('/donor-profile');
      },
      icon: Icon(Icons.update),
      label: const Text(
        "Update Status",
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}

// Nearby Requests Card
class NearbyRequestsCard extends StatelessWidget {
  const NearbyRequestsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.red.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text(
                  "Nearby Blood Requests",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              "There are 3 blood requests within 5km of your location. Your blood type is needed!",
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Navigate to nearby requests map
                context.push('/nearby-requests');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("View Nearby Requests"),
            ),
          ],
        ),
      ),
    );
  }
}

// Update MyDonationsList to display donation history
class MyDonationsList extends StatelessWidget {
  const MyDonationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final donationService = DonationService();
    final _storage = GetIt.instance.get<SecureStorage>();

    return FutureBuilder<User?>(
      future: _storage.getUser(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Please log in to view your donation history",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        // Get the current user ID
        final userId = userSnapshot.data!.id;

        return FutureBuilder<List<Donation>>(
          // Fetch only donations made by the current user
          future: donationService.getUserDonations(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final donations = snapshot.data ?? [];

            if (donations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "You haven't made any donations yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            // Sort by donation date (newest first)
            final sortedDonations = [...donations]
              ..sort((a, b) => b.donationDate.compareTo(a.donationDate));

            // Limit to showing only the 2 most recent donations
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount:
                  sortedDonations.length > 2 ? 2 : sortedDonations.length,
              itemBuilder: (context, index) {
                final donation = sortedDonations[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.red[100],
                      child: Text(
                        donation.bloodType,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      "Donation at ${donation.hospitalName}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        "Date: ${donation.donationDate.toLocal().toString().split(' ')[0]}"),
                    trailing: Chip(
                      label: Text(
                        "${donation.units} units",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: Colors.green[600],
                    ),
                    onTap: () {
                      // Navigate to donation details
                      context.push('/donation-details/${donation.id}');
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// Active Donations List
class ActiveDonationsList extends StatelessWidget {
  const ActiveDonationsList({super.key});

  @override
  Widget build(BuildContext context) {
    final donationService = DonationService();
    final _storage = GetIt.instance.get<SecureStorage>();

    return FutureBuilder<User?>(
      future: _storage.getUser(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Please log in to view your active donations",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        // Get the current user ID
        final userId = userSnapshot.data!.id;

        return FutureBuilder<List<ActiveDonation>>(
          // Fetch active donations for the current user
          future: donationService.getActiveUserDonations(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            final activeDonations = snapshot.data ?? [];

            if (activeDonations.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "You don't have any active donation commitments",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            // Show active donations
            return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount:
                  activeDonations.length > 2 ? 2 : activeDonations.length,
              itemBuilder: (context, index) {
                final donation = activeDonations[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.orange.shade300, width: 1),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange[100],
                      child: Text(
                        donation.bloodType,
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      donation.patientName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("At ${donation.hospitalName}"),
                        Text(
                            "Appointment: ${donation.appointmentDate.toLocal().toString().split(' ')[0]}"),
                      ],
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Pending",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      // Navigate to active donation details
                      context.push('/active-donation/${donation.id}');
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(child: SearchField()),
          const SizedBox(width: 16),
          IconBtnWithCounter(
            svgSrc: filterIcon,
            press: () {},
          ),
          const SizedBox(width: 8),
          IconBtnWithCounter(
            svgSrc: bellIcon,
            numOfItem: 2,
            press: () {},
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: TextFormField(
        onChanged: (value) {},
        decoration: InputDecoration(
          filled: true,
          hintStyle: const TextStyle(color: Color(0xFF757575)),
          fillColor: const Color(0xFF979797).withOpacity(0.1),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          hintText: "Search blood requests",
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

class IconBtnWithCounter extends StatelessWidget {
  const IconBtnWithCounter({
    super.key,
    required this.svgSrc,
    this.numOfItem = 0,
    required this.press,
  });

  final String svgSrc;
  final int numOfItem;
  final GestureTapCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: press,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF979797).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.string(svgSrc),
          ),
          if (numOfItem != 0)
            Positioned(
              top: -3,
              right: 0,
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4848),
                  shape: BoxShape.circle,
                  border: Border.all(width: 1.5, color: Colors.white),
                ),
                child: Center(
                  child: Text(
                    "$numOfItem",
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class DonorBanner extends StatelessWidget {
  const DonorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "donor-profile");
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.red[800],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Your Blood Saves Lives",
              style: TextStyle(
                  height: 1.1,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              "Last donation: 3 months ago\nYou're eligible to donate again!",
              style: TextStyle(color: Colors.white, height: 1.1),
            ),
          ],
        ),
      ),
    );
  }
}

class DonorStatsBar extends StatelessWidget {
  const DonorStatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StatItem(title: "Total Donations", count: 8),
            StatItem(title: "Lives Saved", count: 24),
            StatItem(title: "Streak", count: 3),
          ],
        ),
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String title;
  final int count;

  const StatItem({super.key, required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "$count+",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
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
    );
  }
}

class DonationTipsCard extends StatelessWidget {
  const DonationTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text(
                  "Donation Tips",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            TipItem(
              icon: Icons.local_dining,
              text: "Eat iron-rich foods before donation",
            ),
            TipItem(
              icon: Icons.water_drop,
              text: "Stay hydrated before and after donating",
            ),
            TipItem(
              icon: Icons.fitness_center,
              text: "Avoid strenuous activity for 24 hours after",
            ),
            SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Navigate to donation tips page
                context.push('/donation-tips');
              },
              child: Text(
                "View All Tips",
                style: TextStyle(
                  color: Colors.red[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TipItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const TipItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.red[400], size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// SVG Icons from home_page.dart
const bellIcon =
    '''<svg width="15" height="20" viewBox="0 0 15 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M13.9645 15.8912C13.9645 16.1628 13.7495 16.3832 13.4844 16.3832H9.22765H9.21987H1.51477C1.2505 16.3832 1.03633 16.1628 1.03633 15.8912V10.7327C1.03633 7.08053 3.93546 4.10885 7.50043 4.10885C11.0645 4.10885 13.9645 7.08053 13.9645 10.7327V15.8912ZM7.50043 18.9381C6.77414 18.9381 6.18343 18.3327 6.18343 17.5885C6.18343 17.5398 6.18602 17.492 6.19034 17.4442H8.81052C8.81484 17.492 8.81743 17.5398 8.81743 17.5885C8.81743 18.3327 8.22586 18.9381 7.50043 18.9381ZM9.12488 3.2292C9.35805 2.89469 9.49537 2.48673 9.49537 2.04425C9.49537 0.915044 8.6024 0 7.50043 0C6.39847 0 5.5055 0.915044 5.5055 2.04425C5.5055 2.48673 5.64281 2.89469 5.87512 3.2292C2.51828 3.99204 0 7.06549 0 10.7327V15.8912C0 16.7478 0.679659 17.4442 1.51477 17.4442H5.15142C5.14883 17.492 5.1471 17.5398 5.1471 17.5885C5.1471 18.9186 6.20243 20 7.50043 20C8.79843 20 9.8529 18.9186 9.8529 17.5885C9.8529 17.5398 9.85117 17.492 9.84858 17.4442H13.4844C14.3203 17.4442 15 16.7478 15 15.8912V10.7327C15 7.06549 12.4826 3.99204 9.12488 3.2292Z" fill="#626262"/>
</svg>
''';
const filterIcon =
    '''<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" stroke="#525252"><g id="SVGRepo_bgCarrier" stroke-width="0"></g><g id="SVGRepo_tracerCarrier" stroke-linecap="round" stroke-linejoin="round"></g><g id="SVGRepo_iconCarrier"> <g id="style=linear"> <g id="filter-circle"> <path id="vector" d="M2 17.5H7" stroke="#525252" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"></path> <path id="vector_2" d="M22 6.5H17" stroke="#525252" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"></path> <path id="vector_3" d="M13 17.5H22" stroke="#525252" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"></path> <path id="vector_4" d="M11 6.5H2" stroke="#525252" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"></path> <path id="vector_5" d="M10 20.3999C8.34315 20.3999 7 19.0568 7 17.3999C7 15.743 8.34315 14.3999 10 14.3999C11.6569 14.3999 13 15.743 13 17.3999C13 19.0568 11.6569 20.3999 10 20.3999Z" stroke="#525252" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"></path> <path id="vector_6" d="M14 9.3999C15.6569 9.3999 17 8.05676 17 6.3999C17 4.74305 15.6569 3.3999 14 3.3999C12.3431 3.3999 11 4.74305 11 6.3999C11 8.05676 12.3431 9.3999 14 9.3999Z" stroke="#525252" stroke-width="1.5" stroke-miterlimit="10" stroke-linecap="round" stroke-linejoin="round"></path> </g> </g> </g></svg>''';

// Define Donation model for demonstration
class Donation {
  final String id;
  final String bloodType;
  final String hospitalName;
  final DateTime donationDate;
  final int units;

  Donation({
    required this.id,
    required this.bloodType,
    required this.hospitalName,
    required this.donationDate,
    required this.units,
  });
}

// ActiveDonation model
class ActiveDonation {
  final String id;
  final String bloodType;
  final String patientName;
  final String hospitalName;
  final DateTime appointmentDate;
  final String status;

  ActiveDonation({
    required this.id,
    required this.bloodType,
    required this.patientName,
    required this.hospitalName,
    required this.appointmentDate,
    required this.status,
  });
}

// Simple service to fetch donation data
class DonationService {
  Future<List<Donation>> getUserDonations(String userId) async {
    // In a real app, this would fetch from an API
    await Future.delayed(Duration(milliseconds: 800));

    return [
      Donation(
        id: '1',
        bloodType: 'A+',
        hospitalName: 'City General Hospital',
        donationDate: DateTime.now().subtract(Duration(days: 90)),
        units: 1,
      ),
      Donation(
        id: '2',
        bloodType: 'A+',
        hospitalName: 'Memorial Hospital',
        donationDate: DateTime.now().subtract(Duration(days: 180)),
        units: 1,
      ),
      Donation(
        id: '3',
        bloodType: 'A+',
        hospitalName: 'Community Medical Center',
        donationDate: DateTime.now().subtract(Duration(days: 270)),
        units: 2,
      ),
    ];
  }

  Future<List<ActiveDonation>> getActiveUserDonations(String userId) async {
    // In a real app, this would fetch from an API
    await Future.delayed(Duration(milliseconds: 800));

    return [
      ActiveDonation(
        id: '1',
        bloodType: 'O+',
        patientName: 'Sarah Johnson',
        hospitalName: 'City General Hospital',
        appointmentDate: DateTime.now().add(Duration(days: 2)),
        status: 'Pending',
      ),
      ActiveDonation(
        id: '2',
        bloodType: 'B-',
        patientName: 'Michael Williams',
        hospitalName: 'Memorial Medical Center',
        appointmentDate: DateTime.now().add(Duration(days: 5)),
        status: 'Pending',
      ),
    ];
  }
}
