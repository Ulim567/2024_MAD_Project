import 'package:flutter/material.dart';

class SearchMapPage extends StatefulWidget {
  const SearchMapPage({super.key});

  @override
  State<SearchMapPage> createState() => _SearchMapPageState();
}

class _SearchMapPageState extends State<SearchMapPage> {
  final TextEditingController _searchContent = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          shape: const Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: TextField(
            controller: _searchContent,
            decoration: const InputDecoration(
                hintText: '어디로 갈까요?',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.black38)),
            autofocus: true,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchContent.text = "";
              },
            ),
          ],
        ),
        body: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: 100,
          itemBuilder: (BuildContext ctx, int idx) {
            return Row(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Icon(
                    Icons.schedule,
                    color: Colors.black54,
                    size: 22,
                  ),
                ),
                Expanded(
                  child: Text(
                    "Number $idx andoakdfoinueyoqiadfafasdasfweunyoi",
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    print("Delete!");
                  },
                  icon: const Icon(Icons.delete_outlined),
                  color: Colors.black54,
                )
              ],
            );
          },
          separatorBuilder: (BuildContext ctx, int idx) {
            return const Divider(
              height: 8,
              thickness: 1,
              color: Colors.black12,
            );
          },
        ));
  }
}
