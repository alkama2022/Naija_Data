/// A notification item.
///
/// Matches the prototype's NOTIFS array:
/// [title, body, date, letter, isRead]
class NotificationModel {
  final String title;
  final String body;
  final String date;
  final String letter;
  final bool isRead;

  const NotificationModel({
    required this.title,
    required this.body,
    required this.date,
    required this.letter,
    required this.isRead,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      title: title,
      body: body,
      date: date,
      letter: letter,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'date': date,
        'letter': letter,
        'isRead': isRead,
      };

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      date: json['date'] as String? ?? '',
      letter: json['letter'] as String? ?? 'D',
      isRead: json['isRead'] as bool? ?? false,
    );
  }
}
