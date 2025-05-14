import 'package:flutter/material.dart';

class GenerateButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  const GenerateButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? CircularProgressIndicator()
        : FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(Icons.schedule, color: Color.fromARGB(255, 44, 76, 255)),
          label: Text(
            "Generate Schedule",
            style: TextStyle(
              color: Color.fromARGB(255, 44, 76, 255),
              fontWeight: FontWeight.w500,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 176, 220, 255),
            minimumSize: Size(300, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(fontSize: 16),
          ),
        );
  }
}
