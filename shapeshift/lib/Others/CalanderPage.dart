// ignore_for_file: library_private_types_in_public_api, file_names

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  late final Map<DateTime, List<Event>> _events;

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier([]);
    _events = {
      DateTime.utc(2023, 4, 26): [const Event('Event 1')],
      DateTime.utc(2023, 4, 27): [const Event('Event 2')],
      DateTime.utc(2023, 4, 26): [const Event('Event 3')],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar Page'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: DateTime.now(),
            eventLoader: (day) => _events[day] ?? [],
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedEvents.value = _events[selectedDay] ?? [];
              });
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, events, _) {
                if (events.isEmpty) {
                  return const Center(
                    child: Text('No events for selected day.'),
                  );
                }
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(events[index].name),
                    );
                  },
                );
              },
            ),
          ),
          const Image(
            image: NetworkImage(
                'https://www.verywellfit.com/thmb/5BmWCs3muNUIJOz_kTsWnmF58sQ=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/Dotdash-VWFit-reasons-to-hire-a-personal-trainer-1231372-v1-c822137213bb460ab973a5d651c31fe7.jpg'),
          ),
        ],
      ),
    );
  }
}

class Event {
  const Event(this.name);
  final String name;
}
