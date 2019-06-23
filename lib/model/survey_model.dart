import 'dart:convert';

class Survey {
  static final String tableSurveys = "Surveys";
  static final String columnId = "id";
  static final String columnName = "name";
  static final String columnDescription = "description";
  static final String columnActive = "active";

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

  Survey clientFromJson(String str) {
    final jsonData = json.decode(str);
    return Survey.fromJsonMap(jsonData);
  }

  String clientToJson(Survey data) {
    final dyn = data.toDbMap();
    return json.encode(dyn);
  }

  factory Survey.fromJsonMap(Map<String, dynamic> json) {
    if (json != null) {
      return Survey(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        active: json["active"] == true,
      );
    }
    return null;
  }

  factory Survey.fromDbMap(Map<String, dynamic> json) {
    if (json != null) {
      return Survey(
        id: json[columnId],
        name: json[columnName],
        description: json[columnDescription],
        active: json[columnActive] == 1,
      );
    }
    return null;
  }

  Map<String, dynamic> toDbMap() => {
        columnId: id,
        columnName: name,
        columnDescription: description,
        columnActive: active,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Survey &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              name == other.name &&
              description == other.description &&
              active == other.active;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      active.hashCode;

  @override
  String toString() {
    return 'Survey{id: $id, name: $name, description: $description, active: $active}';
  }


}
