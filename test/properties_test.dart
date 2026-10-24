// Respectlytics SDK for Flutter
// Copyright (c) 2025 Respectlytics. Licensed under the MIT License.

import 'package:flutter_test/flutter_test.dart';
import 'package:respectlytics_flutter/src/properties.dart';

void main() {
  group('PropertyFilter', () {
    test('null or empty properties give nothing to send', () {
      for (final raw in <Map<String, Object?>?>[null, {}]) {
        final result = PropertyFilter.filter(raw);
        expect(result.kept, isEmpty);
        expect(result.dropped, isEmpty);
      }
    });

    test('keeps a list value, an int, a double and a bool, in order', () {
      final result = PropertyFilter.filter({
        'paywall': 'b',
        'items': 3,
        'price': 7.5,
        'trial': true,
        'annual': false,
      });

      expect(result.kept, {
        'paywall': 'b',
        'items': 3,
        'price': 7.5,
        'trial': true,
        'annual': false,
      });
      expect(result.kept.keys.toList(), [
        'paywall',
        'items',
        'price',
        'trial',
        'annual',
      ]);
      expect(result.dropped, isEmpty);
    });

    group('name rule', () {
      test('keeps lowercase letters, digits and _ starting with a letter', () {
        final result = PropertyFilter.filter({
          'a': 'x',
          'plan_2': 'x',
          'a${'b' * 39}': 'x', // 40 characters
        });
        expect(result.kept.length, 3);
        expect(result.dropped, isEmpty);
      });

      for (final name in [
        '',
        'Paywall',
        'PAYWALL',
        '2nd_plan',
        '_plan',
        'plan-name',
        'plan name',
        'plan.name',
        'plän',
        'plan\n',
        'a${'b' * 40}', // 41 characters
      ]) {
        test('drops the name ${name.replaceAll('\n', r'\n')}', () {
          final result = PropertyFilter.filter({name: 'b', 'ok': 'b'});
          expect(result.kept, {'ok': 'b'});
          expect(result.dropped, {name: PropertyDropReason.invalidName});
        });
      }
    });

    group('text value rule', () {
      test('keeps letters, digits, space, _ . - starting with one of A-Za-z0-9',
          () {
        final values = [
          'b',
          'B',
          '7',
          'Plan B',
          'v1.2-beta_3',
          'x${'y' * 39}', // 40 characters
        ];
        final result = PropertyFilter.filter({
          for (var i = 0; i < values.length; i++) 'p$i': values[i],
        });
        expect(result.kept.values.toList(), values);
        expect(result.dropped, isEmpty);
      });

      for (final value in [
        '',
        ' b',
        '.b',
        '-b',
        '_b',
        'jane@example.com',
        'https://example.com',
        'Hello, world',
        'b\n',
        'line\nbreak',
        'blå',
        'x${'y' * 40}', // 41 characters
      ]) {
        test('drops the value ${value.replaceAll('\n', r'\n')}', () {
          final result = PropertyFilter.filter({'variant': value});
          expect(result.kept, isEmpty);
          expect(result.dropped, {'variant': PropertyDropReason.invalidValue});
        });
      }
    });

    group('numbers', () {
      test('keeps any finite number', () {
        final result = PropertyFilter.filter({
          'zero': 0,
          'negative': -12,
          'big': 1e300,
          'small': -0.0001,
        });
        expect(result.kept.length, 4);
        expect(result.dropped, isEmpty);
      });

      test('drops NaN and both infinities', () {
        final result = PropertyFilter.filter({
          'nan': double.nan,
          'inf': double.infinity,
          'neg_inf': double.negativeInfinity,
          'ok': 1,
        });
        expect(result.kept, {'ok': 1});
        expect(result.dropped, {
          'nan': PropertyDropReason.notFinite,
          'inf': PropertyDropReason.notFinite,
          'neg_inf': PropertyDropReason.notFinite,
        });
      });
    });

    test('drops every other type', () {
      final result = PropertyFilter.filter({
        'null_value': null,
        'list': ['b'],
        'map': {'a': 'b'},
        'date': DateTime(2026, 10, 24),
        'object': Object(),
        'ok': 'b',
      });
      expect(result.kept, {'ok': 'b'});
      expect(result.dropped.keys.toList(), [
        'null_value',
        'list',
        'map',
        'date',
        'object',
      ]);
      expect(
        result.dropped.values.toSet(),
        {PropertyDropReason.unsupportedType},
      );
    });

    test('keeps a bool as a JSON bool', () {
      final result = PropertyFilter.filter({'trial': true});
      expect(result.kept['trial'], isA<bool>());
      expect(result.kept['trial'], isTrue);
    });

    group('the 20 limit', () {
      test('keeps the first 20 and drops the rest', () {
        final raw = {for (var i = 1; i <= 25; i++) 'p$i': 'v$i'};
        final result = PropertyFilter.filter(raw);

        expect(PropertyFilter.maxProperties, 20);
        expect(result.kept.length, 20);
        expect(
          result.kept.keys.toList(),
          [for (var i = 1; i <= 20; i++) 'p$i'],
        );
        expect(result.dropped, {
          for (var i = 21; i <= 25; i++) 'p$i': PropertyDropReason.overLimit,
        });
      });

      test('dropped properties do not count toward the limit', () {
        final raw = <String, Object?>{
          'Bad': 'b',
          'free_text': 'jane@example.com',
          'nan': double.nan,
          for (var i = 1; i <= 20; i++) 'p$i': i,
        };
        final result = PropertyFilter.filter(raw);

        expect(result.kept.length, 20);
        expect(result.dropped.length, 3);
        expect(result.dropped.values,
            isNot(contains(PropertyDropReason.overLimit)));
      });

      test('a bad property after the limit gives its own reason', () {
        final raw = <String, Object?>{
          for (var i = 1; i <= 20; i++) 'p$i': i,
          'late': 'jane@example.com',
        };
        final result = PropertyFilter.filter(raw);
        expect(result.dropped, {'late': PropertyDropReason.invalidValue});
      });
    });

    test('the kept map cannot be changed afterwards', () {
      final result = PropertyFilter.filter({'paywall': 'b'});
      expect(() => result.kept['x'] = 'y', throwsUnsupportedError);
    });

    test('the caller changing its map later changes nothing kept', () {
      final raw = <String, Object?>{'paywall': 'b'};
      final result = PropertyFilter.filter(raw);
      raw['paywall'] = 'c';
      raw['extra'] = 'd';
      expect(result.kept, {'paywall': 'b'});
    });
  });

  group('PropertyFilter.describeDropped', () {
    test('says nothing when nothing was dropped', () {
      final result = PropertyFilter.filter({'paywall': 'b'});
      expect(PropertyFilter.describeDropped('paywall_viewed', result), isNull);
    });

    test('names each dropped property and why, never its value', () {
      final result = PropertyFilter.filter({
        'Email': 'jane',
        'note': 'jane@example.com',
        'ratio': double.infinity,
        'when': DateTime(2026),
        'paywall': 'b',
      });
      final line = PropertyFilter.describeDropped('paywall_viewed', result)!;

      expect(line, startsWith('[Respectlytics]'));
      expect(line, contains('paywall_viewed'));
      expect(line,
          contains('Email (${PropertyDropReason.invalidName.description})'));
      expect(line,
          contains('note (${PropertyDropReason.invalidValue.description})'));
      expect(line,
          contains('ratio (${PropertyDropReason.notFinite.description})'));
      expect(line,
          contains('when (${PropertyDropReason.unsupportedType.description})'));
      expect(line, isNot(contains('jane')));
      expect(line, isNot(contains('Infinity')));
      expect(line, isNot(contains('2026')));
      expect(line, isNot(contains('paywall (')));
    });

    test('says when properties were over the limit', () {
      final result = PropertyFilter.filter({
        for (var i = 1; i <= 21; i++) 'p$i': i,
      });
      final line = PropertyFilter.describeDropped('e', result)!;
      expect(line, contains('p21 (more than 20)'));
    });

    test('cuts a long name to 40 characters', () {
      final name = 'X' * 500;
      final result = PropertyFilter.filter({name: 'b'});
      final line = PropertyFilter.describeDropped('e', result)!;
      expect(line, contains('${'X' * 40}...'));
      expect(line, isNot(contains('X' * 41)));
    });
  });
}
