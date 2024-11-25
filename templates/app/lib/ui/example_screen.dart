import 'package:example_app/core/services/native/constants/modal_styles.dart';
import 'package:example_app/core/services/native/triggers/alerts.dart';
import 'package:example_app/core/services/native/triggers/modal.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ExampleScreen extends StatefulWidget {
  final Map<String, dynamic> args;

  const ExampleScreen({
    super.key,
    required this.args,
  });

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  late ModalConfiguration _currentConfig;
  Color _selectedColor = Colors.white;
  double _cornerRadius = 10;
  double _headerHeight = 56;

  @override
  void initState() {
    super.initState();
    _currentConfig = const ModalConfiguration(
      presentationStyle: ModalPresentationStyle.sheet,
      detents: [ModalDetent.medium, ModalDetent.large],
      initialDetent: ModalDetent.medium,
      isDismissible: true,
      showDragIndicator: true,
      enableSwipeGesture: true,
    );
  }

  void _updateConfiguration(ModalConfiguration newConfig) {
    setState(() => _currentConfig = newConfig);
    final modalId = widget.args['modalId'];
    if (modalId != null) {
      debugPrint('Updating modal configuration for ID: $modalId');
      ModalService.updateModalConfiguration(modalId.toString(), newConfig);
    } else {
      debugPrint('No modalId found in arguments');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              widget.args['img'] ?? '',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
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
                    widget.args['description'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Modal Configuration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Presentation Style
                  Row(
                    children: [
                      const Text('Presentation Style:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Text(
                        '(Live Updates ✅)',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ModalPresentationStyle.values.map((style) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: OutlinedButton(
                            onPressed: () => _updateConfiguration(_currentConfig.copyWith(
                              presentationStyle: style,
                            )),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _currentConfig.presentationStyle == style 
                                ? Colors.blue.withOpacity(0.1) 
                                : null,
                            ),
                            child: Text(style.name),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Detents
                  Row(
                    children: [
                      const Text('Detents:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Text(
                        '(Live Updates ✅)',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _updateConfiguration(_currentConfig.copyWith(
                            detents: [ModalDetent.small],
                            initialDetent: ModalDetent.small,
                          )),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _currentConfig.detents.contains(ModalDetent.small)
                                ? Colors.blue.withOpacity(0.1)
                                : null,
                          ),
                          child: const Text('Small'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => _updateConfiguration(_currentConfig.copyWith(
                            detents: [ModalDetent.medium],
                            initialDetent: ModalDetent.medium,
                          )),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _currentConfig.detents.contains(ModalDetent.medium)
                                ? Colors.blue.withOpacity(0.1)
                                : null,
                          ),
                          child: const Text('Medium'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => _updateConfiguration(_currentConfig.copyWith(
                            detents: [ModalDetent.large],
                            initialDetent: ModalDetent.large,
                          )),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _currentConfig.detents.contains(ModalDetent.large)
                                ? Colors.blue.withOpacity(0.1)
                                : null,
                          ),
                          child: const Text('Large'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => _updateConfiguration(_currentConfig.copyWith(
                            detents: [ModalDetent.medium, ModalDetent.large],
                            initialDetent: ModalDetent.medium,
                          )),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _currentConfig.detents.length > 1
                                ? Colors.blue.withOpacity(0.1)
                                : null,
                          ),
                          child: const Text('Multiple'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Transition Style
                  Row(
                    children: [
                      const Text('Transition Style:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Text(
                        '(Live Updates ❌)',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ModalTransitionStyle.values.map((style) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: OutlinedButton(
                            onPressed: () => _updateConfiguration(_currentConfig.copyWith(
                              transitionStyle: style,
                            )),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _currentConfig.transitionStyle == style
                                  ? Colors.blue.withOpacity(0.1)
                                  : null,
                            ),
                            child: Text(style.name),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Swipe Direction
                  const Text('Swipe Direction:', style: TextStyle(fontWeight: FontWeight.w500)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: SwipeDismissDirection.values.map((direction) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: OutlinedButton(
                            onPressed: () => _updateConfiguration(_currentConfig.copyWith(
                              swipeDismissDirection: direction,
                            )),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _currentConfig.swipeDismissDirection == direction
                                  ? Colors.blue.withOpacity(0.1)
                                  : null,
                            ),
                            child: Text(direction.name),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Toggle options
                  Row(
                    children: [
                      const Text('Options:', style: TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8),
                      Text(
                        '(Live Updates ✅)',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text('Dismissible'),
                    value: _currentConfig.isDismissible,
                    onChanged: (value) => _updateConfiguration(_currentConfig.copyWith(
                      isDismissible: value,
                    )),
                  ),
                  SwitchListTile(
                    title: const Text('Show Drag Indicator'),
                    value: _currentConfig.showDragIndicator,
                    onChanged: (value) => _updateConfiguration(_currentConfig.copyWith(
                      showDragIndicator: value,
                    )),
                  ),
                  SwitchListTile(
                    title: const Text('Enable Swipe Gesture'),
                    value: _currentConfig.enableSwipeGesture,
                    onChanged: (value) => _updateConfiguration(_currentConfig.copyWith(
                      enableSwipeGesture: value,
                    )),
                  ),
                  const SizedBox(height: 16),

                  // Corner Radius
                  const Text('Corner Radius:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Slider(
                    value: _cornerRadius,
                    min: 0,
                    max: 32,
                    divisions: 32,
                    label: _cornerRadius.round().toString(),
                    onChanged: (value) {
                      setState(() => _cornerRadius = value);
                      _updateConfiguration(_currentConfig.copyWith(
                        cornerRadius: value,
                      ));
                    },
                  ),
                  const SizedBox(height: 16),

                  // Background Color
                  const Text('Background Color:', style: TextStyle(fontWeight: FontWeight.w500)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Colors.white,
                        Colors.black,
                        Colors.red,
                        Colors.green,
                        Colors.blue,
                        Colors.yellow,
                      ].map((color) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () {
                              setState(() => _selectedColor = color);
                              _updateConfiguration(_currentConfig.copyWith(
                                backgroundColor: color,
                              ));
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                border: Border.all(
                                  color: _selectedColor == color
                                      ? Colors.blue
                                      : Colors.grey,
                                  width: _selectedColor == color ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header Style
                  const Text('Header Style:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Slider(
                    value: _headerHeight,
                    min: 44,
                    max: 88,
                    divisions: 44,
                    label: _headerHeight.round().toString(),
                    onChanged: (value) {
                      setState(() => _headerHeight = value);
                      _updateConfiguration(_currentConfig.copyWith(
                        headerStyle: ModalHeaderStyle(
                          height: value,
                          backgroundColor: Colors.white,
                          showDivider: true,
                        ),
                      ));
                    },
                  ),

                  const SizedBox(height: 24),
                  // Reset Button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentConfig = const ModalConfiguration(
                          presentationStyle: ModalPresentationStyle.sheet,
                          detents: [ModalDetent.medium, ModalDetent.large],
                          initialDetent: ModalDetent.medium,
                          isDismissible: true,
                          showDragIndicator: true,
                          enableSwipeGesture: true,
                        );
                        _cornerRadius = 10;
                        _headerHeight = 56;
                        _selectedColor = Colors.white;
                      });
                      final modalId = widget.args['modalId'];
                      if (modalId != null) {
                        debugPrint('Updating modal configuration for ID: $modalId');
                        ModalService.updateModalConfiguration(modalId.toString(), _currentConfig);
                      } else {
                        debugPrint('No modalId found in arguments');
                      }
                    },
                    child: const Text('Reset All'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
