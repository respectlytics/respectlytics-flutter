// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. Licensed under the MIT License.

/// Why a property was dropped on the device instead of being sent.
enum PropertyDropReason {
  /// The name is not lowercase letters, digits and underscores, starting with
  /// a letter, at most 40 characters.
  invalidName('invalid name'),

  /// The text value is not 1 to 40 letters, digits, spaces, `_`, `.` or `-`
  /// starting with a letter or digit.
  invalidValue('invalid value'),

  /// The number is NaN or infinite.
  notFinite('number not finite'),

  /// The value is not a String, a number or a bool.
  unsupportedType('unsupported type'),

  /// The event already carries the maximum number of properties.
  overLimit('more than ${PropertyFilter.maxProperties}');

  const PropertyDropReason(this.description);

  /// A short explanation for the debug log. It never contains a value.
  final String description;
}

/// The result of filtering an event's properties.
class FilteredProperties {
  /// What passed, in the order it was given. Sent with the event when not
  /// empty.
  final Map<String, Object> kept;

  /// The names that were dropped, each with its reason.
  final Map<String, PropertyDropReason> dropped;

  const FilteredProperties({required this.kept, required this.dropped});

  static const FilteredProperties none = FilteredProperties(
    kept: {},
    dropped: {},
  );
}

/// Filters event properties on the device with the server's own shape rules.
///
/// The server keeps a property only when the app's owner declared it in the
/// app's Settings on respectlytics.com, with one of the declared list values
/// or, for a number property, any finite number (kept only as its band). The
/// SDK does not know what an app declared, so it applies the shape rules the
/// server applies to every property: a name that could never be declared, a
/// text value that could never be a declared value (an email address, a URL,
/// anything over 40 characters), a number that is not finite and any other
/// type are dropped here and never leave the device. A short value that fits
/// the shape (such as "John Smith") is sent, and the server drops it unless it
/// was declared. At most [maxProperties] are kept, counting only those that
/// pass.
///
/// Filtering never throws: a bad property is dropped and the event is still
/// sent with what passed.
class PropertyFilter {
  PropertyFilter._();

  /// The most properties one event carries; the server reads no more.
  static const int maxProperties = 20;

  /// A property name the server can keep.
  static final RegExp namePattern = RegExp(r'^[a-z][a-z0-9_]{0,39}$');

  /// A text value the server can keep (it is then compared exactly with the
  /// declared list values, case-sensitive).
  static final RegExp valuePattern = RegExp(
    r'^[A-Za-z0-9][A-Za-z0-9 _.\-]{0,39}$',
  );

  /// Filter [properties] to what the server can keep.
  static FilteredProperties filter(Map<String, Object?>? properties) {
    if (properties == null || properties.isEmpty) {
      return FilteredProperties.none;
    }

    final kept = <String, Object>{};
    final dropped = <String, PropertyDropReason>{};

    for (final entry in properties.entries) {
      final name = entry.key;
      final value = entry.value;
      final reason = _reasonToDrop(name, value);
      if (reason != null) {
        dropped[name] = reason;
      } else if (kept.length >= maxProperties) {
        dropped[name] = PropertyDropReason.overLimit;
      } else {
        kept[name] = value!;
      }
    }

    return FilteredProperties(
      kept: Map.unmodifiable(kept),
      dropped: Map.unmodifiable(dropped),
    );
  }

  static PropertyDropReason? _reasonToDrop(String name, Object? value) {
    if (!namePattern.hasMatch(name)) {
      return PropertyDropReason.invalidName;
    }
    if (value is String) {
      return valuePattern.hasMatch(value)
          ? null
          : PropertyDropReason.invalidValue;
    }
    if (value is num) {
      return value.isFinite ? null : PropertyDropReason.notFinite;
    }
    if (value is bool) {
      return null;
    }
    return PropertyDropReason.unsupportedType;
  }

  /// One line for the debug log naming every dropped property and why, or
  /// null when nothing was dropped. Values are never part of it.
  static String? describeDropped(String eventName, FilteredProperties result) {
    if (result.dropped.isEmpty) {
      return null;
    }
    final names = result.dropped.entries
        .map((e) => '${_shortName(e.key)} (${e.value.description})')
        .join('; ');
    return '[Respectlytics] ⚠️ "$eventName": dropped properties: $names';
  }

  /// A name as it appears in the log, cut to 40 characters like the server
  /// cuts the names it reports back.
  static String _shortName(String name) {
    if (name.isEmpty) return '(empty name)';
    return name.length > 40 ? '${name.substring(0, 40)}...' : name;
  }
}
