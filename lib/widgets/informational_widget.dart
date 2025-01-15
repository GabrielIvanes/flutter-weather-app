import 'package:flutter/material.dart';

class InformationalWidget extends StatelessWidget {
  final String icon;
  final String title;
  final String information;

  const InformationalWidget({
    super.key,
    required this.icon,
    required this.information,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10.0),
        ),
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Image.asset(icon,
                height: 25, width: 25, color: Theme.of(context).primaryColor),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  Text(information,
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
