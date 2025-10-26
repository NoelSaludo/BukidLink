import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/FormValidator.dart';

class LastNameField extends StatelessWidget{
  final TextEditingController controller;
  const LastNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
return Column (
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: Text(
      "Last Name",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      ),
      ),
      ),
    SizedBox(
      width: 150.0,
      height: 65.0,
      child: Padding(
        padding: EdgeInsets.symmetric( horizontal: 4.0),
        child: TextFormField(
      decoration: InputDecoration(
        // labelText: 'LastName',
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: BorderSide(
            color: Colors.blue,
            width: 2.0,
          ),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      ),
      style: TextStyle(
        fontSize: 14.0,
      ),
      controller: controller,
      validator: FormValidator().nameValidator,
      ),
      ),
    ),
      ],
    );
    }
}