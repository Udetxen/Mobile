import 'package:cloud_firestore/cloud_firestore.dart';

import 'expense.dart';
import 'user.dart';
import 'venue.dart';

class Trip {
  String? uid;
  User? creator;
  String name;
  DateTime? startDate;
  int duration;
  DateTime? endDate;
  Venue departure;
  Venue destination;
  double budget;
  List<Expense>? expenses;
  String type; // individual, group
  List<Participant>? participants;
  List<String>? participantUids;
  DateTime? updatedAt;

  Trip({
    this.uid,
    this.creator,
    required this.name,
    this.startDate,
    required this.duration,
    this.endDate,
    required this.departure,
    required this.destination,
    this.expenses,
    required this.budget,
    required this.type,
    this.participants,
    this.participantUids,
    this.updatedAt,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      uid: json['uid'],
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
      name: json['name'],
      startDate: json['startDate'] != null
          ? (json['startDate'] as Timestamp).toDate()
          : null,
      duration: json['duration'],
      endDate: json['endDate'] != null
          ? (json['endDate'] as Timestamp).toDate()
          : null,
      departure: Venue.fromJson(json['departure']),
      destination: Venue.fromJson(json['destination']),
      expenses: json['expenses'] != null
          ? (json['expenses'] as List).map((e) => Expense.fromJson(e)).toList()
          : null,
      budget: json['budget'],
      type: json['type'],
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((e) => Participant.fromJson(e))
              .toList()
          : null,
      participantUids: json['participantUids'] != null
          ? (json['participantUids'] as List).map((e) => e.toString()).toList()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'creator': creator?.toJson(),
      'name': name,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'duration': duration,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'departure': departure.toJson(),
      'destination': destination.toJson(),
      'expenses': expenses?.map((e) => e.toJson()).toList(),
      'budget': budget,
      'type': type,
      'participants': participants?.map((e) => e.toJson()).toList(),
      'participantUids': participantUids?.map((e) => e.toString()).toList(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Trip copyWith({
    String? uid,
    User? creator,
    String? name,
    DateTime? startDate,
    int? duration,
    DateTime? endDate,
    Venue? departure,
    Venue? destination,
    double? budget,
    List<Expense>? expenses,
    String? type,
    List<Participant>? participants,
    List<String>? participantUids,
    DateTime? updatedAt,
  }) {
    return Trip(
      uid: uid ?? this.uid,
      creator: creator ?? this.creator,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      duration: duration ?? this.duration,
      endDate: endDate ?? this.endDate,
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      budget: budget ?? this.budget,
      expenses: expenses ?? this.expenses,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      participantUids: participantUids ?? this.participantUids,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Participant {
  String participantUid;
  double? personalBudget;
  List<Expense>? expenses;

  Participant({
    required this.participantUid,
    this.personalBudget,
    this.expenses,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      participantUid: json['participantUid'],
      personalBudget: json['personalBudget'],
      expenses: json['expenses'] != null
          ? (json['expenses'] as List).map((e) => Expense.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participantUid': participantUid,
      'personalBudget': personalBudget,
      'expenses': expenses?.map((e) => e.toJson()).toList(),
    };
  }
}
