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
      DateTime.utc(2022, 4, 28): [Event('Event 1')],
      DateTime.utc(2022, 5, 3): [Event('Event 2')],
      DateTime.utc(2022, 5, 5): [Event('Event 3')],
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
              _selectedEvents.value = _events[selectedDay] ?? [];
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, events, _) {
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
        ],
      ),
    );
  }
}

class Event {
  const Event(this.name);
  final String name;
}
