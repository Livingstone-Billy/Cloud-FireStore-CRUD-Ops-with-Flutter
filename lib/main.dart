import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      routes: {
        "/": (context) => const MyApp(),
        "/addContact": (context) => AddContact(),
        "/updateContact": (context) => UpdateContact(),
        "/deleteContact": (context) => DeleteContact(),
      },
    )
  );
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.edit,
                  size: 30,
                  color: Colors.white,
                ),
                tooltip: 'Edit Contact',
                onPressed: () => Navigator.pushNamed(context, '/updateContact'),
              )
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 30,
                  color: Colors.white,
                ),
                tooltip: 'Delete Contact',
                onPressed: () => Navigator.pushNamed(context, '/deleteContact'),
              )
          )
        ],
      ),
      body: const ContactPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.pushNamed(context, '/addContact');
        },
        backgroundColor: Colors.blueAccent,
        tooltip: 'Add new contact',
        child: const Icon(
            Icons.person_add_alt,
          size: 28,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ContactPage extends StatefulWidget{
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage>{

  final Stream<QuerySnapshot> _contactsStream = FirebaseFirestore.instance.collection('contacts').snapshots();

  Widget contactPhoto(String text){
    List<Color> colors = [Colors.tealAccent, Colors.purple, Colors.blue,
      Colors.orange, Colors.lime, Colors.green, Colors.amberAccent, Colors.red, Colors.lime, Colors.blueGrey];
    Random random = Random();
    int colorIndex = random.nextInt(colors.length);
    Color randColor = colors[colorIndex];
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        border: Border.all(
          color: randColor,
        ),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Center(
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: randColor,
        ),
      ),
      )
    );
  }

  @override
  Widget build(BuildContext context){
    return StreamBuilder(
      stream: _contactsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if(snapshot.hasError){
          return const Text('Error retrieving contacts from database');
        }
        if(snapshot.connectionState == ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final data = snapshot.requireData;
        return ListView.builder(
          itemCount: data.size,
          itemBuilder: (context, index){
            String text = data.docs[index]['fullName'];
            return ListTile(
              leading: contactPhoto(text[0].toUpperCase()),
              title: Text(data.docs[index]['fullName']),
              subtitle: Text(data.docs[index]['phoneNumber']),
            );
          },
        );
      },
    );
  }
}

class AddContact extends StatelessWidget{

  final GlobalKey<FormState> _formKey = GlobalKey();

  String fullName = "";
  String phoneNumber = "";

  @override
  Widget build(BuildContext context){
    CollectionReference contacts = FirebaseFirestore.instance.collection('contacts');

    Future<void> addNewContact(){
      return contacts.doc(fullName).set({
        'fullName': fullName,
        'phoneNumber': phoneNumber
      }, SetOptions(merge: true),
      ).then((value) => print("New contact has been added")).catchError((error) =>
      print("Error while adding new contact"));
    }
    return MaterialApp(
      title: 'Create new Contact',
      home: Scaffold(
      appBar: AppBar(title: const Text('Create New Contact')),
      body: Container(
      margin: const EdgeInsets.only(top: 40.0),
      child: Center(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: TextFormField(
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Enter your full names to proceed';
                    }else{
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Enter your full names',
                    icon: Icon(Icons.person)
                  ),
                  onChanged: (text){
                    fullName = text;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: TextFormField(
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return 'Enter your phone number to proceed';
                    }else{
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                      labelText: 'Enter your phone number',
                      icon: Icon(Icons.call)
                  ),
                  onChanged: (text){
                    phoneNumber = text;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: (){
                    if(_formKey.currentState!.validate()){
                      addNewContact();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Submit'),
                ),
              )
            ],
          ),
        ),
      ),
    ),
    )
    );
  }
}

Future<void> deleteContact(String documentID, CollectionReference collectionReference){
  return collectionReference.doc(documentID).delete()
      .then((value) => print("Contact deleted successfully")).catchError((error) =>
  print("Error while deleting contact"));
}


class DeleteContact extends StatelessWidget{

  String fullName = "";

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context){

    CollectionReference contacts = FirebaseFirestore.instance.collection('contacts');

    return MaterialApp(
      title: 'Delete Contact',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Delete Contact'),
          backgroundColor: Colors.redAccent,
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: TextFormField(
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Enter fullname to delete contact';
                      }else{
                        return null;
                      }
                    },
                    onChanged: (text){
                      fullName = text;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter full name',
                      icon: Icon(Icons.person_remove)
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: (){
                            if(_formKey.currentState!.validate()){
                              deleteContact(fullName, contacts);
                            }
                          },
                          child: const Text('Delete'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                        child: ElevatedButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.redAccent
                          ),
                          child: const Text('Home'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UpdateContact extends StatelessWidget{


  String originalFullName = "";
  String newFullName = "";
  String newContact = "";

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context){

    CollectionReference contacts = FirebaseFirestore.instance.collection('contacts');

    Future<void> updateContact(){
      deleteContact(originalFullName, contacts);
      return contacts.doc(newFullName).set({
        'fullName': newFullName,
        'phoneNumber': newContact,
      }).then((value) => print("Contact updated successfully")).catchError((error) =>
      print("Error while updating new contact"));
    }

    return MaterialApp(
      title: 'Update Contact',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Update Existing Contact'),
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: TextFormField(
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Enter original name to proceed';
                      }else{
                        return null;
                      }
                    },
                    onChanged: (text){
                      originalFullName = text;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter original name',
                      icon: Icon(Icons.account_circle)
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: TextFormField(
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Enter new name to proceed';
                      }else{
                        return null;
                      }
                    },
                    onChanged: (text){
                      newFullName = text;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Enter new name',
                        icon: Icon(Icons.person)
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: TextFormField(
                    validator: (value){
                      if(value == null || value.isEmpty){
                        return 'Enter new contact to proceed';
                      }else{
                        return null;
                      }
                    },
                    onChanged: (text){
                      newContact = text;
                    },
                    decoration: const InputDecoration(
                        labelText: 'Enter new contact',
                        icon: Icon(Icons.call)
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: (){
                      if(_formKey.currentState!.validate()){
                        updateContact();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Update'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}