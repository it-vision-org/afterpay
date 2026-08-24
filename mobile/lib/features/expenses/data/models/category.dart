import 'package:flutter/material.dart';

enum Category {
  housing,
  food,
  transportation,
  shopping,
  entertainment,
  health,
  bills,
  subscriptions,
  education,
  family,
  travel,
  other;

  String get apiValue => switch (this) {
    Category.housing => 'HOUSING',
    Category.food => 'FOOD',
    Category.transportation => 'TRANSPORTATION',
    Category.shopping => 'SHOPPING',
    Category.entertainment => 'ENTERTAINMENT',
    Category.health => 'HEALTH',
    Category.bills => 'BILLS',
    Category.subscriptions => 'SUBSCRIPTIONS',
    Category.education => 'EDUCATION',
    Category.family => 'FAMILY',
    Category.travel => 'TRAVEL',
    Category.other => 'OTHER',
  };

  String get label => switch (this) {
    Category.housing => 'Housing',
    Category.food => 'Food',
    Category.transportation => 'Transportation',
    Category.shopping => 'Shopping',
    Category.entertainment => 'Entertainment',
    Category.health => 'Health',
    Category.bills => 'Bills',
    Category.subscriptions => 'Subscriptions',
    Category.education => 'Education',
    Category.family => 'Family',
    Category.travel => 'Travel',
    Category.other => 'Other',
  };

  IconData get icon => switch (this) {
    Category.housing => Icons.home_outlined,
    Category.food => Icons.restaurant_outlined,
    Category.transportation => Icons.directions_car_outlined,
    Category.shopping => Icons.shopping_bag_outlined,
    Category.entertainment => Icons.movie_outlined,
    Category.health => Icons.favorite_outline,
    Category.bills => Icons.receipt_outlined,
    Category.subscriptions => Icons.autorenew,
    Category.education => Icons.school_outlined,
    Category.family => Icons.family_restroom_outlined,
    Category.travel => Icons.flight_takeoff_outlined,
    Category.other => Icons.category_outlined,
  };

  static Category fromApiValue(String value) {
    return switch (value) {
      'HOUSING' => Category.housing,
      'FOOD' => Category.food,
      'TRANSPORTATION' => Category.transportation,
      'SHOPPING' => Category.shopping,
      'ENTERTAINMENT' => Category.entertainment,
      'HEALTH' => Category.health,
      'BILLS' => Category.bills,
      'SUBSCRIPTIONS' => Category.subscriptions,
      'EDUCATION' => Category.education,
      'FAMILY' => Category.family,
      'TRAVEL' => Category.travel,
      'OTHER' => Category.other,
      _ => throw ArgumentError('Unknown category: $value'),
    };
  }
}
