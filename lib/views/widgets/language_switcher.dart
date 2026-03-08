import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language, color: Colors.black,),
      onSelected: (locale){
        context.setLocale(locale);
      },
      itemBuilder: (context) => const[
        PopupMenuItem(
          value: Locale('en'),
          child: Text('English'),
        ),
        PopupMenuItem(
          value: Locale('si'),
          child: Text('සිංහල'),
        ),
        PopupMenuItem(
          value: Locale('ta'),
          child: Text('தமிழ்'),
        ), 
      ],
    );
  }
}