class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.referenceId,
    required this.referenceType,
    required this.statusLabel,
    required this.notificationType,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final String referenceId;
  final String referenceType;
  final String statusLabel;
  final String notificationType;
  final DateTime? createdAt;

  bool get hasReference => referenceId.isNotEmpty;
  bool get canOpenLicenseDetails {
    final type = referenceType.toLowerCase();
    return hasReference &&
        (type.contains('license') ||
            type.contains('application') ||
            type.contains('complaint') ||
            type.contains('request') ||
            type.isEmpty);
  }

  String get statusLabelTranslated =>
      statusLabel.isEmpty ? '' : _translateStatusLabel(statusLabel);

  String get notificationTypeTranslated => notificationType.isEmpty
      ? ''
      : _translateNotificationType(notificationType);

  static String _translateStatusLabel(String value) {
    final lower = value.toLowerCase();
    if (_containsArabic(value)) return value;
    if (lower.contains('pending')) return 'قيد المراجعة';
    if (lower.contains('review')) return 'قيد المراجعة';
    if (lower.contains('approved') || lower.contains('accepted'))
      return 'تمت الموافقة';
    if (lower.contains('rejected') || lower.contains('declined'))
      return 'مرفوض';
    if (lower.contains('completed') || lower.contains('finished'))
      return 'مكتمل';
    if (lower.contains('processing') || lower.contains('in progress'))
      return 'قيد التنفيذ';
    if (lower.contains('new')) return 'جديد';
    if (lower.contains('read')) return 'مقروء';
    if (lower.contains('unread')) return 'غير مقروء';
    if (lower.contains('cancel') || lower.contains('canceled')) return 'ملغى';
    if (lower.contains('draft')) return 'مسودة';
    if (lower.contains('approved')) return 'موافقة';
    return value;
  }

  static String _translateNotificationType(String value) {
    final lower = value.toLowerCase();
    if (_containsArabic(value)) return value;
    if (lower.contains('license')) return 'طلب ترخيص';
    if (lower.contains('application')) return 'طلب';
    if (lower.contains('complaint')) return 'شكوى';
    if (lower.contains('reminder')) return 'تذكير';
    if (lower.contains('alert')) return 'تنبيه';
    if (lower.contains('message')) return 'رسالة';
    if (lower.contains('info')) return 'معلومة';
    if (lower.contains('update')) return 'تحديث';
    if (lower.contains('approval')) return 'موافقة';
    return value;
  }

  static bool _containsArabic(String value) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(value);
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataMap = data is Map<String, dynamic> ? data : <String, dynamic>{};

    String title = '';
    String body = '';

    if (dataMap.isNotEmpty) {
      title =
          dataMap['title']?.toString() ??
          dataMap['body']?.toString() ??
          dataMap['message']?.toString() ??
          '';
      body =
          dataMap['body']?.toString() ??
          dataMap['message']?.toString() ??
          dataMap['title']?.toString() ??
          '';
    }

    title = title.isNotEmpty
        ? title
        : json['title']?.toString() ?? json['message']?.toString() ?? '';
    body = body.isNotEmpty
        ? body
        : json['body']?.toString() ?? json['message']?.toString() ?? '';

    String extractField(List<String> keys) {
      for (final key in keys) {
        final value = dataMap[key] ?? json[key];
        if (value != null) {
          return value.toString();
        }
      }
      return '';
    }

    final referenceId = extractField([
      'reference_id',
      'application_id',
      'license_id',
      'complaint_id',
      'request_id',
      'id',
    ]);

    final referenceType = extractField([
      'reference_type',
      'type',
      'notification_type',
      'category',
    ]).toLowerCase();

    final statusLabel = extractField(['status', 'state']);
    final notificationType = extractField(['notification_type', 'category']);

    final createdAt = _parseDateTime(
      json['created_at'] ?? json['createdAt'] ?? json['date'],
    );
    final time =
        _formatRelativeTime(createdAt) ?? json['time']?.toString() ?? '';
    final isRead =
        json['read_at'] != null ||
        json['readAt'] != null ||
        json['read'] == true;

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: title,
      body: body,
      time: time,
      isRead: isRead,
      referenceId: referenceId,
      referenceType: referenceType,
      statusLabel: statusLabel,
      notificationType: notificationType,
      createdAt: createdAt,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? time,
    bool? isRead,
    String? referenceId,
    String? referenceType,
    String? statusLabel,
    String? notificationType,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      referenceId: referenceId ?? this.referenceId,
      referenceType: referenceType ?? this.referenceType,
      statusLabel: statusLabel ?? this.statusLabel,
      notificationType: notificationType ?? this.notificationType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static String? _formatRelativeTime(DateTime? dateTime) {
    if (dateTime == null) return null;

    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) {
      return 'الآن';
    }
    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    }
    if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    }
    if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} يوم';
    }
    return 'منذ ${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
  }
}
