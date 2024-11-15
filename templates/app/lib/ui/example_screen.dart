import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../core/services/native/triggers/modal.dart';

class ExampleScreen extends StatelessWidget {
  final Map<String, dynamic> args;

  const ExampleScreen({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context) => FTheme(
        data: FThemes.zinc.light,
        child: FScaffold(
          header: FHeader(
            title: Text(args['title'] ?? ''),
          ),
          content: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    try {
                      ModalService.showModalWithRoute(context: context,
                        route: '/example',
                        arguments: {
                          'img': 'https://example.com/image.png',
                          'title': 'Example Title'
                        },
                      );
                    } catch (e) {
                      debugPrint('Error showing modal: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                ),
                
                Image.network(
                  args['img'] ?? '',
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        args['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        args['description'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
