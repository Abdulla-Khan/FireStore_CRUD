import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('task').snapshots();
  TextEditingController controller = TextEditingController();
  addData() async {
    await FirebaseFirestore.instance.collection('task').add({
      'tasks': controller.text,
      'date':
          '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}',
    });
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Container(
          margin: EdgeInsets.all(40),
          padding: EdgeInsets.only(top: 40),
          child: Center(
            child: Column(
              children: [
                TextField(
                  controller: controller,
                ),
                ElevatedButton(onPressed: () => addData(), child: Text('Add')),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 200,
          width: MediaQuery.of(context).size.width * 0.9,
          child: StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return CircularProgressIndicator();
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data()! as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['tasks']),
                      subtitle: Text(data['date']),
                      leading: IconButton(
                          onPressed: () {
                            document.reference.delete();
                          },
                          icon: Icon(Icons.delete)),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return SimpleDialog(
                                  title: Text('Update'),
                                  children: [
                                    TextField(
                                      controller: taskCont,
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          document.reference.update({
                                            'tasks': taskCont.text,
                                            'date':
                                                '${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}',
                                          });
                                          Navigator.pop(context);
                                          taskCont.clear();
                                        },
                                        child: Text('UPDATE'))
                                  ],
                                );
                              });
                        },
                      ),
                    );
                  }).toList(),
                );
              }),
        )
      ],
    ));
  }

  TextEditingController taskCont = TextEditingController();
}
