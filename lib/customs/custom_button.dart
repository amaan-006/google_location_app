import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final bool loading;
  final double height;
  final double width;
  final double borderRadius;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.loading = false,
    this.height = 50,
    this.width = double.infinity,
    this.borderRadius = 12,
    this.backgroundColor = const Color.fromARGB(255, 231, 31, 64),
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton(
        onPressed: loading ? null :onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(borderRadius),
          ),
        ),
         child: loading
         ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.amber,
          ),
          
         )
         : Text(title,
         style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: textColor,
         ),)
         ),
    );
  }
}
