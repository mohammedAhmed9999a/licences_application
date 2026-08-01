class AttachmentRequirement {
  final String key;
  final String title;
  final String docType;
  final bool isRequired;

  const AttachmentRequirement({
    required this.key,
    required this.title,
    required this.docType,
    this.isRequired = true,
  });
}
