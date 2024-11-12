import 'package:example_app/core/services/native/constants/modal_styles.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import 'package:go_router/go_router.dart';

import '../core/services/native/triggers/modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Flutter Template'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              try {
                ModalService.showModalWithRoute(
                  showNativeHeader: true,
                  showCloseButton: true,
                  headerTitle: "Example Title",
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
          IconButton(
            icon: FIcon(FAssets.icons.info),
            onPressed: () {
              ModalService.showModalWithRoute(
                  route: '/license', arguments: {}, showNativeHeader: false);
            },
          ),
        ],
      ),
      content: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
         
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                context.go('info');
              },
              child: FCard(
               
              ),
            ),
          );
        },
      ),
      footer: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FButton(
            onPress: () {
              ModalService.showModalWithRoute(
                  route: '/',
                  arguments: {},
                  configuration: const ModalConfiguration(
                      presentationStyle: ModalPresentationStyle.fullScreen));
            },
            label: const Text("Scrollable Modal")),
      ),
    );
  }
}
