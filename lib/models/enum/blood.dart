enum BloodGroup {
  aPlus('A', '+'),
  aMinus('A', '-'),
  bPlus('B', '+'),
  bMinus('B', '-'),
  abPlus('AB', '+'),
  abMinus('AB', '-'),
  oPlus('O', '+'),
  oMinus('O', '-');

  // Fields must be final in an enhanced enum
  final String type;
  final String rh;

  // The constructor must be constant
  const BloodGroup(this.type, this.rh);

  // add helper methods
  @override
  String toString() => '$type$rh';
}