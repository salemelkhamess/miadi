class Contact {
  final String phone1;
  final String phone2;
  final String fb;
  final String wh;
  final String email;
  final String sn;
  final String ins;

  Contact({
    required this.phone1,
    required this.phone2,
    required this.fb,
    required this.wh,
    required this.email,
    required this.sn,
    required this.ins,
  });

// Factory method to create a Contact instance from a JSON map
  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      phone1: json['phone1'],
      phone2: json['phone2'],
      fb: json['fb'],
      wh: json['wh'],
      email: json['email'],
      sn: json['sn'],
      ins: json['ins'],


    );
  }

}