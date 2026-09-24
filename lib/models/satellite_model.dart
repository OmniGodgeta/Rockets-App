class Satellite {
  final String name;
  final String noradId;
  final String tleLine1;
  final String tleLine2;

  Satellite({
    required this.name,
    required this.noradId,
    required this.tleLine1,
    required this.tleLine2,
  });

  factory Satellite.fromTle(String name, String noradId, String line1, String line2) {
    return Satellite(
      name: name,
      noradId: noradId,
      tleLine1: line1,
      tleLine2: line2,
    );
  }
}
