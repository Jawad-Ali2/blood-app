//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _bloodRequests.isEmpty
//               ? Center(child: Text("No requests found."))
//               : ListView.builder(
//                   itemCount: _bloodRequests.length,
//                   itemBuilder: (context, index) {
//                     return BloodRequestCard(
//                       post: _bloodRequests[index],
//                       onTap: () {
//                         print("Tapped on ${_bloodRequests[index].groupRequired}");
//                       },
//                     );
//                   },
//                 ),
//     );
//   }
// }

// // Reusable Blood Request Card Widget
// class BloodRequestCard extends StatelessWidget {
//   final Request post;
//   final VoidCallback onTap;
//
//   const BloodRequestCard({super.key, required this.post, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         elevation: 3,
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Blood Group (Highlighted)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     post.groupRequired,
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red,
//                     ),
//                   ),
//                   Text(
//                     // "${post.distance.toStringAsFixed(1)} km away",
//                     "-- km away",
//                     style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//                   ),
//                 ],
//               ),
//
//               const SizedBox(height: 6),
//
//               // Location & Bags Required
//               Text(
//                 "${post.location} • ${post.bagsRequired} bag(s) required",
//                 style: TextStyle(fontSize: 16),
//               ),
//
//               // Required Till Date
//               Text(
//                 "Needed by: ${post.requiredTill.toLocal()}".split(' ')[0],
//                 style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//               ),
//
//               const SizedBox(height: 6),
//
//               // Additional Info (Icons for pick & drop, will pay)
//               Row(
//                 children: [
//                   if (post.pickAndDrop)
//                     Icon(Icons.local_taxi, size: 18, color: Colors.green),
//                   if (post.pickAndDrop) const SizedBox(width: 4),
//                   if (post.willPay)
//                     Icon(Icons.attach_money, size: 18, color: Colors.blue),
//                   if (post.willPay) const SizedBox(width: 4),
//                   Text("Credibility: ${post.userCredibility}/10",
//                       style:
//                           TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//                 ],
//               ),
//
//               const SizedBox(height: 8),
//
//               // Contact Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: () {
//                     print("Contacting ${post.userContact}");
//                   },
//                   icon: Icon(Icons.phone),
//                   label: Text("Contact"),
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:app/core/network/dio_client.dart';
import 'package:app/models/request.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  final _dioClient = GetIt.instance.get<DioClient>();
  List<Request> _bloodRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // fetchBloodRequests();
  }

  Future<void> fetchBloodRequests() async {
    try {
      final response = await _dioClient.dio.get('/listing');

      if (response.statusCode == 200) {
        List data = response.data;
        setState(() {
          _bloodRequests = data.map((json) => Request.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.red[600],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const BloodGroups(),
              const SizedBox(height: 16),
              // _isLoading
              //     ? Center(child: CircularProgressIndicator())
              //     : _bloodRequests.isEmpty
              //         ? Center(child: Text("No requests found."))
              //         : Donors(),
              Donors(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[600],
        onPressed: () {},
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[300],
        shape: const CircularNotchedRectangle(),
        child: IconTheme(
          data: const IconThemeData(color: Colors.black),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.person),
                onPressed: () {},
              ),
              IconButton(
                tooltip: 'Favorite',
                icon: const Icon(Icons.settings),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BloodGroups extends StatefulWidget {
  const BloodGroups({super.key});

  @override
  State<BloodGroups> createState() => _BloodGroupsState();
}

class _BloodGroupsState extends State<BloodGroups> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            "Group Filter",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                children: List.generate(
                  demoCategories.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedIndex == index
                            ? Colors.red[600]
                            : const Color(0xFFA4A2A2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(demoCategories[index]["title"]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Demo data categories
List<Map<String, dynamic>> demoCategories = [
  {"title": "All", "isActive": true},
  {"title": "A+", "isActive": false},
  {"title": "A-", "isActive": false},
  {"title": "B+", "isActive": false},
  {"title": "B-", "isActive": false},
  {"title": "AB+", "isActive": false},
  {"title": "AB-", "isActive": false},
  {"title": "O+", "isActive": false},
  {"title": "O-", "isActive": false},
];

class Donors extends StatefulWidget {
  const Donors({super.key});

  @override
  State<Donors> createState() => _DonorsState();
}

class _DonorsState extends State<Donors> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(
          demoData.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ItemCard(
              name: demoData[index]["name"],
              address: demoData[index]["address"],
              image: demoData[index]["image"],
              bloodGroup: demoData[index]["bloodGroup"],
              onContactPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.name,
    required this.address,
    required this.image,
    required this.bloodGroup,
    required this.onContactPressed,
  });

  final String name, address, image, bloodGroup;
  final VoidCallback onContactPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      onTap: onContactPressed,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white, // Light background color
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2), // Light shadow
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(2, 4), // Offset to make it look lifted
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  image,
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 18),
                    ),
                    Text(
                      address,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bloodGroup,
                    style: TextStyle(
                        color: Colors.red[900],
                        fontWeight: FontWeight.w900,
                        fontSize: 18),
                  ),
                  IconButton(
                    onPressed: onContactPressed,
                    icon:
                        const Icon(Icons.phone, color: Colors.green, size: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Sample Data
final List<Map<String, dynamic>> demoData = [
  {
    "image": "https://randomuser.me/api/portraits/men/1.jpg",
    "name": "John Doe",
    "address": "123 Main St, New York",
    "bloodGroup": "A+",
  },
  {
    "image": "https://randomuser.me/api/portraits/women/2.jpg",
    "name": "Jane Smith",
    "address": "456 Park Ave, Chicago",
    "bloodGroup": "O-",
  },
  {
    "image": "https://randomuser.me/api/portraits/men/3.jpg",
    "name": "Mike Johnson",
    "address": "789 Sunset Blvd, Los Angeles",
    "bloodGroup": "B+",
  },
];
