import 'package:flutter/material.dart';

class DonorsPage extends StatelessWidget {
  const DonorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.red[600],
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              BloodGroups(),
              SizedBox(height: 16),
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
