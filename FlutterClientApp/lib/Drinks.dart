import 'dart:collection';

class Drink {
  final String name;
  final Map<String, dynamic> ingredients;

  Drink({this.name, this.ingredients});
  factory Drink.fromJson(Map<String, dynamic> data) =>
      Drink(name: data['name'], ingredients: data['ingredients']);
}
