import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:firstly/pages/chat_screen.dart';

class CommunityScreen extends StatefulWidget {
  @override
  _CommunityScreen createState() => _CommunityScreen();
}

class _CommunityScreen extends State<CommunityScreen> {
  bool showMyCommunities = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // **Mood Tracking Section**
          Container(
            padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
            child: Row(
              children: [
                Icon(CupertinoIcons.chat_bubble, color: Colors.black),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatScreen()),
                    );
                  },
                  child: Text('Want to try our chat bot ?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // **Expert connection section**
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Expert Image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://via.placeholder.com/100'), // Replace with actual image URL
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16),
                // Expert Details
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. Uroos Fatima',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Psychiatrist'),
                        Text('MBBS, MD'),
                        // Map Placeholder
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(child: Text('Map Placeholder')),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // **Community Chat Section**
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Have a chat with the community',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/50')),
                SizedBox(width: 10),
                Text("Spirituality"),
                SizedBox(width: 10),
                CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/50')),
                SizedBox(width: 10),
                Text("Art & Craft"),
                SizedBox(width: 10),
                CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/50')),
                SizedBox(width: 10),
                Text("Spirituality"),
                SizedBox(width: 10),
                CircleAvatar(radius: 30, backgroundColor: Colors.black),
                SizedBox(width: 10),
                Text("Coming Soon"),
              ],
            ),
          ),

          // **Community Screen Section**
          Padding(
            padding: const EdgeInsets.only(
                top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Communities',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(CupertinoIcons.search, color: Colors.black),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All communities',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('View all', style: TextStyle(color: Colors.blue)),
              ],
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                CircleAvatar(radius: 30, child: Icon(Icons.healing)),
                SizedBox(width: 10),
                CircleAvatar(radius: 30, child: Icon(Icons.color_lens)),
                SizedBox(width: 10),
                CircleAvatar(radius: 30, child: Icon(Icons.self_improvement)),
                SizedBox(width: 10),
                CircleAvatar(radius: 30, child: Icon(Icons.favorite)),
                SizedBox(width: 10),
              ],
            ),
          ),

          // **Combined "My feed" and "My communities" tabs**
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showMyCommunities = false;
                    });
                  },
                  child: Text('My feed',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: showMyCommunities
                              ? FontWeight.normal
                              : FontWeight.bold)),
                ),
                SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showMyCommunities = true;
                    });
                  },
                  child: Text('My communities',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: showMyCommunities
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ),
              ],
            ),
          ),

          // **Post Creation Section**
          if (!showMyCommunities)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage('https://via.placeholder.com/40'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Write your post here'),
                  ),
                ],
              ),
            ),
          if (!showMyCommunities)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text('Add your post in'),
                  Icon(Icons.arrow_drop_down),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text('Publish Post'),
                  ),
                ],
              ),
            ),

          // **Example Post**
          if (!showMyCommunities)
            Card(
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Posted in Reiki Healing',
                        style: TextStyle(color: Colors.grey)),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage:
                              NetworkImage('https://via.placeholder.com/40'),
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Aarav Sharma'),
                            Text('Banglore, India',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        Spacer(),
                        Text('view community',
                            style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('This is what I learned in my recent course'),
                    SizedBox(height: 10),
                    Text('"The whole secret of existence"'),
                  ],
                ),
              ),
            ),

          // **Community List**
          if (showMyCommunities)
            Expanded(
              child: ListView(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  CommunityCard(
                      title: 'Reiki Healing',
                      rating: '4.3',
                      members: '10K+',
                      onTap: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CommunityDetailScreen()),
                        );
                      }),
                  CommunityCard(
                      title: 'Crystal Healing',
                      rating: '4.3',
                      members: '10K+',
                      onTap: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CommunityDetailScreen()),
                        );
                      }),
                  CommunityCard(
                      title: 'Crypto Currency',
                      rating: '4.3',
                      members: '10K+',
                      onTap: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CommunityDetailScreen()),
                        );
                      }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class CommunityCard extends StatelessWidget {
  final String title;
  final String rating;
  final String members;
  final Function(BuildContext) onTap;

  CommunityCard(
      {required this.title,
      required this.rating,
      required this.members,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.group),
        ),
        title: Text(title),
        subtitle: Text('$rating ⭐ ($members members)'),
        trailing: ElevatedButton(
          onPressed: () {
            onTap(context);
          },
          child: Text('View Community'),
        ),
      ),
    );
  }
}

class CommunityDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 40.0, left: 16.0, right: 16.0, bottom: 0.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                SizedBox(width: 8),
                Text(
                  'Reiki Healing Community',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          CommunityHeader(),
          SizedBox(height: 20),
          CommunityTabs(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome to Healing Community 👋',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ), // <-- Removed extra parenthesis here
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'A supportive space where practitioners and enthusiasts come together to explore the transformative power of Reiki, fostering growth, connection, and self-healing. Join us on this journey of wellness and inner harmony.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          SizedBox(height: 20),
          ImageGrid(),
          SizedBox(height: 20),
          WhatIsCommunity(),
        ],
      ),
    );
  }
}

class CommunityHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reiki Healing',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('4.3 ⭐ (10K+ members)'),
              SizedBox(height: 8),
              Text(
                  'Reiki healing channels universal energy, restoring balance and promoting holistic well-being.'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                child: Text('Join Community ->'),
              ),
            ],
          ),
        ),
        clipBehavior: Clip.hardEdge,
        semanticContainer: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class CommunityTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('About community',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          Text('Feed', style: TextStyle(color: Colors.grey)),
          Text('Sessions', style: TextStyle(color: Colors.grey)),
          Text('Challenges', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class ImageGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: [
          Icon(Icons.healing, size: 50),
          Icon(Icons.self_improvement, size: 50),
          Icon(Icons.favorite, size: 50),
          Icon(Icons.spa, size: 50),
        ],
      ),
    );
  }
}

class WhatIsCommunity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text('What is this community for?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              'This community is for sharing knowledge, experiences, and support related to Reiki healing practices. Connect with fellow practitioners, ask questions, and deepen your understanding of Reiki.'),
        ),
      ],
    );
  }
}
