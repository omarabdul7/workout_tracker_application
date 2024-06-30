import 'package:flutter/material.dart';
import '../widgets/big_card.dart';
import '../my_app_state.dart';
import '/pages/history_page.dart';
import '/pages/new_workout_page.dart';
import '/pages/settings_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';



class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Page'),
    );
  }
}
