import 'package:intl/intl.dart';

//this basically is to convert date/day/time from calendar to string
class DateConverted {
  static String getDate(DateTime date) {
    return DateFormat.yMd().format(date);
  }

  static String getDay(int day) {
    switch (day) {
      case 1:
        return 'Lundi';
      case 2:
        return 'Mardi';
      case 3:
        return 'Mercredi';
      case 4:
        return 'Jeudi';
      case 5:
        return 'Vendredi';
      case 6:
        return 'Samedi';
      case 7:
        return 'Dimanche';
      default:
        return 'Dimanche';
    }
  }

  static String getTime(int time) {
    switch (time) {
      case 0:
        return '8:00 AM';
      case 1:
        return '9:00 AM';
      case 2:
        return '10:00 AM';
      case 3:
        return '11:00 AM';
      case 4:
        return '12:00 PM';
      case 5:
        return '13:00 PM';
      case 6:
        return '14:00 PM';
      case 7:
        return '15:00 PM';
      case 8:
        return '16:00 PM';
      case 9:
        return '17:00 PM';
      case 10:
        return '18:00 PM';
      case 11:
        return '19:00 PM';
      case 12:
        return '20:00 PM';
      case 13:
        return '21:00 PM';
      case 14:
        return '22:00 PM';
      case 15:
        return '23:00 PM';
      case 16:
        return '24:00 PM';
      default:
        return '8:00 AM';
    }
  }
}
