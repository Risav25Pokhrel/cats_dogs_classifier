import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';

class Core extends StatefulWidget {
  const Core({super.key});

  @override
  State<Core> createState() => _CoreState();
}

class _CoreState extends State<Core> {
  bool _loading = true;
  File? _image;
  List _output = [];
  final picker = ImagePicker();

  detectImage(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 3,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5);
    setState(() {
      _output = output!;
      _loading = false;
    });
  }

  loadmodel() async {
    await Tflite.loadModel(
        model: "assets/model_unquant.tflite", labels: "assets/labels.txt");
  }

  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  pickerImageCamera() async {
    var image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });

    detectImage(_image!);
  }

  pickerImageGallery() async {
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    setState(() {
      _image = File(image.path);
    });

    detectImage(_image!);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 50),
            const Text("CATS AND DOGS",
                style: TextStyle(color: Colors.blueGrey, fontSize: 30)),
            const SizedBox(height: 5),
            const SizedBox(height: 50),
            Center(
                child: _loading
                    ? SizedBox(
                        width: 400,
                        child: Column(
                          children: [
                            Image.asset("assets/cats_dog.png"),
                            const SizedBox(height: 50)
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          SizedBox(
                            height: 200,
                            child: Image.file(_image!),
                          ),
                          const SizedBox(height: 20),
                          _output.isNotEmpty
                              ? Text(
                                  _output[0]["label"],
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 25),
                                )
                              : const SizedBox()
                        ],
                      )),
            const SizedBox(height: 5),
            ElevatedButton(
                onPressed: () => pickerImageCamera(),
                child: const Text("Capture A Photo")),
            const SizedBox(height: 5),
            ElevatedButton(
                onPressed: () => pickerImageGallery(),
                child: const Text("Select A Photo"))
          ],
        ),
      ),
    );
  }
}
