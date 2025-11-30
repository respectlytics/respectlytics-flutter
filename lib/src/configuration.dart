// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. All rights reserved.
// See LICENSE file for terms.

/// SDK configuration holding API key and endpoint.
class Configuration {
  final String apiKey;
  final String baseUrl;

  Configuration({
    required this.apiKey,
    this.baseUrl = 'https://respectlytics.com/api/v1',
  });

  /// API endpoint for sending events.
  String get eventsEndpoint => '$baseUrl/events/';
}
