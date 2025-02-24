import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LibraryPage extends StatelessWidget {
  final List<Map<String, String>> books = [
    {
      'title': 'Little Blue Book of Sunshine',
      'description': 'A guide to mental well-being for young people.',
      'image':
          'https://cypf.berkshirehealthcare.nhs.uk/media/168458/little-blue-book-of-sunshine.jpg',
      'url':
          'https://cypf.berkshirehealthcare.nhs.uk/media/168458/little-blue-book-of-sunshine.pdf'
    },
    {
      'title': 'Youth Mental Handbook',
      'description': 'A comprehensive mental health resource for young people.',
      'image':
          'https://i-lib.imu.edu.my/pluginfile.php/3109/mod_resource/content/2/Youth%20Mental%20Handbook.jpg',
      'url':
          'https://i-lib.imu.edu.my/pluginfile.php/3109/mod_resource/content/2/Youth%20Mental%20Handbook.pdf'
    },
    {
      'title': 'The Practices of Happiness',
      'description': 'A book on the science and philosophy of happiness.',
      'image':
          'https://reader.bookfusion.com/books/138653-the-practices-of-happiness.jpg',
      'url':
          'https://reader.bookfusion.com/books/138653-the-practices-of-happiness?type=pdf'
    },
    {
      'title': 'Mental Health Guidebook',
      'description': 'A global mental health guidebook for primary care.',
      'image':
          'https://www.globalfamilydoctor.com/site/DefaultSite/filesystem/documents/resources/MHGuidebook-EBookDownload.jpg',
      'url':
          'https://www.globalfamilydoctor.com/site/DefaultSite/filesystem/documents/resources/MHGuidebook-EBookDownload.pdf'
    }
  ];

  void _openBook(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not open $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Library'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: ListView.builder(
          itemCount: books.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _openBook(books[index]['url']!),
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/placeholder.jpg',
                        image: books[index]['image']!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/placeholder.jpg',
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            books[index]['title']!,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            books[index]['description']!,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
