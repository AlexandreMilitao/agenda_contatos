import 'dart:io';

import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'contact_page.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();

    //Contact c = Contact();

    //c.name = "Alexandre";
    //c.email = "ale.levi@hotmail.com";
    //c.phone = "(17)98835-0744";
    //c.img = "imgteste";

    //helper.saveContact(c);

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A - Z"),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de Z - A"),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage(contact: Contact());
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: contacts[index].img != null
                        ? FileImage(File(contacts[index].img!))
                        : const AssetImage("assets/images/person.png")
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].name ?? "",
                      style: const TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    Text(
                      contacts[index].phone ?? "",
                      style: const TextStyle(
                        fontSize: 18.0,
                      ),
                    )
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort(
            (a, b) => a.name!.toLowerCase().compareTo(b.name!.toLowerCase()));
        break;
      case OrderOptions.orderza:
        contacts.sort(
            (a, b) => b.name!.toLowerCase().compareTo(a.name!.toLowerCase()));
        break;
    }
    setState(() {});
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
              onClosing: () {},
              builder: (context) {
                return Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.white),
                          child: const Text(
                            "Ligar",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20.0,
                            ),
                          ),
                          onPressed: () {
                            launchUrlString("tel:${contacts[index].phone}");
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.white),
                          child: const Text(
                            "Editar",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20.0,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _showContactPage(contact: contacts[index]);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.white),
                          child: const Text(
                            "Excluir",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 20.0,
                            ),
                          ),
                          onPressed: () {
                            helper.deleteContact(contacts[index].id!);
                            setState(() {
                              contacts.removeAt(index);
                              Navigator.pop(context);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              });
        });
  }

  void _showContactPage({required Contact? contact}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact)),
    ); //{required Contact contact}]
    if (recContact != null) {
      if (contact!.id != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) async {
      setState(() {
        contacts = list as List<Contact>;
      });
    });
  }
}
