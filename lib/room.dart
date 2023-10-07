class Room {
  String? name;
  List<Persons>? persons;

  Room({required this.name, required this.persons});

  Room.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['persons'] != null) {
      persons = <Persons>[];
      json['persons'].forEach((v) {
        persons!.add(Persons.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (persons != null) {
      data['persons'] = persons!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Persons {
  int? type;
  String? name;
  int? age;

  Persons({required this.type, this.name, this.age});

  Persons.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    name = json['name'];
    age = json['age'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['name'] = name;
    data['age'] = age;
    return data;
  }
}
