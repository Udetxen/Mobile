import 'expense.dart';
import 'user.dart';
import 'venue.dart';

class Trip {
  String uid;
  User? creator;
  String name;
  DateTime startDate;
  int duration;
  DateTime? endDate;
  Venue departure;
  Venue destination;
  double budget;
  List<Expense>? expenses;
  String type;
  List<Participant>? participants;

  Trip({
    required this.uid,
    this.creator,
    required this.name,
    required this.startDate,
    required this.duration,
    this.endDate,
    required this.departure,
    required this.destination,
    this.expenses,
    required this.budget,
    required this.type,
    this.participants,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      uid: json['uid'],
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      duration: json['duration'],
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      departure: Venue.fromJson(json['departure']),
      destination: Venue.fromJson(json['destination']),
      expenses:
          (json['expenses'] as List).map((e) => Expense.fromJson(e)).toList(),
      budget: json['budget'],
      type: json['type'],
      participants: json['participants'] != null
          ? (json['participants'] as List)
              .map((e) => Participant.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'creator': creator?.toJson(),
      'name': name,
      'startDate': startDate.toIso8601String(),
      'duration': duration,
      'endDate': endDate?.toIso8601String(),
      'departure': departure.toJson(),
      'destination': destination.toJson(),
      'expenses': expenses?.map((e) => e.toJson()).toList(),
      'budget': budget,
      'type': type,
      'participants': participants?.map((e) => e.toJson()).toList(),
    };
  }
}

class Participant {
  String participantUid;
  double? personalBudget;
  List<Expense>? expenses;

  Participant({
    required this.participantUid,
    required this.personalBudget,
    required this.expenses,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      participantUid: json['participantUid'],
      personalBudget: json['personalBudget'],
      expenses:
          (json['expenses'] as List).map((e) => Expense.fromJson(e)).toList(),
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
