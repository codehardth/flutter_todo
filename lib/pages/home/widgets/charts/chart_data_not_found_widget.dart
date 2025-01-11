import 'package:flutter/material.dart';

class ChartDataNotFoundWidget extends StatelessWidget {
  final IconData icon;

  const ChartDataNotFoundWidget({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: const BorderRadius.all(
            Radius.circular(
              10,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 100,
              color: Colors.grey,
            ),
            const Text('ไม่พบข้อมูล'),
          ],
        ),
      ),
    );
  }
}
