import 'package:flutter/material.dart';
import 'package:bukidlink/Utils/FormValidator.dart';

class FirstNameField extends StatelessWidget{
  final TextEditingController controller;
  const FirstNameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children:[
    Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: Text(
      "First Name",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16.0,
      ),
      ),
      ),
    SizedBox(
      width: 155.0,
      height: 65.0,
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 4.0),
        child: TextFormField(
      decoration: InputDecoration(
        // labelText: 'FirstName',
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