import '../models/log.dart';
import 'api_service.dart';

class LogService {
  final ApiService _apiService;

  LogService(this._apiService);

  // Get all logs
  Future<LogsResponse> getAllLogs() async {
    try {
      final response = await _apiService.get(
        '/api/logs',
        requiresAuth: true,
      );
      return LogsResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get filtered logs
  Future<LogStatsResponse> getFilteredLogs(LogFilterParams params) async {
    try {
      final response = await _apiService.getWithParams(
        '/api/logs/filter',
        params.toQueryParams(),
        requiresAuth: true,
      );

      print('Filtered Logs Response: $response');
      return LogStatsResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  // Get today's logs
  Future<LogStatsResponse> getTodayLogs() async {
    return getFilteredLogs(
      LogFilterParams(period: LogFilterPeriod.today),
    );
  }

  // Get logs by specific date
  Future<LogStatsResponse> getLogsByDate(String date) async {
    return getFilteredLogs(
      LogFilterParams(
        period: LogFilterPeriod.date,
        date: date,
      ),
    );
  }

  // Get logs by date range
  Future<LogStatsResponse> getLogsByRange(String start, String end) async {
    return getFilteredLogs(
      LogFilterParams(
        period: LogFilterPeriod.range,
        start: start,
        end: end,
      ),
    );
  }

  // Get logs by name
  Future<LogStatsResponse> getLogsByName(String name) async {
    return getFilteredLogs(
      LogFilterParams(
        period: LogFilterPeriod.today,
        name: name,
      ),
    );
  }

  // Create new log entry
  Future<Log> createLog(LogCreate logCreate) async {
    try {
      final response = await _apiService.post(
        '/api/logs',
        logCreate.toJson(),
        requiresAuth: true,
      );
      return Log.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  // Delete log entry
  Future<void> deleteLog(int logId) async {
    try {
      await _apiService.delete(
        '/api/logs/$logId',
        requiresAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
