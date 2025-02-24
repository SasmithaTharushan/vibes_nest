import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoodTrackingScreen extends StatefulWidget {
  @override
  _MoodTrackingScreenState createState() => _MoodTrackingScreenState();
}

class _MoodTrackingScreenState extends State<MoodTrackingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime)
      setState(() {
        _selectedTime = pickedTime;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
        title: Text(
          'Mood tracking screen',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule a day',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < 5; i++)
                    _buildDayCard(
                      DateFormat('E')
                          .format(DateTime.now().add(Duration(days: i))),
                      DateFormat('d')
                          .format(DateTime.now().add(Duration(days: i))),
                      _selectedDate != null &&
                          DateFormat('yyyy-MM-dd').format(_selectedDate!) ==
                              DateFormat('yyyy-MM-dd').format(
                                  DateTime.now().add(Duration(days: i))),
                      () {
                        setState(() {
                          _selectedDate = DateTime.now().add(Duration(days: i));
                        });
                      },
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Select Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTimeCard('8:30',
                      _selectedTime?.hour == 8 && _selectedTime?.minute == 30,
                      () {
                    setState(() {
                      _selectedTime = TimeOfDay(hour: 8, minute: 30);
                    });
                  }),
                  SizedBox(width: 10),
                  _buildTimeCard('9:30',
                      _selectedTime?.hour == 9 && _selectedTime?.minute == 30,
                      () {
                    setState(() {
                      _selectedTime = TimeOfDay(hour: 9, minute: 30);
                    });
                  }),
                  SizedBox(width: 10),
                  _buildTimeCard('10:30',
                      _selectedTime?.hour == 10 && _selectedTime?.minute == 30,
                      () {
                    setState(() {
                      _selectedTime = TimeOfDay(hour: 10, minute: 30);
                    });
                  }),
                ],
              ),
            ),
            SizedBox(height: 20),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedDate != null && _selectedTime != null) {
                    DateTime appointmentDateTime = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );

                    print('Appointment Date & Time: ${appointmentDateTime}');
                    // You can now use appointmentDateTime to save to a database, etc.
                  } else {
                    print('Please select both date and time');
                    // Optionally, show a message to the user
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Book Appointment',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                '*appointments are completely until the first meet',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard(
      String day, String date, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              day,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              date,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard(String time, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[400]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: isSelected ? Colors.white : Colors.black,
            ),
            SizedBox(width: 5),
            Text(
              time,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
