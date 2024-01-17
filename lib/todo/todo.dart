class Todo {
  String id;
  String title;
  bool isDone;
  String description;
  String? imagePath;

  Todo(this.id, this.title, this.isDone, this.description, {this.imagePath});

  Map<String, dynamic> toMap(){
    return{
      'id': id,
      'title': title,
      'isDone': isDone,
      'description': description,
      'imagePath': imagePath,
    };
  }
}