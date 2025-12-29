import 'package:flutter/material.dart';
import 'package:google_location/customs/custom_button.dart';
import 'package:google_location/customs/custom_input.dart';
import 'package:google_location/models/custom_marker_model.dart';

class CreateMarkerpage extends StatefulWidget {
  const CreateMarkerpage({super.key});

  @override
  State<CreateMarkerpage> createState() => _CreateMarkerpageState();
}

class _CreateMarkerpageState extends State<CreateMarkerpage> {
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();

  void submit() {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    final lat = double.tryParse(latController.text);
    final lng = double.tryParse(lngController.text);

    if (name.isEmpty || desc.isEmpty || lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields correctly")),
      );
      return;
    }

    final marker = CustomMarkerModel(
      Lat: lat,
      Lng: lng, 
      name: name,
       description: desc,
    );

    Navigator.pop(context, marker); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Create Location Marker",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(),

            CustomInput(controller: nameController, hintText: "Name"),
            const SizedBox(height: 15),
            CustomInput(controller: descController, hintText: "Description"),
            const SizedBox(height: 15),
            CustomInput(
              controller: latController,
              hintText: "Latitude",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),
            CustomInput(
              controller: lngController,
              hintText: "Longitude",
              keyboardType: TextInputType.number,
            ),

            const Spacer(),
            CustomButton(title: "Submit", onPressed: submit),
          ],
        ),
      ),
    );
  }
}
