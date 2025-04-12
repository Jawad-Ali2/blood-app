import 'package:app/core/network/dio_client.dart';
import 'package:app/pages/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DonorsPage extends StatefulWidget {
  const DonorsPage({super.key});

  @override
  State<DonorsPage> createState() => _DonorsPageState();
}

class _DonorsPageState extends State<DonorsPage> {
  final _dioClient = GetIt.instance.get<DioClient>();
  List donors = [];
  bool isLoading = true;
  String selectedBloodGroup = "All";

  Future fetchDonors({String? bloodGroup}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = bloodGroup != null && bloodGroup != "All"
          ? await _dioClient.dio.get("/user/donors/filter",
              queryParameters: {"bloodGroup": bloodGroup})
          : await _dioClient.dio.get("/user/donors");

      setState(() {
        donors = response.data['data'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching donors: $e");
    }
  }

  void filterByBloodGroup(String bloodGroup) {
    setState(() {
      selectedBloodGroup = bloodGroup;
    });
    fetchDonors(bloodGroup: bloodGroup);
  }

  @override
  void initState() {
    super.initState();
    fetchDonors();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Available Donors",
            style: TextStyle(color: Colors.white)),
        toolbarHeight: 70,
        backgroundColor: Colors.red[600],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.red))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    BloodGroups(
                      onBloodGroupSelected: filterByBloodGroup,
                      selectedBloodGroup: selectedBloodGroup,
                    ),
                    const SizedBox(height: 16),
                    const DonorMap(),
                    const SizedBox(height: 16),
                    donors.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text("No donors found",
                                  style: TextStyle(fontSize: 18)),
                            ),
                          )
                        : Donors(donors: donors),
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
  final Function(String) onBloodGroupSelected;
  final String selectedBloodGroup;

  const BloodGroups({
    super.key,
    required this.onBloodGroupSelected,
    required this.selectedBloodGroup,
  });

  @override
  State<BloodGroups> createState() => _BloodGroupsState();
}

class _BloodGroupsState extends State<BloodGroups> {
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
                        widget.onBloodGroupSelected(
                            demoCategories[index]["title"]);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.selectedBloodGroup ==
                                demoCategories[index]["title"]
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

class Donors extends StatelessWidget {
  const Donors({
    super.key,
    required this.donors,
  });

  final List donors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(
          donors.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: DonorCard(
              name: donors[index]["username"] ?? "Unknown",
              address: donors[index]["city"] ?? "Unknown",
              image:
                  "https://randomuser.me/api/portraits/${index % 2 == 0 ? 'men' : 'women'}/${(index % 10) + 1}.jpg",
              bloodGroup: donors[index]["bloodGroup"] ?? "Unknown",
              phone: donors[index]["phone"] ?? "",
              onContactPressed: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class DonorCard extends StatelessWidget {
  const DonorCard({
    super.key,
    required this.name,
    required this.address,
    required this.image,
    required this.bloodGroup,
    required this.onContactPressed,
    this.phone = "",
  });

  final String name, address, image, bloodGroup, phone;
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(2, 4),
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
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 85,
                    height: 85,
                    color: Colors.grey[300],
                    child: const Icon(Icons.person, size: 40),
                  ),
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

class DonorMap extends StatefulWidget {
  const DonorMap({super.key});

  @override
  State<DonorMap> createState() => _DonorMapState();
}

class _DonorMapState extends State<DonorMap> {
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      height: screenHeight * 0.4,
      width: screenWidth,
      child: MapScreen(),
    );
  }
}
