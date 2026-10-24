// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. Licensed under the MIT License.

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'configuration.dart';
import 'models/event.dart';

/// Network errors that can occur when sending events.
enum NetworkErrorType {
  notConfigured,
  invalidResponse,
  unauthorized,
  badRequest,
  rateLimited,
  serverError,
  networkError,
}

class NetworkError implements Exception {
  final NetworkErrorType type;
  final String? message;
  final int? statusCode;

  NetworkError(this.type, {this.message, this.statusCode});

  @override
  String toString() =>
      'NetworkError: $type${message != null ? ' - $message' : ''}';
}

/// HTTP client for sending events to the Respectlytics API.
class NetworkClient {
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 30);

  final Configuration configuration;
  final http.Client _client;

  NetworkClient({required this.configuration, http.Client? client})
    : _client = client ?? http.Client();

  /// Send one event to the API.
  ///
  /// Retries on network errors, 429 and 5xx responses with exponential
  /// backoff, and throws [NetworkError] when sending is worth trying again
  /// later.
  ///
  /// A 400 is final, since no retry can change it. An event with properties
  /// is then sent once more without them, for a server older than v3.1.0 (a
  /// self-hosted Community Edition not yet updated) that refuses the
  /// properties field. If the server refuses the event itself, it is dropped,
  /// so it never holds up the events queued after it.
  Future<void> sendEvent(Event event) async {
    try {
      await _sendEventWithRetry(event, attempt: 0);
      return;
    } on NetworkError catch (e) {
      if (e.type != NetworkErrorType.badRequest) rethrow;
    }

    if (event.properties.isNotEmpty) {
      try {
        await _sendEventWithRetry(
          Event(
            eventName: event.eventName,
            timestamp: event.timestamp,
            sessionId: event.sessionId,
            platform: event.platform,
          ),
          attempt: 0,
        );
        print(
          '[Respectlytics] ⚠️ Server refused the properties, '
          'event sent without them',
        );
        return;
      } on NetworkError catch (e) {
        if (e.type != NetworkErrorType.badRequest) rethrow;
      }
    }

    print('[Respectlytics] ⚠️ Server refused an event (400), dropped');
  }

  Future<void> _sendEventWithRetry(Event event, {required int attempt}) async {
    try {
      final response = await _client
          .post(
            Uri.parse(configuration.eventsEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'X-App-Key': configuration.apiKey,
            },
            body: jsonEncode(event.toJson()),
          )
          .timeout(_timeout);

      _handleResponse(response);
    } on TimeoutException {
      await _retryOrThrow(
        event,
        attempt,
        NetworkError(
          NetworkErrorType.networkError,
          message: 'Request timed out',
        ),
      );
    } on http.ClientException catch (e) {
      await _retryOrThrow(
        event,
        attempt,
        NetworkError(NetworkErrorType.networkError, message: e.message),
      );
    } on NetworkError catch (e) {
      // Check if this error type should be retried
      if (e.type == NetworkErrorType.serverError ||
          e.type == NetworkErrorType.rateLimited) {
        await _retryOrThrow(event, attempt, e);
      } else {
        rethrow;
      }
    }
  }

  Future<void> _retryOrThrow(
    Event event,
    int attempt,
    NetworkError error,
  ) async {
    if (attempt < _maxRetries) {
      // Exponential backoff: 2^attempt seconds
      final delay = Duration(seconds: 1 << attempt); // 2, 4, 8 seconds
      await Future.delayed(delay);
      await _sendEventWithRetry(event, attempt: attempt + 1);
    } else {
      throw error;
    }
  }

  void _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return; // Success
    }

    switch (response.statusCode) {
      case 400:
        throw NetworkError(
          NetworkErrorType.badRequest,
          statusCode: 400,
          message: response.body,
        );
      case 401:
        throw NetworkError(NetworkErrorType.unauthorized, statusCode: 401);
      case 429:
        throw NetworkError(NetworkErrorType.rateLimited, statusCode: 429);
      default:
        if (response.statusCode >= 500) {
          throw NetworkError(
            NetworkErrorType.serverError,
            statusCode: response.statusCode,
          );
        }
        throw NetworkError(
          NetworkErrorType.invalidResponse,
          statusCode: response.statusCode,
        );
    }
  }

  void dispose() {
    _client.close();
  }
}
