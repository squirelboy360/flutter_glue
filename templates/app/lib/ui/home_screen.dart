import 'package:example_app/core/services/native/utils/constants/modal/modal_configs.dart';
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
        title: const Text('Flutter+Native'),
        
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              try {
                ModalService.showModalWithRoute(
                  const ModalConfig(
                    arguments: {},
                    headerTitle: 'Modal Title',
                    isDismissible: true,
                    showCloseButton: true,
                    detents: ['large'],
                    style: ModalStyle(
                      backgroundColor: Colors.white,
                    ),
                  ),
                  route: '/example',
                  arguments: {},
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
                const ModalConfig(
                  // <-- Provide ModalConfig here

                  arguments: {},
                  showNativeHeader: false,
                ),
                route: '/license', // <-- Use route as named argument
                arguments: {},
              );
            },
          ),
        ],
      ),
      content: Column(
        children: [
          GestureDetector(
            onTap: () {
              context.go('/license');
            },
            child: FCard(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 150,
                  margin: EdgeInsets.zero,
                  decoration: const BoxDecoration(
                      image: DecorationImage(fit:BoxFit.cover,
                          image: NetworkImage(
                              "https://pbs.twimg.com/media/FKNlhKZUcAEd7FY.jpg:large"))),
                ),
              ),
            ),
          ),
        ],
      ),
      footer: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FButton(
          onPress: () {
            ModalService.showModalWithRoute(
              const ModalConfig(
                // <-- Provide ModalConfig here
                isDismissible: true,
                showCloseButton: true,
                detents: ['large'],
                style: ModalStyle(
                  backgroundColor: Colors.white,
                ),
              ),
              route: '/', // <-- Use route as named argument
              arguments: {},
            );
          },
          label: const Text("Scrollable Modal"),
        ),
      ),
    );
  }
}
