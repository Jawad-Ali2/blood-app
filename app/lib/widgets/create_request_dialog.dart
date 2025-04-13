import 'package:app/services/listing_service.dart';
import 'package:app/widgets/custom_toast.dart';
import 'package:flutter/material.dart';

class CreateRequestDialog extends StatefulWidget {
  final Function? onRequestCreated;
  final bool? isEmergencyChecked;

  const CreateRequestDialog(
      {super.key, this.onRequestCreated, this.isEmergencyChecked});

  @override
  State<CreateRequestDialog> createState() => _CreateRequestDialogState();
}

class _CreateRequestDialogState extends State<CreateRequestDialog> {
  String selectedBloodType = 'A+';
  int units = 1;
  final hospitalController = TextEditingController();
  final descriptionController = TextEditingController();
  bool isEmergency = false;
  bool pickAndDrop = false;
  bool willPay = false;
  DateTime requiredTill = DateTime.now().add(Duration(days: 7));
  bool isLoading = false;

  final List<String> bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEmergencyChecked != null) {
      isEmergency = widget.isEmergencyChecked!;
    }
  }

  @override
  void dispose() {
    hospitalController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Create Blood Request"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Blood Type"),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedBloodType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: bloodTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedBloodType = newValue!;
                });
              },
            ),
            SizedBox(height: 16),
            Text("Units Needed"),
            SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (units > 1) {
                      setState(() {
                        units--;
                      });
                    }
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "$units",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: () {
                    setState(() {
                      units++;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Text("Required Till"),
            SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: requiredTill,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) {
                  setState(() {
                    requiredTill = picked;
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${requiredTill.toLocal()}".split(' ')[0]),
                    Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Text("Hospital/Location"),
            SizedBox(height: 8),
            TextField(
              controller: hospitalController,
              decoration: InputDecoration(
                hintText: "Enter hospital or location",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text("Additional Details"),
            SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter any additional details",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Pick & Drop"),
                    value: pickAndDrop,
                    onChanged: (value) {
                      setState(() {
                        pickAndDrop = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: Text("Will Pay"),
                    value: willPay,
                    onChanged: (value) {
                      setState(() {
                        willPay = value!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              title: Text(
                "Emergency Request",
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              value: isEmergency,
              onChanged: (value) {
                setState(() {
                  isEmergency = value!;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            // if (isEmergency)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Note: You can only have 2 active listings. Creating an emergency request might require you to cancel an existing listing.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  setState(() {
                    isLoading = true;
                  });

                  // Create listing data with proper formatting
                  final listingData = {
                    'groupRequired': selectedBloodType,
                    'bagsRequired': units,
                    'requiredTill': requiredTill.toIso8601String(),
                    'pickAndDrop': pickAndDrop,
                    'willPay': willPay,
                    'hospitalName': hospitalController.text.isNotEmpty
                        ? hospitalController.text
                        : null,
                    'notes': descriptionController.text.isNotEmpty
                        ? descriptionController.text
                        : null,
                    'isEmergency': isEmergency,
                  };

                  try {
                    // Use the service to create the listing, passing context for dialogs
                    final listingService = ListingService();
                    final result = await listingService
                        .createListing(listingData, context: context);

                    // Check if we need to navigate to listings management
                    if (result is Map &&
                        result['action'] == 'navigate_to_listings') {
                      if (mounted) {
                        Navigator.of(context).pop(result);
                      }
                      return;
                    }

                    // If result is null, a dialog was shown and user chose not to proceed
                    if (result == null) {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                      return;
                    }

                    // Close the dialog on success
                    if (mounted) {
                      Navigator.of(context).pop(result);
                    }

                    // Call the callback if provided
                    if (widget.onRequestCreated != null) {
                      widget.onRequestCreated!(result);
                    }

                    // Show confirmation using our custom toast
                    CustomToast.show(
                      context,
                      message: "Blood request created successfully!",
                      isError: false,
                    );
                  } catch (e) {
                    // Use our custom toast to show a formatted error
                    if (mounted) {
                      // Format the error message to be user-friendly
                      String errorMessage = CustomToast.formatErrorMessage(e);

                      // Show the custom toast with error
                      CustomToast.show(
                        context,
                        message: errorMessage,
                        isError: true,
                        duration: const Duration(seconds: 5),
                      );

                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[600],
            foregroundColor: Colors.white,
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text("Submit Request"),
        ),
      ],
    );
  }
}
