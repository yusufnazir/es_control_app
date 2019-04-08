import 'dart:convert';

Survey clientFromJson(String str) {
  final jsonData = json.decode(str);
  return Survey.fromJsonMap(jsonData);
}

String clientToJson(Survey data) {
  final dyn = data.toDbMap();
  return json.encode(dyn);
}

class Survey {
  int id;
  String name;
  String description;
  bool active;

  Survey({
    this.id,
    this.name,
    this.description,
    this.active,
  });

  factory Survey.fromJsonMap(Map<String, dynamic> json) => new Survey(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        active: json["active"] == true,
      );

  factory Survey.fromDbMap(Map<String, dynamic> json) => new Survey(
    id: json["id"],
    name: json["name"],
    description: json["description"],
    active: json["active"] == 1,
  );

  Map<String, dynamic> toDbMap() => {
        "id": id,
        "name": name,
        "description": description,
        "active": active,
      };

  @override
  String toString() {
    return 'Survey{id: $id, name: $name, description: $description, active: $active}';
  }
}
