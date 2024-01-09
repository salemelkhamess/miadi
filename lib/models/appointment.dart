import './doctor.dart';
import './clinique.dart';

class Appointment {
  final int id;
  final int doctorId;
  final String day;
  final String date;
  final String status;
  final Doctor doctor;
  final Clinique clinique;
  final int app_number;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.day,
    required this.date,
    required this.status,
    required this.doctor,
    required this.clinique,
    required this.app_number
  });
}