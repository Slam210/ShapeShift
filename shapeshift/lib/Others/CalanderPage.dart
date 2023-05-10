// ignore_for_file: file_names, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
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
  late final ValueNotifier<DateTime> _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = ValueNotifier(DateTime.now());
    _selectedEvents = ValueNotifier([]);
    _events = {};

    _fetchEventsFromFirestore();
  }

  void showWorkouts() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose a workout'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('My workouts'),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  child: SizedBox(
                    height: 150,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.userId)
                          .collection('workouts')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Text('Loading...');
                        }

                        final data = snapshot.data!.docs
                            .map((doc) => doc['title'])
                            .toList();
                        return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(data[index]),
                              onTap: () {
                                final DateTime selectedDay = _selectedDay.value;
                                final String title = data[index];

                                final Event event = Event(selectedDay, title);
                                addEvent(selectedDay, event);

                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Group workouts'),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  child: SizedBox(
                    height: 150,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Group')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          final List<DocumentSnapshot> groupDocuments =
                              snapshot.data!.docs;
                          final List<DocumentSnapshot> joinedGroupDocuments =
                              groupDocuments
                                  .where((doc) =>
                                      (doc['members'] as List<dynamic>)
                                          .contains(widget.userId))
                                  .toList();

                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35,
                            child: ListView.builder(
                              itemCount: joinedGroupDocuments.length,
                              itemBuilder: (context, index) {
                                final DocumentSnapshot groupDoc =
                                    joinedGroupDocuments[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16.0),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.35,
                                      child: SingleChildScrollView(
                                        child: StreamBuilder<QuerySnapshot>(
                                          stream: groupDoc.reference
                                              .collection('workouts')
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            } else {
                                              final List<DocumentSnapshot>
                                                  workoutDocs =
                                                  snapshot.data!.docs;
                                              return ListView.builder(
                                                shrinkWrap:
                                                    true, // Add this to wrap the ListView with content
                                                itemCount:
                                                    workoutDocs.length - 1,
                                                itemBuilder: (context, index) {
                                                  final DocumentSnapshot
                                                      workoutDoc =
                                                      workoutDocs[index];
                                                  return ListTile(
                                                    title: Text(
                                                        workoutDoc['title']),
                                                    onTap: () {
                                                      final DateTime
                                                          selectedDay =
                                                          _selectedDay.value;
                                                      final String title =
                                                          workoutDoc['title'];

                                                      final Event event = Event(
                                                          selectedDay, title);
                                                      addEvent(
                                                          selectedDay, event);

                                                      Navigator.pop(context);
                                                    },
                                                  );
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }

  void _fetchEventsFromFirestore() {
    FirebaseFirestore.instance
        .collection('Calendar')
        .doc(widget.userId)
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        final eventData = snapshot.data() as Map<String, dynamic>;
        eventData.forEach((key, value) {
          final DateTime date = DateTime.parse(key);
          final String title = value.toString();
          final Event event = Event(date, title);

          setState(() {
            _events[date] = [...(_events[date] ?? []), event];
          });
        });
      }
    });
  }

  void addEvent(DateTime date, Event event) {
    setState(() {
      _events[date] = [...(_events[date] ?? []), event];
      _selectedEvents.value = _events[date] ?? [];
    });

    FirebaseFirestore.instance
        .collection('Calendar')
        .doc(widget.userId)
        .collection('events')
        .add({
      'date': date,
      'title': event.title,
    });
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
            focusedDay: _selectedDay.value,
            selectedDayPredicate: (day) {
              return isSameDay(day, _selectedDay.value);
            },
            eventLoader: (day) => _events[day] ?? [],
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay.value = selectedDay;
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
                      title: Text(events[index].title),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showWorkouts,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Event {
  final DateTime date;
  final String title;

  Event(this.date, this.title);
}
