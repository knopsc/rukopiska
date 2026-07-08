class PenPreset {
  PenPreset({required this.size, required this.streamline, required this.color});

  double size;
  double streamline;
  int color;

  factory PenPreset.fromJson(Map<String, dynamic> json) => PenPreset(
        size: (json['size'] as num).toDouble(),
        streamline: (json['streamline'] as num).toDouble(),
        color: json['color'] as int,
      );

  Map<String, dynamic> toJson() => {
        'size': size,
        'streamline': streamline,
        'color': color,
      };
}