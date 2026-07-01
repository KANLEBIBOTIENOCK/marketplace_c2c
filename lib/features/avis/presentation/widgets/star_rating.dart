import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final int initialNote;
  final void Function(int) onChanged;
  final double size;

  const StarRating({
    super.key,
    this.initialNote = 0,
    required this.onChanged,
    this.size = 36,
  });

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int _note;

  @override
  void initState() {
    super.initState();
    _note = widget.initialNote;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final index = i + 1;
        return GestureDetector(
          onTap: () {
            setState(() => _note = index);
            widget.onChanged(index);
          },
          child: Icon(
            index <= _note ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: widget.size,
          ),
        );
      }),
    );
  }
}

// Widget d'affichage statique des étoiles
class StarDisplay extends StatelessWidget {
  final double note;
  final double size;

  const StarDisplay({super.key, required this.note, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final index = i + 1;
        return Icon(
          index <= note
              ? Icons.star
              : (index - 0.5 <= note ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }
}
