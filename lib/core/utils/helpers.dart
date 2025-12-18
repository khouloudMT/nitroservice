import 'package:intl/intl.dart';

class Helpers {
  // Formater date
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Formater heure
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  // Formater prix
  static String formatPrice(double price) {
    return '${price.toStringAsFixed(0)} DT';
  }

  // Calculer durée
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    int hours = minutes ~/ 60;
    int mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}min' : '${hours}h';
  }
}