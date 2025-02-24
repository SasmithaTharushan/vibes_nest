import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityPage extends StatelessWidget {
  final List<Map<String, String>> communityLinks = [
    {
      "name": "WhatsApp Community",
      "url": "https://chat.whatsapp.com/Jn6xBKok9AoJX9glvpnsay",
      "icon": "assets/images/whatsapp.png"
    },
    {
      "name": "Telegram Group",
      "url": "https://t.me/joinchat/example",
      "icon": "assets/images/telegram.jpg"
    },
    {
      "name": "Discord Server",
      "url": "https://discord.gg/example",
      "icon": "assets/images/discord.png"
    },
  ];

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Community"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Join Our Communities",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: communityLinks.map((community) {
                  return GestureDetector(
                    onTap: () => _launchURL(community["url"]!),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.white,
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(community["icon"]!, height: 50),
                          SizedBox(height: 10),
                          Text(community["name"]!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              Text("Trending Topics",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTopicCard("Dealing with Anxiety"),
                    _buildTopicCard("Self-Care Tips"),
                    _buildTopicCard("Mindfulness Techniques"),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text("Community Members",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                children: List.generate(
                    6, (index) => _buildUserAvatar("User ${index + 1}")),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.teal,
        child: Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  Widget _buildTopicCard(String topic) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(topic, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildUserAvatar(String name) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.teal,
          child: Icon(Icons.person, color: Colors.white, size: 30),
        ),
        SizedBox(height: 5),
        Text(name, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
