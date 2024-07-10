import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depstar_docs/splash_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';


// ignore: must_be_immutable
class UploadDocumentScreen extends StatefulWidget {

  List<String> navigationStack = [];


  UploadDocumentScreen({super.key, required this.navigationStack});
  @override
  _UploadDocumentState createState() => _UploadDocumentState();
}

class _UploadDocumentState extends State<UploadDocumentScreen> {
  final TextEditingController _fileNameController = TextEditingController();
  String? _fileName;
  String? _filePath;
  bool uploading = false;
  final storage = FirebaseStorage.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload document', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Colors.blue[500],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _handleFileUpload, child: uploading ? const Center(child: SizedBox(width: 20.0, height: 20.0,child: CircularProgressIndicator(strokeWidth: 2,))) :  const Icon(Icons.check),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fileNameController,
                    // readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.post_add_rounded),
                  onPressed: _pickFile,
                ),
              ],
            ),
            if (_fileName != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
                  onPressed: _openFile,
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center,children: [Icon(Icons.open_in_new_rounded, size: 15.0,), SizedBox(width: 8.0,),Text('Preview File')]),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Selected file: ${_fileName!}',
                style: const TextStyle(
                  fontSize: 16,
                  // fontWeight: FontWeight.bold,
                  // color: Colors.blue,
                ),
              ),
              
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom,allowedExtensions: ['pdf']);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path;
        _fileName = result.files.single.name;
        _fileNameController.text = _fileName!;
      });
    }
  }

  Future<void> _openFile() async {
    if (_filePath != null) {
      OpenFile.open(_filePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file selected'),
        ),
      );
    }
  }

  Future<void> _handleFileUpload() async {

    setState(() {
      uploading = true;
    });

    final storageRef = FirebaseStorage.instance.ref();

    final destRef = storageRef.child('${widget.navigationStack.join('/')}/${_fileName?? 'Document.pdf'}');

    // final String fullPath = await supabase.storage.from('Documents').upload(
    //   widget.navigationStack.join('/') + '/' + (_fileName?? 'Document.pdf'),
    //   File(_filePath!),
    //   fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    // )
    destRef.putFile(File(_filePath!))

    // ignore: body_might_complete_normally_catch_error
    .catchError((err) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error while uploading, try again later!!')),
      );
      setState(() {
        uploading = false;
      });
      
    });

    // Upadte the entry

    dynamic data;
    await db.collection("Comeetee").doc(widget.navigationStack[0]).get().then((event) {
        // event.printError();
        // print(event.);
        data = event.data()?["child"];
        data = jsonDecode(data);
        // print("AYYY");
        // print(data);
        // for (var doc in event.docs) {
        //   print("${doc.id} => ${doc.data()}");
        //   globalMap[doc.id] = jsonDecode(doc.data()["child"]);
        // }
      });
    // data = data[0];
    // data = data['child'];
    if(data is List){
      data.add({"name": _fileName, "url": '${widget.navigationStack.join('/')}/${_fileName?? 'Document.pdf'}'});
    } else {
      

      List<String> tmpNavStk = widget.navigationStack.map((e) => e).toList();
      tmpNavStk.removeAt(0);
      // insertValue(data, tmpNavStk, );
      dynamic current = data;
      // Traverse through the keys to reach the target list
      for (int i = 0; i < tmpNavStk.length - 1; i++) {
        current = current[tmpNavStk[i]];
        if (current is! Map) {
          throw Exception("Key path is invalid: ${tmpNavStk.sublist(0, i + 1).join(' -> ')}");
        }
      }
      dynamic targetList = current[tmpNavStk.last];
      if (targetList is List) {
        targetList.add({"name": _fileName, "url": '${widget.navigationStack.join('/')}/${_fileName?? 'Document.pdf'}'});
      } else {
        throw Exception("Target is not a list: ${tmpNavStk.join(' -> ')}");
      }
    }
    await db.collection("Comeetee").doc(widget.navigationStack[0]).update({"child": jsonEncode(data)}).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded!!')),
        );
      setState(() {
        uploading = false;
      });

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (ct) => const SplashScreen()));
    });
    // await supabase.from("Committee").update({'child': data}).eq('name', widget.navigationStack[0]).then((value) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('Document uploaded!!')),
    //     );
    //   setState(() {
    //     uploading = false;
    //   });

    //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (ct) => SplashScreen()));
    // });  



  }

  void insertValue(Map<String, dynamic> map, List<String> keys, dynamic value) {
    dynamic current = map;

    // Traverse through the keys to reach the target list
    for (int i = 0; i < keys.length - 1; i++) {
      current = current[keys[i]];
      if (current is! Map) {
        throw Exception("Key path is invalid: ${keys.sublist(0, i + 1).join(' -> ')}");
      }
    }

    // Insert the value into the target list
    dynamic targetList = current[keys.last];
    if (targetList is List) {
      targetList.add(value);
    } else {
      throw Exception("Target is not a list: ${keys.join(' -> ')}");
    }
  }
  

}