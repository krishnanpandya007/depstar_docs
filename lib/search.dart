import 'package:depstar_docs/commete.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SearchDoc extends StatefulWidget {

  dynamic globalMap;
  Map<String, dynamic>? contactMap;

  SearchDoc({super.key, required this.globalMap, required this.contactMap});

  @override
  State<SearchDoc> createState() => _SearchDocState();
}

class _SearchDocState extends State<SearchDoc> {

  final TextEditingController _searchDocNameController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text(
          'Search Docs',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[500],
      ),

      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          
          children: [
            TextField(
              onChanged: _onQueryChange,
              onSubmitted: _onQueryChange,
              controller: _searchDocNameController,
              // readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Document name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25.0,),
            Container(width:double.infinity, color: Colors.blue,child: const Center(child: Text("RESULTS", style: TextStyle(color: Colors.white),)),),
            const SizedBox(height: 15.0,),
            Expanded(child:_searchResults.isEmpty ? const Center(child: Text("Oops, Nothing to show...", style: TextStyle(color: Colors.grey),),) :  Column(
              children: _searchResults.map((elem) => _resultEntry(elem["name"], elem["url"])).toList()
                    
            ) 
            )
            
          ],
        ),
      ),
    );
  }

  Widget _resultEntry(String documentName, List<String> navPath) {

    return InkWell(
      onTap: (){
        Navigator.push(
        context,
        MaterialPageRoute(
            builder: (ctx) => CometeePage(
                  navigationStack: navPath,
                  globalMap: widget.globalMap,
                  contactMap: widget.contactMap,
                )));
      },
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(width: 2.0, color: Colors.grey))),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(documentName, style:const TextStyle(fontWeight: FontWeight.bold) ,),
            Text(navPath.join(' > '), style: const TextStyle(fontSize: 11.0),)
          ],
        ),
      ),
    );

  }

  void _onQueryChange(String value) {
    setState(() {
      _searchResults = searchInDataStructure(widget.globalMap, value, []);
    });
  } 

  List<Map<String, dynamic>> searchInDataStructure(
    Map<String, dynamic> data, String query, List<String> currentPath) {
      print("DEBUG::");
      print(data);
  List<Map<String, dynamic>> results = [];

  data.forEach((key, value) {
    if (value is List) {
      for (var item in value) {
        if (item['name'].toLowerCase().contains(query.toLowerCase())) {
          print("adding");
          results.add({'name': item['name'], 'url': [...currentPath, key]});
        }
      }
    } else if (value is Map) {
          print("recursing");

      results.addAll(searchInDataStructure(
          value as Map<String,dynamic>, query, [...currentPath, key.toString()]));
    }
  });
  print("Done");
  print(results);

  return results;
}
  
}