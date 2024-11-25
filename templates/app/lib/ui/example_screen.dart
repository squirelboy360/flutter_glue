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
    final theme = Theme.of(context);
    return FTheme(
      data: theme.brightness == Brightness.dark 
          ? FThemes.zinc.dark 
          : FThemes.zinc.light,
      child: FScaffold(
        contentPad: false,
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
             
              
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
                icon: const Icon(Icons.add),
                onPressed: () {
                //? Use this to show Alerts
                //  AlertService.showConfirm(title: "Are you sure", message: "message").then((v){
                //   debugPrint(v.toString());
                //  });
                   AlertService.showAlert(title: "Normal Alert", message: "This is a normal alert");
                },
              ),
            ],
          ),
        ),
      );
  }
}
