class Log {
  final int id;
  final bool authorized;
  final double confidence;
  final String name;
  final String role;
  final String timestamp;
  final DateTime createdAt;
  final DateTime updatedAt;

  Log({
    required this.id,
    required this.authorized,
    required this.confidence,
    required this.name,
    required this.role,
    required this.timestamp,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['id'] as int,
      authorized: json['authorized'] as bool,
      confidence: (json['confidence'] as num).toDouble(),
      name: json['name'] as String,
      role: json['role'] as String,
      timestamp: json['timestamp'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorized': authorized,
      'confidence': confidence,
      'name': name,
      'role': role,
      'timestamp': timestamp,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class LogCreate {
  final bool authorized;
  final double confidence;
  final String name;
  final String role;
  final String timestamp;

  LogCreate({
    required this.authorized,
    required this.confidence,
    required this.name,
    required this.role,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'authorized': authorized,
      'confidence': confidence,
      'name': name,
      'role': role,
      'timestamp': timestamp,
    };
  }
}

class LogStatsResponse {
  final List<Log> data;
  final int count;
  final int unknownVisitors;

  LogStatsResponse({
    required this.data,
    required this.count,
    required this.unknownVisitors,
  });

  factory LogStatsResponse.fromJson(Map<String, dynamic> json) {
    return LogStatsResponse(
      data: (json['data'] as List)
          .map((item) => Log.fromJson(item as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int,
      unknownVisitors: json['unknown_visitors'] as int,
    );
  }
}

class LogsResponse {
  final List<Log> data;

  LogsResponse({
    required this.data,
  });

  factory LogsResponse.fromJson(Map<String, dynamic> json) {
    return LogsResponse(
      data: (json['data'] as List)
          .map((item) => Log.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

enum LogFilterPeriod {
  today,
  date,
  range,
}

class LogFilterParams {
  final LogFilterPeriod? period;
  final String? date; // YYYY-MM-DD
  final String? start; // YYYY-MM-DD
  final String? end; // YYYY-MM-DD
  final String? name;

  LogFilterParams({
    this.period,
    this.date,
    this.start,
    this.end,
    this.name,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    if (period != null) {
      params['period'] = period!.name;
    }
    if (date != null) {
      params['date'] = date!;
    }
    if (start != null) {
      params['start'] = start!;
    }
    if (end != null) {
      params['end'] = end!;
    }
    if (name != null) {
      params['name'] = name!;
    }

    return params;
  }
}
