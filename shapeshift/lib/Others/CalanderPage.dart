// ignore_for_file: library_private_types_in_public_api, file_names, use_build_context_synchronously

import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  final String userId;

  const CalendarPage({Key? key, required this.userId}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  LinkedHashMap<DateTime, List<Event>> _events = LinkedHashMap(
    equals: isSameDay,
    hashCode: getHashCode,
  );

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
                                final String title = data[index];
                                addEventToCalendar(title);
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
                                                  itemCount: workoutDocs.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final DocumentSnapshot
                                                        workoutDoc =
                                                        workoutDocs[index];
                                                    if (workoutDoc.exists &&
                                                        workoutDoc.data() !=
                                                            null &&
                                                        (workoutDoc.data()
                                                                as Map<String,
                                                                    dynamic>)
                                                            .isNotEmpty) {
                                                      return ListTile(
                                                        title: Text(workoutDoc[
                                                            'title']),
                                                        onTap: () {
                                                          final String title =
                                                              workoutDoc[
                                                                  'title'];
                                                          addEventToCalendar(
                                                              title);
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      );
                                                    }
                                                    return Container();
                                                  });
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

  void addEventToCalendar(String workout) async {
    final newEvent = Event(_selectedDay, workout);
    setState(() {
      if (_events.containsKey(_selectedDay)) {
        _events[_selectedDay]!.add(newEvent);
      } else {
        _events[_selectedDay] = [newEvent];
      }
    });

    try {
      final eventsCollection = FirebaseFirestore.instance
          .collection('Calendar')
          .doc(widget.userId)
          .collection('events');

      await eventsCollection.add({
        'date': _selectedDay,
        'title': workout,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding event to Firestore: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeEvents();
  }

  void _initializeEvents() async {
    try {
      final userId = widget.userId;
      final eventsSnapshot = await FirebaseFirestore.instance
          .collection('Calendar')
          .doc(userId)
          .collection('events')
          .get();

      final eventSource = eventsSnapshot.docs.map((doc) {
        final timestamp = doc['date'] as Timestamp;
        final title = doc['title'] as String;
        final date = timestamp.toDate();
        return Event(date, title);
      }).toList();

      _events = LinkedHashMap(
        equals: isSameDay,
        hashCode: getHashCode,
      )..addAll({
          for (var event in eventSource) event.date: [event]
        });

      setState(() {}); // Update the state after fetching events
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching events: $e');
      }
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _focusedDay = focusedDay;
        _selectedDay = selectedDay;
      });
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(children: [
        TableCalendar(
          firstDay: DateTime.utc(2021, 1, 1),
          lastDay: DateTime.utc(2023, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            // Return true if the day is selected
            return isSameDay(_selectedDay, day);
          },
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onDaySelected: _onDaySelected,
          onPageChanged: _onPageChanged, // Add the onPageChanged callback
          eventLoader: (day) {
            return _getEventsForDay(day);
          },
        ),
        const SizedBox(height: 16),
        Expanded(
          child: EventListView(
            selectedDay: _selectedDay,
            events: _events,
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showWorkouts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EventListView extends StatelessWidget {
  final DateTime selectedDay;
  final LinkedHashMap<DateTime, List<Event>> events;

  const EventListView({
    super.key,
    required this.selectedDay,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    final selectedEvents = events[selectedDay] ?? [];

    return ListView.builder(
      itemCount: selectedEvents.length,
      itemBuilder: (context, index) {
        final event = selectedEvents[index];
        return ListTile(
          title: Text(event.title),
          subtitle: Text(event.date.toString()),
        );
      },
    );
  }
}

class Event {
  final DateTime date;
  final String title;

  Event(this.date, this.title);
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

int getHashCode(DateTime key) {
  return key.year * 10000 + key.month * 100 + key.day;
}
