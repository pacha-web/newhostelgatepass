import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

class ViewRequests extends StatefulWidget {
  const ViewRequests({super.key});
  @override
  State<ViewRequests> createState() => _ViewRequestsState();
}

class _ViewRequestsState extends State<ViewRequests> {
  List<dynamic> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      final url = Uri.parse("http://192.168.13.144:5000/api/my-requests");
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer YOUR_TOKEN', // remove if not using auth
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          requests = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch requests: $e')),
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gate Pass Requests'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(child: Text('No requests found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    final status = req['status'] ?? 'Pending';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reason: ${req['reason'] ?? 'N/A'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Status: $status',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: getStatusColor(status),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Approved – QR Code
                            if (status == 'Approved') ...[
                              Center(
                                child: QrImageView(
                                  data: jsonEncode({
                                    'id': req['id'],
                                    'name': req['name'],
                                    'roll': req['roll'],
                                    'departure': req['departureTime'],
                                    'return': req['returnTime'],
                                    'issued': req['createdAt']
                                  }),
                                  version: QrVersions.auto,
                                  size: 200,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Center(
                                child: Text(
                                  'Show this QR code at the gate.',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ]

                            // Rejected – Message
                            else if (status == 'Rejected') ...[
                              const Text(
                                '❌ Your gate pass request was rejected by the admin.',
                                style: TextStyle(fontSize: 14, color: Colors.red),
                              ),
                            ]

                            // Pending – Info
                            else ...[
                              const Text(
                                '⏳ Your request is under review.',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
