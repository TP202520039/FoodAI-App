import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {

  final void Function()? onPressed;
  final String text;
  final Color? buttonColor;
  final Color? fontColor;
  final String? imagePath;

  const CustomFilledButton({
    super.key, 
    this.onPressed, 
    required this.text, 
    this.buttonColor,
    this.fontColor,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {

    const radius = Radius.circular(40);

    return FilledButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(buttonColor),
        foregroundColor: WidgetStateProperty.all(fontColor),
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(radius)
          )
        ),
      ),
      onPressed: onPressed, 
      child: imagePath != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                imagePath!,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Text(text),
            ],
          )
        : Text(text),
    );
  }
}