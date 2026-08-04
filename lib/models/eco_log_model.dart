class EcoLogModel {
  final String date;
  final String transport;
  final bool lightsOff;
  final bool reducedAc;
  final String waste;
  final int score;

  EcoLogModel({
    required this.date,
    required this.transport,
    required this.lightsOff,
    required this.reducedAc,
    required this.waste,
    required this.score,
  });

  static int calculateScore({
    required String transport,
    required bool lightsOff,
    required bool reducedAc,
    required String waste,
  }) {
    int total = 0;

    if (transport == 'walk') total += 35;
    if (transport == 'bus') total += 20;
    if (transport == 'car') total += 5;

    if (lightsOff) total += 20;
    if (reducedAc) total += 15;

    if (waste == 'recycled') total += 30;
    if (waste == 'composted') total += 20;
    if (waste == 'single_use') total += 5;

    return total > 100 ? 100 : total;
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'transport': transport,
        'lightsOff': lightsOff,
        'reducedAc': reducedAc,
        'waste': waste,
        'score': score,
      };

  factory EcoLogModel.fromJson(Map<String, dynamic> json) => EcoLogModel(
        date: json['date'],
        transport: json['transport'],
        lightsOff: json['lightsOff'],
        reducedAc: json['reducedAc'],
        waste: json['waste'],
        score: json['score'],
      );
}