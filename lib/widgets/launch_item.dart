import 'package:flutter/material.dart';

class LaunchItem extends StatelessWidget {
  const LaunchItem({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Launch name'),
        subtitle: Text('Launch date'),
      ),
    );
  }
}
