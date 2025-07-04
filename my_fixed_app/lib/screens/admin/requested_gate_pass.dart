import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestedGatePass extends StatefulWidget {
  const RequestedGatePass({super.key});

  @override
  State<RequestedGatePass> createState() => _RequestedGatePassState();
}

class _RequestedGatePassState extends State<RequestedGatePass> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.13.144:5000/api/requests"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _requests = data.map((item) => {
            'id': item['id'],
            'studentName': item['name'],
            'reason': item['reason'],
            'date': item['createdAt'].substring(0, 10),
            'status': item['status'],
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      print("Error fetching requests: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void updateRequestStatus(int index, String newStatus) async {
    final id = _requests[index]['id'];
    final response = await http.put(
      Uri.parse("http://192.168.13.144:5000/api/requests/$id/status"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'status': newStatus}),
    );

    if (response.statusCode == 200) {
      setState(() {
        _requests[index]['status'] = newStatus;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status')),
      );
    }
  }

  void approveRequest(int index) => updateRequestStatus(index, 'Approved');
  void rejectRequest(int index) => updateRequestStatus(index, 'Rejected');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Requested Gate Passes"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: const Color.fromARGB(255, 23, 16, 161),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? const Center(child: Text("No pending requests."))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(request['studentName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Reason: ${request['reason']}"),
                            Text("Date: ${request['date']}"),
                            Text("Status: ${request['status']}"),
                          ],
                        ),
                        trailing: request['status'] == 'Pending'
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check, color: Colors.green),
                                    onPressed: () => approveRequest(index),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () => rejectRequest(index),
                                  ),
                                ],
                              )
                            : Text(
                                request['status'],
                                style: TextStyle(
                                  color: request['status'] == 'Approved'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
