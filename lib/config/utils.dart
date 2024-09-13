// // date_picker.dart
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// Future<void> selectDate(BuildContext context) async {
//   final DateTime? picked = await showDatePicker(
//     context: context,
//     initialDate: DateTime.now(),
//     firstDate: DateTime(2020),
//     lastDate: DateTime(2101),
//   );
//   if (picked != null && picked != selectedDate)
//     setState(() {
//       selectedDate = picked;
//       tanggalController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
//     });
// }
