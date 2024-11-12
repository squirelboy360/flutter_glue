class NativeBarButton {
  final String id;
  final String? systemName;
  final String? title;

  const NativeBarButton({
    required this.id,
    this.systemName,
    this.title,
  }) : assert(
         systemName != null || title != null,
         'Either systemName or title must be provided'
       );

  Map<String, dynamic> toMap() => {
    'id': id,
    if (systemName != null) 'systemName': systemName,
    if (title != null) 'title': title,
  };
}
