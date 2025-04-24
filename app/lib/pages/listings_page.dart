import 'package:app/core/storage/secure_storage.dart';
import 'package:app/services/listing_service.dart';
import 'package:app/widgets/app_bar.dart';
import 'package:app/widgets/nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

class BloodRequestsPage extends StatefulWidget {
  const BloodRequestsPage({super.key});

  @override
  State<BloodRequestsPage> createState() => _BloodRequestsPageState();
}

class _BloodRequestsPageState extends State<BloodRequestsPage> {
  String _selectedFilter = "All";
  bool _isLoading = false;
  List<Listing> _requests = [];
  final _listingService = ListingService();
  final _storage = GetIt.instance.get<SecureStorage>();
  String? _userBloodType;
  List<String> _compatibleTypes = [];

  @override
  void initState() {
    super.initState();
    _loadUserBloodTypeAndRequests();
  }

  Future<void> _loadUserBloodTypeAndRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user's blood type from storage
      final bloodGroup = await _storage.getUserBloodGroup();

      // Safely handle null or empty blood group
      setState(() {
        if (bloodGroup != null && bloodGroup.isNotEmpty) {
          _userBloodType = bloodGroup;
          _compatibleTypes = _getCompatibleBloodTypes(bloodGroup);
        } else {
          _userBloodType = null;
          _compatibleTypes = [];
        }
      });

      // Load requests regardless of blood type availability
      await _loadRequests();
    } catch (e) {
      print("Error loading user data: $e");
      setState(() {
        _isLoading = false;
        _userBloodType = null;
        _compatibleTypes = [];
      });
    }
  }

  List<String> _getCompatibleBloodTypes(String bloodType) {
    // Validate input first
    if (bloodType == null || bloodType.isEmpty) {
      return [];
    }

    // Blood type compatibility chart
    switch (bloodType) {
      case 'O-':
        return ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'];
      case 'O+':
        return ['O+', 'A+', 'B+', 'AB+'];
      case 'A-':
        return ['A-', 'A+', 'AB-', 'AB+'];
      case 'A+':
        return ['A+', 'AB+'];
      case 'B-':
        return ['B-', 'B+', 'AB-', 'AB+'];
      case 'B+':
        return ['B+', 'AB+'];
      case 'AB-':
        return ['AB-', 'AB+'];
      case 'AB+':
        return ['AB+'];
      default:
        return [];
    }
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final requests = await _listingService.getCompatibleListings();
      setState(() {
        if (_userBloodType != null &&
            _userBloodType!.isNotEmpty &&
            _compatibleTypes.isNotEmpty) {
          _requests = requests
              .where(
                  (request) => _compatibleTypes.contains(request.groupRequired))
              .toList();
        } else {
          _requests = requests;
        }
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading requests: $e");
      setState(() {
        _requests = []; // Ensure we never have null
        _isLoading = false;
      });
    }
  }

  List<Listing> get _filteredRequests {
    print(_requests);
    if (_selectedFilter == "All") {
      return _requests;
    } else if (_selectedFilter == "Urgent") {
      return _requests.where((request) => request.isEmergency).toList();
    } else {
      return _requests
          .where((request) =>
              request.groupRequired == _selectedFilter &&
              request.isEmergency == false)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BloodAppBar(),
      body: Column(
        children: [
          // Page Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.bloodtype, color: Colors.red[800], size: 28),
                SizedBox(width: 12),
                Text(
                  "Blood Requests",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
              ],
            ),
          ),

          // Blood Type Compatibility Card
          if (_userBloodType != null)
            BloodCompatibilityCard(
              userBloodType: _userBloodType!,
              compatibleTypes: _compatibleTypes,
            ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: SearchField(),
          ),

          // Filter Section
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip("All"),
                _buildFilterChip("Urgent"),
                if (_userBloodType != null)
                  ..._compatibleTypes.map((type) => _buildFilterChip(type)),
                if (_userBloodType == null) ...[
                  _buildFilterChip("A+"),
                  _buildFilterChip("A-"),
                  _buildFilterChip("B+"),
                  _buildFilterChip("B-"),
                  _buildFilterChip("AB+"),
                  _buildFilterChip("AB-"),
                  _buildFilterChip("O+"),
                  _buildFilterChip("O-"),
                ],
              ],
            ),
          ),

          // Request List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredRequests.isEmpty
                    ? _buildEmptyState()
                    : _buildRequestsList(),
          ),
        ],
      ),
      floatingActionButton: NavBarFloatingButton(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      bottomNavigationBar: BloodNavBar(),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(filter),
        selected: isSelected,
        selectedColor: Colors.red[100],
        checkmarkColor: Colors.red[800],
        labelStyle: TextStyle(
          color: isSelected ? Colors.red[800] : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.grey[200],
        onSelected: (selected) {
          setState(() {
            _selectedFilter = filter;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bloodtype_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            "No blood requests found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _selectedFilter != "All"
                ? "Try changing your filter"
                : "Check back later for new requests",
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList() {
    return RefreshIndicator(
      onRefresh: _loadRequests,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filteredRequests.length,
        itemBuilder: (context, index) {
          final request = _filteredRequests[index];
          return BloodRequestCard(request: request);
        },
      ),
    );
  }
}

class BloodCompatibilityCard extends StatelessWidget {
  final String userBloodType;
  final List<String> compatibleTypes;

  const BloodCompatibilityCard({
    super.key,
    required this.userBloodType,
    required this.compatibleTypes,
  });

  @override
  Widget build(BuildContext context) {
    // Always use a safe list to prevent null pointer errors
    final List<String> safeTypes =
        compatibleTypes.isNotEmpty ? compatibleTypes : [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade600, Colors.red.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  userBloodType,
                  style: TextStyle(
                    color: Colors.red[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Your Blood Type",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "You can donate to:",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 8),
          if (safeTypes.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: safeTypes
                  .map((type) => Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 0.5),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ))
                  .toList(),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white, width: 0.5),
              ),
              child: Text(
                "No compatible types found",
                style: TextStyle(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.white.withOpacity(0.8),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Only showing compatible blood requests",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({Key? key}) : super(key: key);

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
          hintText: "Search by location or blood type",
          prefixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}

class BloodRequestCard extends StatelessWidget {
  final Listing request;

  const BloodRequestCard({Key? key, required this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract username safely from the user object
    final String username = _extractUsernameFromUser(request.user);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: request.isEmergency ? Colors.red : Colors.transparent,
          width: request.isEmergency ? 1 : 0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push('/request-details/${request.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BloodTypeTag(bloodType: request.groupRequired),
                  SizedBox(width: 8),
                  if (request.isEmergency) UrgentTag(),
                  Spacer(),
                  Text(
                    _formatTimeDifference(request.createdAt),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                username,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                request.hospitalName != null && request.hospitalName!.isNotEmpty
                    ? request.hospitalName!
                    : "No hospital name provided",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  request.address != null
                      ? Text(
                          request.address!,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        )
                      : Text(
                          "Location Not Provided",
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                  Spacer(),
                  Text(
                    "${request.bagsRequired} units needed",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ListingService()
                          .donateAndChangeStatus(context, request.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text("Donate"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeDifference(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 0) {
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago";
    } else {
      return "Just now";
    }
  }

  String _extractUsernameFromUser(Map<String, dynamic> userMap) {
    if (userMap.containsKey('username') && userMap['username'] != null) {
      return userMap['username'].toString();
    }
    return "Anonymous";
  }
}

class BloodTypeTag extends StatelessWidget {
  final String bloodType;

  const BloodTypeTag({Key? key, required this.bloodType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        bloodType,
        style: TextStyle(
          color: Colors.red[800],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class UrgentTag extends StatelessWidget {
  const UrgentTag({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "URGENT",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
