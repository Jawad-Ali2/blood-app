import 'package:app/core/storage/secure_storage.dart';
import 'package:app/services/auth_services.dart';
import 'package:app/services/listing_service.dart';
import 'package:app/widgets/create_request_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

class UserListingsPage extends StatefulWidget {
  const UserListingsPage({super.key});

  @override
  State<UserListingsPage> createState() => _UserListingsPageState();
}

class _UserListingsPageState extends State<UserListingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _listingService = ListingService();
  final _storage = GetIt.instance.get<SecureStorage>();
  bool isLoading = true;
  List<Listing> allListings = [];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 5, vsync: this); // Correctly set to 5 tabs
    _fetchListings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchListings() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = await _storage.getUser();
      if (user != null) {
        final listings = await _listingService.getUserListings(user.id);
        setState(() {
          allListings = listings;
          isLoading = false;
        });
      } else {
        setState(() {
          allListings = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching listings: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Listing> _getFilteredListings(String status) {
    if (status == 'Emergency') {
      return allListings
          .where((listing) => listing.isEmergency && listing.status == 'active')
          .toList();
    } else if (status == 'Active') {
      return allListings
          .where(
              (listing) => !listing.isEmergency && listing.status == 'active')
          .toList();
    } else if (status == 'In Progress') {
      return allListings
          .where((listing) => listing.status == 'in-progress')
          .toList();
    } else if (status == 'Fulfilled') {
      return allListings
          .where((listing) => listing.status == 'fulfilled')
          .toList();
    } else if (status == 'Canceled') {
      return allListings
          .where((listing) => listing.status == 'canceled')
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[600],
        title: Text(
          "My Blood Requests",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "Emergency"),
            Tab(text: "Active"),
            Tab(text: "In Progress"),
            Tab(text: "Fulfilled"),
            Tab(text: "Canceled"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListingList('Emergency'),
                _buildListingList('Active'),
                _buildListingList('In Progress'),
                _buildListingList('Fulfilled'),
                _buildListingList('Canceled'),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _createNewListing,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildListingList(String category) {
    final listings = _getFilteredListings(category);

    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No $category requests found",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchListings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: listings.length,
        itemBuilder: (context, index) {
          return _buildListingCard(listings[index], category);
        },
      ),
    );
  }

  Widget _buildListingCard(Listing listing, String category) {
    Color cardColor = Colors.white;
    Color statusColor = Colors.blue;
    IconData statusIcon = Icons.info;

    switch (category) {
      case 'Emergency':
        cardColor = Colors.red[50]!;
        statusColor = Colors.red[700]!;
        statusIcon = Icons.emergency;
        break;
      case 'Active':
        cardColor = Colors.blue[50]!;
        statusColor = Colors.blue[700]!;
        statusIcon = Icons.check_circle;
        break;
      case 'In Progress':
        cardColor = Colors.amber[50]!;
        statusColor = Colors.amber[700]!;
        statusIcon = Icons.pending_actions;
        break;
      case 'Fulfilled':
        cardColor = Colors.green[50]!;
        statusColor = Colors.green[700]!;
        statusIcon = Icons.check_circle;
        break;
      case 'Canceled':
        cardColor = Colors.grey[200]!;
        statusColor = Colors.grey[700]!;
        statusIcon = Icons.cancel;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          _showListingDetailsDialog(listing, category);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.2),
                    child: Text(
                      listing.groupRequired,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${listing.bagsRequired} units needed",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Created on: ${listing.createdAt.toLocal().toString().split(' ')[0]}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    statusIcon,
                    color: statusColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (listing.hospitalName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.local_hospital,
                          size: 18, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        listing.hospitalName!,
                        style: TextStyle(
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  if (listing.pickAndDrop)
                    _buildFeatureChip(
                      icon: Icons.transfer_within_a_station,
                      label: "Pick & Drop",
                      color: Colors.purple[700]!,
                    ),
                  if (listing.willPay)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildFeatureChip(
                        icon: Icons.monetization_on,
                        label: "Will Pay",
                        color: Colors.green[700]!,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showListingDetailsDialog(Listing listing, String category) {
    Color statusColor;
    String statusText;

    switch (category) {
      case 'Emergency':
        statusColor = Colors.red[700]!;
        statusText = "Emergency";
        break;
      case 'Active':
        statusColor = Colors.blue[700]!;
        statusText = "Active";
        break;
      case 'In Progress':
        statusColor = Colors.amber[700]!;
        statusText = "In Progress";
        break;
      case 'Fulfilled':
        statusColor = Colors.green[700]!;
        statusText = "Fulfilled";
        break;
      case 'Canceled':
        statusColor = Colors.grey[700]!;
        statusText = "Canceled";
        break;
      default:
        statusColor = Colors.blue[700]!;
        statusText = "Active";
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Request Details"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow("Blood Type", listing.groupRequired),
                _buildDetailRow("Units Needed", "${listing.bagsRequired}"),
                _buildDetailRow(
                    "Hospital", listing.hospitalName ?? "Not specified"),
                _buildDetailRow("Created",
                    "${listing.createdAt.toLocal().toString().split(' ')[0]}"),
                _buildDetailRow("Required Till",
                    "${listing.requiredTill.toLocal().toString().split(' ')[0]}"),
                _buildDetailRow(
                    "Pick & Drop", listing.pickAndDrop ? "Yes" : "No"),
                _buildDetailRow("Will Pay", listing.willPay ? "Yes" : "No"),
                if (listing.status == 'in-progress' &&
                    listing.acceptedBy != null) ...[
                  const SizedBox(height: 16),

                  // Donor profile summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header
                        Row(
                          children: [
                            Icon(
                              Icons.person_pin_circle,
                              color: Colors.green.shade800,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Donor Information",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),

                        // Donor profile with photo
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.green.shade100,
                              foregroundColor: Colors.green.shade800,
                              child: Text(
                                listing.acceptedBy?.bloodGroup?.substring(
                                        0,
                                        listing.acceptedBy!.bloodGroup.length >
                                                2
                                            ? 2
                                            : 1) ??
                                    "?",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${listing.acceptedBy?.firstName ?? ''} ${listing.acceptedBy?.lastName ?? listing.acceptedBy?.username ?? 'Anonymous Donor'}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.bloodtype,
                                          size: 14, color: Colors.red.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Blood Group: ${listing.acceptedBy?.bloodGroup ?? 'Unknown'}",
                                        style:
                                            TextStyle(color: Colors.grey[700]),
                                      ),
                                    ],
                                  ),
                                  if (listing.acceptedBy?.city != null)
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 14,
                                            color: Colors.blue.shade700),
                                        const SizedBox(width: 4),
                                        Text(
                                          listing.acceptedBy!.city!,
                                          style: TextStyle(
                                              color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),

                            // Contact button if phone available
                            if (listing.acceptedBy?.phone != null)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Icon(Icons.phone,
                                    color: Colors.green.shade800, size: 20),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Transaction details
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Donation Details",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDonationInfoItem(
                                      Icons.bloodtype,
                                      "Donating",
                                      "${listing.bagsRequired} unit${listing.bagsRequired > 1 ? 's' : ''}",
                                      Colors.red.shade700,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDonationInfoItem(
                                      Icons.access_time,
                                      "Status",
                                      "In Progress",
                                      Colors.amber.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDonationInfoItem(
                                      Icons.calendar_today,
                                      "Accepted on",
                                      "${DateTime.now().difference(listing.createdAt).inDays} days ago",
                                      Colors.blue.shade700,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDonationInfoItem(
                                      Icons.timeline,
                                      "Required Till",
                                      "${listing.requiredTill.difference(DateTime.now()).inDays} days left",
                                      listing.requiredTill
                                                  .difference(DateTime.now())
                                                  .inDays <
                                              3
                                          ? Colors.red.shade700
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Hospital/Location information
                        if (listing.hospitalName != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.local_hospital,
                                    color: Colors.blue.shade700),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Hospital / Location",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                      Text(
                                        listing.hospitalName!,
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (listing.address != null)
                                        Text(
                                          listing.address!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Map icon
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(Icons.map,
                                      color: Colors.blue.shade800, size: 20),
                                ),
                              ],
                            ),
                          ),

                        // Donation features
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (listing.pickAndDrop)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.purple.shade200),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.transfer_within_a_station,
                                          color: Colors.purple.shade700,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Pick & Drop",
                                        style: TextStyle(
                                          color: Colors.purple.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (listing.pickAndDrop && listing.willPay)
                              const SizedBox(width: 8),
                            if (listing.willPay)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.green.shade200),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.monetization_on,
                                          color: Colors.green.shade700,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Paid Donation",
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Information about completion
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber[700]),
                            const SizedBox(width: 8),
                            Text(
                              "Confirm Donation Completion",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.amber[900],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "This will increase your donor's credibility points and help build trust in the community.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Confirming completion ensures the donation record is properly maintained and helps other recipients find reliable donors.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
            if (category == 'Active' || category == 'Emergency')
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showCancelConfirmationDialog(listing);
                },
                child: Text(
                  "Cancel Request",
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            if (category == 'Active' || category == 'Emergency')
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showFulfillConfirmationDialog(listing);
                },
                child: Text(
                  "Mark Fulfilled",
                  style: TextStyle(color: Colors.green[700]),
                ),
              ),
            if (category == 'In Progress')
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showFulfillConfirmationDialog(listing);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
                child: const Text("Mark Donation Complete"),
              ),
            if (category == 'Canceled')
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showReactivateConfirmationDialog(listing);
                },
                child: Text(
                  "Reactivate",
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmationDialog(Listing listing) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Cancel Request?"),
          content: const Text(
            "Are you sure you want to cancel this blood request? You can reactivate it later if needed.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No, Keep It"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _listingService.cancelListing(listing.id);
                  await _fetchListings();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Request canceled successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error canceling request: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                "Yes, Cancel",
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFulfillConfirmationDialog(Listing listing) {
    final bool isInProgress = listing.status == 'in-progress';
    final String title =
        isInProgress ? "Confirm Donation Complete" : "Mark as Fulfilled?";
    final String message = isInProgress
        ? "Are you sure you want to mark this donation as complete? This will finalize the process and express your gratitude to the donor."
        : "Are you sure you want to mark this request as fulfilled? This indicates you've received the blood you needed.";
    final String confirmText =
        isInProgress ? "Yes, Donation Complete" : "Yes, Mark Fulfilled";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message),
              if (isInProgress) ...[
                const SizedBox(height: 16),

                // Donor profile summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            foregroundColor: Colors.green.shade800,
                            child: const Icon(Icons.person),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${listing.acceptedBy?.firstName ?? ''} ${listing.acceptedBy?.lastName ?? listing.acceptedBy?.username ?? 'Anonymous Donor'}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Blood Group: ${listing.acceptedBy?.bloodGroup ?? 'Unknown'}",
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 24),

                      // Donation details
                      Row(
                        children: [
                          Expanded(
                            child: _buildDonationInfoItem(
                              Icons.bloodtype,
                              "Donating",
                              "${listing.bagsRequired} unit${listing.bagsRequired > 1 ? 's' : ''}",
                              Colors.red.shade700,
                            ),
                          ),
                          Expanded(
                            child: _buildDonationInfoItem(
                              Icons.access_time,
                              "Status",
                              "In Progress",
                              Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      if (listing.hospitalName != null)
                        _buildDonationInfoItem(
                          Icons.local_hospital,
                          "Location",
                          listing.hospitalName!,
                          Colors.blue.shade700,
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "This will increase your donor's credibility points and help build trust in the community.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Confirming completion ensures the donation record is properly maintained.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.amber[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _listingService.fulfillListing(listing.id);
                  await _fetchListings();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isInProgress
                          ? "Donation marked as complete. Thank you!"
                          : "Request marked as fulfilled"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error updating request: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
              child: Text(
                confirmText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method for donation information items
  Widget _buildDonationInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showReactivateConfirmationDialog(Listing listing) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reactivate Request?"),
          content: const Text(
            "Are you sure you want to reactivate this request? This will make it visible to donors again.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  if (listing.isEmergency) {
                    final activeListings = allListings
                        .where(
                            (l) => l.status == 'active' && l.id != listing.id)
                        .toList();

                    if (activeListings.isNotEmpty) {
                      final shouldCancel = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Cancel Other Listings?"),
                              content: const Text(
                                "Reactivating an emergency request requires canceling all your other active listings. Do you want to proceed?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red[700],
                                  ),
                                  child: const Text("Yes, Cancel Others"),
                                ),
                              ],
                            ),
                          ) ??
                          false;

                      if (!shouldCancel) return;

                      await _listingService.cancelAllActiveListings();
                    }
                  } else {
                    final activeRegularListings = allListings
                        .where((l) => l.status == 'active' && !l.isEmergency)
                        .toList();

                    if (activeRegularListings.length >= 2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "You already have 2 active listings. Please cancel one before reactivating this.",
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    final hasActiveEmergency = allListings
                        .any((l) => l.status == 'active' && l.isEmergency);

                    if (hasActiveEmergency) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "You cannot reactivate a regular listing while you have an active emergency request.",
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                  }

                  await _listingService.reactivateListing(listing.id);
                  await _fetchListings();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Request reactivated successfully"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error reactivating request: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text(
                "Yes, Reactivate",
                style: TextStyle(color: Colors.blue[700]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _createNewListing() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateRequestDialog(
          onRequestCreated: (dynamic result) {
            if (result is Map && result['action'] == 'navigate_to_listings') {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please manage your existing listings first"),
                  duration: Duration(seconds: 2),
                ),
              );
              _fetchListings();
            } else if (result != null) {
              _fetchListings();
            }
          },
        );
      },
    ).then((_) => _fetchListings());
  }
}
