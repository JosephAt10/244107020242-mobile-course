class Comment {
  const Comment({
    required this.postId,
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  final int postId;
  final int id;
  final String name;
  final String email;
  final String body;

  factory Comment.fromJson(Map<String, dynamic> json) {
    final postIdValue = json['postId'];
    final idValue = json['id'];
    final nameValue = json['name'];
    final emailValue = json['email'];
    final bodyValue = json['body'];

    return Comment(
      postId: postIdValue is num ? postIdValue.toInt() : 0,
      id: idValue is num ? idValue.toInt() : 0,
      name: nameValue is String ? nameValue : '',
      email: emailValue is String ? emailValue : '',
      body: bodyValue is String ? bodyValue : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'id': id,
      'name': name,
      'email': email,
      'body': body,
    };
  }
}
