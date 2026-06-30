class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});

  Map<String, dynamic> toJson() {
    return {"title": title, "isDone": isDone};
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(title: json["title"], isDone: json["isDone"]);
  }
}
