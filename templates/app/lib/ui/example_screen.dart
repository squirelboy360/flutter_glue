import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../core/services/native/triggers/modal.dart';

class ExampleScreen extends StatelessWidget {
  final String img;
  final String title;

  const ExampleScreen({
    super.key,
    required this.img,
    required this.title,
  });

  @override
  Widget build(BuildContext context) => FTheme(
        data: FThemes.zinc.light,
        child: FScaffold(
          header: FHeader(
            title: Text(title),
          ),
          content: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    try {
                      ModalService.showModalWithRoute(
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
                
                Image.network(img),
                Text(title),
              ],
            ),
          ),
        ),
      );
}
