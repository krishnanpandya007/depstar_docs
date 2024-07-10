// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:depstar_docs/auth_controller.dart';
import 'package:depstar_docs/search.dart';
import 'package:depstar_docs/splash_screen.dart';
import 'package:depstar_docs/upload_document.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

// ignore: must_be_immutable
class CometeePage extends StatefulWidget {
  List<String> navigationStack = [];
  dynamic globalMap;
  Map<String, dynamic>? contactMap;

  CometeePage(
      {super.key,
      required this.navigationStack,
      required this.globalMap,
      required this.contactMap});

  @override
  State<CometeePage> createState() => _CometeePageState();
}

class _CometeePageState extends State<CometeePage> {
// get map from context
  // if type==list then its terminating committee or sub-committee

  late String mapType = 'committee'; // committee | docs

  late dynamic focusedMap;
  List<dynamic> focusMapList = [];
  bool canEditDocument = false;

  @override
  void initState() {
    super.initState();

    focusedMap = widget.globalMap;
    for (final e in widget.navigationStack) {
      focusedMap = focusedMap[e];
    }
    if (focusedMap is Map) {
      // Select committee
      mapType = 'committee';
      setState(() {
        focusMapList = (focusedMap).keys.toList();
      });
    } else {
      // get current comittee email list
      List<String> adminEmails = [];
      (widget.contactMap?[widget.navigationStack[0]] as Map)
          .forEach((key, personList) {
        if (key == "Process Owner" || key == "Co-ordinator") {
          for (final person in personList) {
            print("Hid");
            print(personList);
            adminEmails.add(person['email']);
          }
        }
      });
      print(adminEmails);
      if (FirebaseAuth.instance.currentUser != null) {
        if (adminEmails.contains(FirebaseAuth.instance.currentUser?.email)) {
          canEditDocument = true;
        }
      }
      mapType = 'docs';
      for (final fileDetail in focusedMap) {
        focusMapList.add(fileDetail['name']);
      }
      setState(() {});
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: widget.navigationStack.isNotEmpty
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                canEditDocument && mapType == 'docs'
                    ? FloatingActionButton(
                        onPressed: () {
                          // upload new document
                          // take its name and file
                          // upload to bucket
                          // add entry to Committee
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => UploadDocumentScreen(
                                    navigationStack: widget.navigationStack,
                                  )));
                        },
                        child: const Icon(Icons.upload_file),
                      )
                    : const SizedBox(),
                const SizedBox(
                  width: 15.0,
                ),
                (FloatingActionButton.extended(
                  icon: const Icon(Icons.person),
                  label: const Text('Contact'),
                  onPressed: () {
                    showModalBottomSheet<void>(
                      // context and builder are
                      // required properties in this widget
                      context: context,
                      isScrollControlled: true,
                      isDismissible: true,

                      builder: (BuildContext context) {
                        // we set up a container inside which
                        // we create center column and display text

                        // Returning SizedBox instead of a Container
                        return SingleChildScrollView(
                          child: SizedBox(
                            // height: 200,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 20.0,
                                  ),
                                  ...getContactPersonsOfType('Process Owner'),
                                  ...getContactPersonsOfType('Co-ordinator'),
                                  ...getContactPersonsOfType('DCE'),
                                  ...getContactPersonsOfType('DIT'),
                                  ...getContactPersonsOfType('DCSE'),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ))
              ],
            )
          : null,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (ctx) => SearchDoc(
                              globalMap: widget.globalMap,
                              contactMap: widget.contactMap,
                            )));
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              )),
          IconButton(
              onPressed: () {
                showModalBottomSheet<void>(
                    // context and builder are
                    // required properties in this widget
                    context: context,
                    // isScrollControlled: true,
                    isDismissible: true,
                    builder: (BuildContext context) {
                      // we set up a container inside which
                      // we create center column and display text

                      // Returning SizedBox instead of a Container
                      return SizedBox(
                        height: 150,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 25.0, horizontal: 15),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(FirebaseAuth
                                          .instance.currentUser?.email ??
                                      ' User 12423')
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                      onPressed: () async {
                                        AuthService().signout(context: context);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (ctx) =>
                                                    const SplashScreen()));
                                      },
                                      child: const Text('Sign Out')))
                            ],
                          ),
                        ),
                      );
                    });
              },
              icon: const Icon(
                Icons.person,
                color: Colors.white,
              ))
        ],
        title: const Text(
          'Depstar Docs',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              padding: const EdgeInsets.only(left: 15.0, bottom: 10.0, top: 10.0),
              color: Colors.blue[100],
              child: Row(
                children: widget.navigationStack.map((navigationPath) {
                  return Row(children: [
                    Text(navigationPath),
                    const Icon(Icons.arrow_right)
                  ]);
                }).toList(),
              )),
          Expanded(
            // height: 700,
            child: focusMapList.isEmpty
                ? const Center(child: Text("No Documents"))
                : ListView.separated(
                    itemCount: focusMapList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text((focusMapList)[index]),
                        onTap: mapType == 'docs'
                            ? () async {
                                final storageRef =
                                    FirebaseStorage.instance.ref();
                                FirebaseStorage.instance.refFromURL(
                                    "gs://depstar-docs.appspot.com/" +
                                        widget.navigationStack.join('/') +
                                        '/' +
                                        (focusMapList)[index]);
                                print("Download URL");
                                print(widget.navigationStack.join('/') +
                                    '/' +
                                    (focusMapList)[index]);
                                print(await storageRef
                                    .child(widget.navigationStack.join('/') +
                                        '/' +
                                        (focusMapList)[index])
                                    .getDownloadURL());

                                await launchUrl(
                                    Uri.parse(await storageRef
                                        .child(
                                            widget.navigationStack.join('/') +
                                                '/' +
                                                (focusMapList)[index])
                                        .getDownloadURL()),
                                    mode: LaunchMode
                                        .externalNonBrowserApplication);

                                // DocumentFileSavePlus().saveFile(file, widget.navigationStack.join('_') + '_' + (focusMapList)[index], 'application/pdf');
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   SnackBar(
                                //     content: Text('Done! check your downloads folder...'),
                                //   ),
                                // );
                                // Directory? d = await getDownloadsDirectory();
                                // OpenFile.open("${d?.path}/${(focusMapList)[index]}");
                                // File a = File(widget.navigationStack.join('_') + '_' + (focusMapList)[index]);
                                // print(a.path);
                                // print(a.uri);
                                // OpenFile.open(a.path);
                              }
                            : () {
                                try {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (ctx) => CometeePage(
                                                navigationStack: [
                                                  ...widget.navigationStack,
                                                  focusMapList[index]
                                                ],
                                                globalMap: widget.globalMap,
                                                contactMap: widget.contactMap,
                                              )));
                                } catch (e) {
                                  print("NOT WORKING");
                                  print(e.toString());
                                }
                              },
                        // leading: canEditDocument ? IconButton(onPressed: (){}, icon: Icon(Icons.upload_file_outlined)) : SizedBox(),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            canEditDocument && mapType == 'docs'
                                ? IconButton(
                                    onPressed: () async {
                                      //delete document from bucket and from database entry in Committee
                                      // delete a file, delete an entry
                                      // final List<FileObject> objects =
                                      await FirebaseStorage.instance
                                          .ref()
                                          .child(
                                              widget.navigationStack.join('/') +
                                                  '/' +
                                                  (focusMapList)[index])
                                          .delete();
                                      dynamic data = await FirebaseFirestore
                                          .instance
                                          .collection("Comeetee")
                                          .doc(widget.navigationStack[0])
                                          .get();
                                      // data = data[0];
                                      // data = data['child'];
                                      // data = event.data()?["child"];
                                      data = jsonDecode(data.data()["child"]);
                                      if (data is List) {
                                        for (var i = 0; i < data.length; i++) {
                                          if (data[i]["name"] ==
                                              (focusMapList)[index]) {
                                            data.removeAt(i);
                                            break;
                                          }
                                        }
                                      } else {
                                        List<String> tmpNavStk = widget
                                            .navigationStack
                                            .map((e) => e)
                                            .toList();
                                        tmpNavStk.removeAt(0);
                                        // insertValue(data, tmpNavStk, );
                                        dynamic current = data;
                                        // Traverse through the keys to reach the target list
                                        for (int i = 0;
                                            i < tmpNavStk.length - 1;
                                            i++) {
                                          current = current[tmpNavStk[i]];
                                          if (current is! Map) {
                                            throw Exception(
                                                "Key path is invalid: ${tmpNavStk.sublist(0, i + 1).join(' -> ')}");
                                          }
                                        }
                                        dynamic targetList =
                                            current[tmpNavStk.last];
                                        if (targetList is List) {
                                          for (var i = 0;
                                              i < targetList.length;
                                              i++) {
                                            if (targetList[i]["name"] ==
                                                (focusMapList)[index]) {
                                              targetList.removeAt(i);
                                              break;
                                            }
                                          }
                                          // targetList.remo({"name": (focusMapList)[index], "path": widget.navigationStack.join('/') + '/' + ((focusMapList)[index]?? 'Document.pdf')});
                                        } else {
                                          throw Exception(
                                              "Target is not a list: ${tmpNavStk.join(' -> ')}");
                                        }
                                      }
                                      await FirebaseFirestore.instance
                                          .collection("Comeetee")
                                          .doc(widget.navigationStack[0])
                                          .update({
                                        "child": jsonEncode(data)
                                      }).then((value) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content:
                                                  Text('Document deleted!!')),
                                        );

                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (ct) =>
                                                    const SplashScreen()));
                                      });
                                    },
                                    icon: const Icon(Icons.delete_outline))
                                : const SizedBox(),
                            Icon(
                              mapType == 'committee'
                                  ? Icons.arrow_forward_ios_rounded
                                  : Icons.open_in_new_rounded,
                              size: 15.0,
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext ctx, int length) {
                      return const Divider();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> getContactPersonsOfType(String type) {
    return <Widget>[
      Chip(
          label: Text(
        type,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
      )),
      // (widget.contactMap![widget.navigationStack[0]][type]).map((val) => )
      ...widget.contactMap?[widget.navigationStack[0]][type].map((val) {
        return Column(
          children: [
            const SizedBox(
              height: 10.0,
            ),
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(
                  width: 18.0,
                ),
                Text(val['name'])
              ],
            ),
            ListTile(
              title: Text(val['email']),
              leading: const Icon(Icons.email_outlined),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                launchUrlString("mailto:${val['email']}");
              },
            ),
          ],
        );
      }),
      const SizedBox(
        height: 20.0,
      ),
    ];
  }
}
