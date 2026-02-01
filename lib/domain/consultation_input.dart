class ConsultationInput {
  const ConsultationInput({
    required this.symptoms,
    required this.intensity,
  });

  final List<String> symptoms;
  final String intensity;
}
