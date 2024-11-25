import 'package:example_app/core/services/native/triggers/alerts.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ExampleScreen extends StatelessWidget {
  final Map<String, dynamic> args;

  const ExampleScreen({
    super.key,
    required this.args,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              args['img'] ?? '',
              height: 300,
              width: double.infinity,
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
            IconButton(
              onPressed: () {
                AlertService.showAlert(
                  
                  title: "Example Alert",
                  message: "This is an example alert message.",
                );
              },
              icon: const Icon(Icons.info),
            ),
          ],
        ),
      ),
    );
  }
}
