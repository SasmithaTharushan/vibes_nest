import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  String? _selectedDate;
  String? _selectedDoctor;
  String? _selectedTime;
  bool _isOnline = false;
  bool _appointmentBooked = false;
  String? _zoomLink;

  final List<String> _doctorIds = ['Dr. Smith', 'Dr. Johnson', 'Dr. Williams'];

  final Map<String, List<String>> _doctorSchedules = {
    'Dr. Smith': ['2025-03-01', '2025-03-02'],
    'Dr. Johnson': ['2025-03-03', '2025-03-04'],
    'Dr. Williams': ['2025-03-05', '2025-03-06'],
  };

  final Map<String, List<String>> _availableTimes = {
    '2025-03-01': ['10:00 AM', '11:00 AM'],
    '2025-03-02': ['2:00 PM', '3:00 PM'],
    '2025-03-03': ['9:00 AM', '10:00 AM'],
    '2025-03-04': ['1:00 PM', '2:00 PM'],
    '2025-03-05': ['11:00 AM', '12:00 PM'],
    '2025-03-06': ['3:00 PM', '4:00 PM'],
  };

  void _bookAppointment() {
    if (_selectedDate != null &&
        _selectedTime != null &&
        _selectedDoctor != null) {
      setState(() {
        _appointmentBooked = true;
        _zoomLink = "https://zoom.us/j/123456789";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment booked successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select doctor, date, and time')),
      );
    }
  }

  void _joinZoomMeeting() async {
    if (_zoomLink == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No Zoom link available')),
      );
      return;
    }

    if (await canLaunch(_zoomLink!)) {
      await launch(_zoomLink!);
    } else {
      throw 'Could not launch $_zoomLink';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Appointments'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choose a Doctor:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedDoctor,
              hint: const Text('Select a doctor'),
              items: _doctorIds
                  .map((doctorId) => DropdownMenuItem(
                        value: doctorId,
                        child: Text(doctorId),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDoctor = value;
                  _selectedDate = null;
                  _selectedTime = null;
                });
              },
            ),
            if (_selectedDoctor != null &&
                _doctorSchedules.containsKey(_selectedDoctor))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Choose a Date:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedDate,
                    hint: const Text('Select a date'),
                    items: _doctorSchedules[_selectedDoctor!]!.map((dateStr) {
                      return DropdownMenuItem(
                          value: dateStr, child: Text(dateStr));
                    }).toList(),
                    onChanged: (date) {
                      setState(() {
                        _selectedDate = date; // Store as String
                        _selectedTime = null;
                      });
                    },
                  ),
                ],
              ),
            if (_selectedDate != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Choose a Time:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedTime,
                    hint: const Text('Select a time'),
                    items: _availableTimes[_selectedDate!]?.map((time) {
                          return DropdownMenuItem(
                            value: time,
                            child: Text(time),
                          );
                        }).toList() ??
                        [],
                    onChanged: (value) => setState(() => _selectedTime = value),
                  ),
                ],
              ),
            SwitchListTile(
              title: const Text('Online Video Consultation'),
              value: _isOnline,
              onChanged: (bool value) => setState(() => _isOnline = value),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _bookAppointment,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Book Appointment',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            if (_isOnline && _appointmentBooked)
              Center(
                child: ElevatedButton(
                  onPressed: _joinZoomMeeting,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Join Zoom Meeting',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
