import 'package:flutter/material.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({Key? key}) : super(key: key);

  @override
  _SocialPageState createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  final List<Person> _people = [
    Person('Sam Salmi', 'XamXalmi@example.com'),
    Person('Emily Garcia', 'emily.garcia@example.com'),
    Person('Benjamin Lee', 'benjamin.lee@example.com'),
    Person('Sophia Patel', 'sophia.patel@example.com'),
  ];

  void _addPerson(String name, String email) {
    setState(() {
      _people.add(Person(name, email));
    });
    Navigator.of(context).pop();
  }

  void _showAddPersonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final nameController = TextEditingController();
        final emailController = TextEditingController();

        return AlertDialog(
          title: const Text('Add a new person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter the name',
                ),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter the email',
                ),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                child: const Text('Add'),
                onPressed: () {
                  _addPerson(nameController.text, emailController.text);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonBubble(BuildContext context, Person person) {
    return Dismissible(
      key: Key(person.name),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _people.remove(person);
        });
      },
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30.0,
              child: Icon(Icons.person),
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person.name),
                    const SizedBox(height: 5.0),
                    Text(person.email),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Social page',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.blue),
            onPressed: () {
              _showAddPersonDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _people.length,
              itemBuilder: (BuildContext context, int index) {
                final person = _people[index];
                return _buildPersonBubble(context, person);
              },
            ),
          ],
        ),
      ),
    );
  }
}

  class Person {
  final String name;
  final String email;

  Person(this.name, this.email);
}
