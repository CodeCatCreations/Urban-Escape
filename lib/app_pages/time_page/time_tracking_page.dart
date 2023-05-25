import 'package:flutter/material.dart';
import 'package:urban_escape_application/app_pages/time_page/time_tracker.dart';

class TimeTrackingPage extends StatefulWidget {
  const TimeTrackingPage({super.key});

  @override
  State<TimeTrackingPage> createState() => _TimeTrackingPageState();
}

class _TimeTrackingPageState extends State<TimeTrackingPage> {
  late TimeTracker tracker;

  @override
  void initState() {
    super.initState();
    tracker = TimeTracker(this);
    tracker.initState();
  }

  @override
  Widget build(BuildContext context) {
    return tracker.build(context);
  }
}
          
