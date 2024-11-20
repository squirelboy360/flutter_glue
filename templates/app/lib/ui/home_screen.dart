import 'package:example_app/core/services/native/constants/modal_styles.dart';
import 'package:example_app/core/services/native/views/text_input_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../core/services/native/triggers/modal.dart';

class ItemData {
  final int id;
  final String title;
  final String description;
  final String imageUrl;

  ItemData({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<ItemData> items;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateItems();
  }

  void _generateItems() {
    final List<String> titles = [
      'Mountain Sunrise',
      'Ocean Waves',
      'Forest Path',
      'Desert Dunes',
      'City Lights',
      'Autumn Colors',
      'Winter Snow',
      'Spring Flowers',
      'Summer Beach',
      'Sunset Valley'
    ];

    final List<String> descriptions = [
      'A breathtaking view of the sun rising over misty mountain peaks',
      'Gentle waves rolling onto a pristine sandy beach at dawn',
      'A serene path winding through an ancient forest',
      'Golden sand dunes stretching endlessly under a clear blue sky',
      'The vibrant glow of city lights reflecting in the night',
      'Trees adorned in brilliant red and gold autumn foliage',
      'Pure white snow blanketing a peaceful landscape',
      'Colorful wildflowers swaying in a gentle spring breeze',
      'Crystal clear waters meeting white sand under summer sun',
      'The last rays of sunlight painting the valley in golden hues'
    ];

    items = List.generate(
      10,
      (index) => ItemData(
        id: index + 1,
        title: titles[index],
        description: descriptions[index],
        imageUrl: 'https://picsum.photos/seed/${index + 1}/800/500',
      ),
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Nature Gallery'),
        actions: [
          IconButton(
            icon: FIcon(FAssets.icons.info),
            onPressed: () {
              ModalService.showModalWithRoute(
                context: context,
                route: '/license',
                arguments: {},
                showNativeHeader: false,
              );
            },
          ),
        ],
      ),
      content: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator.adaptive(
              onRefresh: () async {
                setState(() {
                  isLoading = true;
                });
                _generateItems();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () {
                        ModalService.showModalWithRoute(
                          context: context,
                          showNativeHeader: true,
                          showCloseButton: true,
                          headerTitle: item.title,
                          route: '/example',
                          arguments: {
                            'img': item.imageUrl,
                            'title': item.title,
                            'description': item.description,
                          },
                        );
                      },
                      child: FCard(
                        image: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item.imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            ),
                          ),
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            item.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Text(
                                'View Details',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      footer: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.red[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
                child: TextInputService.createDefaultInput(
              height: 60,
              placeholder: "Enter text",
              onChanged: (value) {
                if (kDebugMode) {
                  print("Text changed: $value");
                }
              },
            ))),
      ),
    );
  }
}
