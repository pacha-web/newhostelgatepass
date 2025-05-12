import 'package:flutter/material.dart';

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

  // Replace this with actual backend call
  Future<void> fetchRequests() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulating network delay

    // Sample data - replace with backend response
    setState(() {
      _requests = [
        {
          'studentName': 'John Doe',
          'reason': 'Medical Appointment',
          'date': '2025-04-13',
          'status': 'Pending',
        },
        {
          'studentName': 'Alice Smith',
          'reason': 'Family Visit',
          'date': '2025-04-12',
          'status': 'Pending',
        },
      ];
      _isLoading = false;
    });
  }

  void approveRequest(int index) {
    setState(() {
      _requests[index]['status'] = 'Approved';
    });
    // Send status update to backend here
  }

  void rejectRequest(int index) {
    setState(() {
      _requests[index]['status'] = 'Rejected';
    });
    // Send status update to backend here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Requested Gate Passes"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
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
