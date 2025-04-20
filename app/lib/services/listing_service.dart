import 'dart:convert';
import 'dart:ffi';
import 'package:app/core/network/dio_client.dart';
import 'package:app/core/storage/secure_storage.dart';
import 'package:app/widgets/custom_toast.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';

class Listing {
  final String id;
  final String groupRequired;
  final int bagsRequired;
  final DateTime requiredTill;
  final bool pickAndDrop;
  final bool willPay;
  final String? hospitalName;
  final String? address;
  final bool isEmergency;
  final String? notes;
  final Map<String, dynamic> user;
  final String status;
  final DateTime createdAt;

  Listing({
    required this.id,
    required this.groupRequired,
    required this.bagsRequired,
    required this.requiredTill,
    required this.pickAndDrop,
    required this.willPay,
    this.hospitalName,
    this.address,
    required this.isEmergency,
    this.notes,
    this.status = 'active',
    required this.user,
    required this.createdAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'],
      groupRequired: json['groupRequired'],
      bagsRequired: json['bagsRequired'],
      requiredTill: DateTime.parse(json['requiredTill']),
      pickAndDrop: json['pickAndDrop'],
      willPay: json['willPay'] ?? false,
      hospitalName: json['hospitalName'],
      address: json['address'],
      isEmergency: json['isEmergency'] ?? false,
      notes: json['notes'],
      user: json['user'],
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ListingService {
  final _storage = GetIt.instance.get<SecureStorage>();
  final _dioClient = GetIt.instance.get<DioClient>();

  // Get all listings
  Future<List<Listing>> getListings() async {
    try {
      final response = await _dioClient.dio.get('/listing');

      final List<dynamic> data = response.data;
      return data.map((json) => Listing.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load listings: ${e.message}');
    }
  }

  Future<List<Listing>> getCompatibleListings() async {
    try {
      final bloodGroup = await _storage.getUserBloodGroup();
      final encodedBloodGroup = Uri.encodeComponent(bloodGroup);
      final response = await _dioClient.dio
          .get('/listing/compatible?bloodGroup=$encodedBloodGroup');

      final List<dynamic> data = response.data;
      return data.map((json) => Listing.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load compatible listings: ${e.message}');
    }
  }

  // Get dummy listings for testing
  Future<List<Listing>> getDummyListings() async {
    try {
      final response = await _dioClient.dio.get('/listing/dummyListings');

      final List<dynamic> data = response.data;
      return data.map((json) {
        // Handle location data separately since it's not in the entity
        final Map<String, dynamic> processedJson = {...json};
        if (json.containsKey('location')) {
          processedJson['address'] =
              'Lat: ${json['location']['latitude']}, Lng: ${json['location']['longitude']}';
        }
        return Listing.fromJson(processedJson);
      }).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load dummy listings: ${e.message}');
    }
  }

  // Get emergency listings
  Future<List<Listing>> getEmergencyListings() async {
    try {
      final response = await _dioClient.dio.get('/listing/emergency');

      final List<dynamic> data = response.data;
      return data.map((json) => Listing.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load emergency listings: ${e.message}');
    }
  }

  // Get user's listings
  Future<List<Listing>> getUserListings(String userId) async {
    try {
      final response = await _dioClient.dio.get('/listing/user/$userId');
      final List<dynamic> data = response.data;
      return data.map((json) => Listing.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Failed to load user listings: ${e.message}');
    }
  }

  // Get user's active listings count
  Future<Map<String, int>> getUserListingsCount() async {
    final user = await _storage.getUser();
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final response = await _dioClient.dio.get('/listing/count/${user.id}');
      return {
        'active': response.data['count']['active'] ?? 0,
        'canceled': response.data['count']['canceled'] ?? 0,
        'fulfilled': response.data['count']['fulfilled'] ?? 0,
        'total': response.data['count']['total'] ?? 0,
      };
    } on DioException catch (e) {
      throw Exception('Failed to load user listings count: ${e.message}');
    }
  }

  // Update a listing status (cancel, fulfill, reactivate)
  Future<void> updateListingStatus(String listingId, String status) async {
    if (!['active', 'in-progress', 'canceled', 'fulfilled'].contains(status)) {
      throw Exception(
          'Invalid status. Must be one of: active, canceled, fulfilled');
    }

    try {
      await _dioClient.dio.post(
        '/listing/status/$listingId',
        data: {'status': status},
      );
    } on DioException catch (e) {
      throw Exception('Failed to update listing status: ${e.message}');
    }
  }

  // Cancel a listing
  Future<void> cancelListing(String listingId) async {
    return updateListingStatus(listingId, 'canceled');
  }

  // Mark a listing as fulfilled
  Future<void> fulfillListing(String listingId) async {
    return updateListingStatus(listingId, 'fulfilled');
  }

  // Reactivate a canceled listing
  Future<void> reactivateListing(String listingId) async {
    return updateListingStatus(listingId, 'active');
  }

  // Cancel all active listings for a user
  Future<bool> cancelAllActiveListings() async {
    final user = await _storage.getUser();
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final response = await _dioClient.dio.post(
        '/listing/cancel-all/${user.id}',
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception('Failed to cancel all listings: ${e.message}');
    }
  }

  // Cancel the oldest active listing
  Future<Listing?> cancelOldestListing() async {
    final user = await _storage.getUser();
    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final response = await _dioClient.dio.post(
        '/listing/cancel-oldest/${user.id}',
      );

      if (response.statusCode == 200 && response.data['success']) {
        return Listing.fromJson(response.data['data']);
      }
      return null;
    } on DioException catch (e) {
      throw Exception('Failed to cancel oldest listing: ${e.message}');
    }
  }

  // Create a new listing
  Future<dynamic> createListing(Map<String, dynamic> listingData,
      {BuildContext? context}) async {
    final user = await _storage.getUser();
    if (user == null) {
      throw Exception('User not logged in');
    }

    // Add userId to the listing data
    listingData['userId'] = user.id;

    // Handle the emergency flag - ensure it exists
    final bool isEmergency = listingData['isEmergency'] ?? false;

    try {
      // Get user's listings to check active ones
      final userListings = await getUserListings(user.id);
      final activeListings =
          userListings.where((l) => l.status == 'active').toList();
      final activeEmergencyListings =
          activeListings.where((l) => l.isEmergency).toList();
      final activeNormalListings =
          activeListings.where((l) => !l.isEmergency).toList();

      // Check restrictions based on listing type
      if (isEmergency) {
        // EMERGENCY LISTING
        // Check if user already has an emergency listing
        if (activeEmergencyListings.isNotEmpty) {
          if (context != null) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Emergency Request Exists'),
                content: const Text(
                  'You already have an active emergency request. Please fulfill or cancel it before creating a new one.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return null;
          } else {
            throw Exception('You already have an active emergency request');
          }
        }

        // Check if user has normal listings that need to be canceled
        if (activeNormalListings.isNotEmpty) {
          if (context != null) {
            final shouldCancel = await _showCancelConfirmationDialog(
              context,
              'Cancel Existing Listings',
              'Creating an emergency request requires canceling all your ${activeNormalListings.length} active normal request(s). Do you want to proceed?',
              'Cancel All & Create Emergency',
            );

            if (shouldCancel) {
              // Cancel all active listings
              await cancelAllActiveListings();
            } else {
              // User declined, stop the process
              return null;
            }
          } else {
            throw Exception(
                'You have active listings that need to be canceled before creating an emergency request');
          }
        }
      } else {
        // NORMAL LISTING
        // Check if there's an active emergency listing
        if (activeEmergencyListings.isNotEmpty) {
          if (context != null) {
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Emergency Request Active'),
                content: const Text(
                    'You cannot create a regular listing while you have an active emergency request. Please fulfill or cancel your emergency request first.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return null;
          } else {
            throw Exception(
                'You cannot create a regular listing while you have an active emergency request');
          }
        }

        // Check if already have 2 active normal listings
        if (activeNormalListings.length >= 2) {
          if (context != null) {
            final choice = await _showListingLimitDialog(context);

            switch (choice) {
              case 'cancel_oldest':
                await cancelOldestListing();
                break;
              case 'view_listings':
                // Return a special value to indicate navigation to listings page
                return {'action': 'navigate_to_listings'};
              case 'cancel':
                return null;
            }
          } else {
            throw Exception(
                'You can only have 2 active normal listings at a time');
          }
        }
      }

      // Clean up null values to prevent backend validation issues
      listingData.removeWhere((key, value) => value == null);

      final response = await _dioClient.dio.post(
        isEmergency ? '/listing/emergency' : '/listing',
        data: listingData,
      );

      // Return the created listing for potential future use
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        if (e.response?.statusCode == 400 &&
            e.response?.data is Map &&
            e.response?.data['message'] != null) {
          // Check for specific error patterns in the response
          final responseData = e.response?.data as Map;

          if (responseData.containsKey('activeListings')) {
            if (context != null) {
              if (isEmergency) {
                // For emergency, ask to cancel all
                final shouldCancel = await _showCancelConfirmationDialog(
                  context,
                  'Emergency Request',
                  'Creating an emergency request requires canceling all your active requests. Do you want to proceed?',
                  'Cancel All & Create Emergency',
                );

                if (shouldCancel) {
                  await cancelAllActiveListings();
                  // Retry after cancellation
                  return createListing(listingData, context: context);
                }
              } else {
                // For normal listings, offer multiple options
                final choice = await _showListingLimitDialog(context);

                switch (choice) {
                  case 'cancel_oldest':
                    await cancelOldestListing();
                    // Retry after cancellation
                    return createListing(listingData, context: context);
                  case 'view_listings':
                    return {'action': 'navigate_to_listings'};
                  case 'cancel':
                    return null;
                }
              }
              return null;
            }
          }

          // Generic error with message from server
          throw Exception(
              responseData['message'] ?? 'Failed to create listing');
        } else {
          // Handle other errors
          throw Exception(
              'Failed to create listing: ${e.response?.data['message'] ?? e.message}');
        }
      } else {
        throw Exception('Failed to create listing: ${e.message}');
      }
    }
  }

  // Show confirmation dialog for managing listings
  Future<bool> _showCancelConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    String confirmButtonText, {
    String cancelButtonText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelButtonText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: Text(confirmButtonText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Show dialog with multiple options for handling listing limit
  Future<String> _showListingLimitDialog(BuildContext context) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Listing Limit Reached'),
        content: const Text(
            'You can only have 2 active normal listings at a time. What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('view_listings'),
            child: const Text('View My Listings'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop('cancel_oldest'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Oldest & Create New'),
          ),
        ],
      ),
    );
    return result ?? 'cancel';
  }

  // Create an emergency listing
  Future<dynamic> createEmergencyListing(Map<String, dynamic> listingData,
      {BuildContext? context}) async {
    // Set emergency flag
    listingData['isEmergency'] = true;

    try {
      return await createListing(listingData, context: context);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'Failed to create emergency listing: ${e.response?.data['message'] ?? e.message}');
      } else {
        throw Exception('Failed to create emergency listing: ${e.message}');
      }
    }
  }

  // Delete a listing
  Future<void> deleteListing(String listingId) async {
    try {
      await _dioClient.dio.delete(
        '/listing',
        data: {'listingId': listingId},
      );
    } on DioException catch (e) {
      throw Exception('Failed to delete listing: ${e.message}');
    }
  }

  Future<void> donateAndChangeStatus(context, requestId) async {
    try {
      final donorId = await _storage.getCurrentUserId();
      if(donorId == "") return;
      final response = await _dioClient.dio.post('/listing/donate/$requestId', data: {
        'donorId': donorId,
      });

      if (response.statusCode == 201) {
        CustomToast.show(context,
            message: "Listing Added To Your Active List", isError: false);
      }
    } on DioException catch (e) {
      CustomToast.show(context,
          message: "Failed to donate and change status: ${e.message}",
          isError: true, duration: Duration(seconds: 10));
    }
  }
}
