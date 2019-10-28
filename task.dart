class Task {
  int id;
  String title;
  String description;
  int priorit;
  bool isDone;

  Task({
    this.id,
    this.title,
    this.description,
    this.priorit,
    this.isDone = false,
  });

  factory Task.fromMap(Map<String, dynamic> json) => Task(
        id: json["id"],
        title: json["title"],
        description: json["description"],
        priorit: json["priorit"],
        isDone: json["isDone"] == 1,
      );

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "id": id,
      "title": title,
      "description": description,
      "priorit": priorit,
      "isDone": isDone ? 1 : 0
    };

    if (id != null) map["id"] = id;

    return map;
  }
}
