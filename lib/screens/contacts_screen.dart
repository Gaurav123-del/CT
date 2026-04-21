import 'package:flutter/material.dart';
import 'home_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {

  List<Map<String, dynamic>> contacts = [];

  void addContact() {
    if (contacts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 5 contacts allowed")),
      );
      return;
    }

    setState(() {
      contacts.add({
        "name": "",
        "phone": "",
        "primary": false,
      });
    });
  }

  void deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
    });
  }

  void setPrimary(int index) {
    setState(() {
      for (var c in contacts) {
        c['primary'] = false;
      }
      contacts[index]['primary'] = true;
    });
  }

  bool isValid() {
    return contacts.isNotEmpty &&
        contacts.every((c) =>
            c['name'].toString().isNotEmpty &&
            c['phone'].toString().isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: addContact,
        child: const Icon(Icons.add, color: Colors.black),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF121212)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const SizedBox(height: 20),

                // 🔙 Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Emergency Contacts",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  "Add up to 5 trusted contacts for emergency alerts",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 15),

                // 📊 Progress
                LinearProgressIndicator(
                  value: contacts.length / 5,
                  backgroundColor: Colors.grey.shade800,
                  color: Colors.greenAccent,
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {

                      final contact = contacts[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(18),
                        ),

                        child: Column(
                          children: [

                            Row(
                              children: [

                                CircleAvatar(
                                  backgroundColor: Colors.greenAccent,
                                  child: Text(
                                    contact['name'].isEmpty
                                        ? "?"
                                        : contact['name'][0].toUpperCase(),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: TextField(
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: "Name",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (val) {
                                      contact['name'] = val;
                                      setState(() {});
                                    },
                                  ),
                                ),

                                IconButton(
                                  icon: Icon(
                                    contact['primary']
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.yellow,
                                  ),
                                  onPressed: () => setPrimary(index),
                                ),
                              ],
                            ),

                            const Divider(color: Colors.grey),

                            Row(
                              children: [

                                Expanded(
                                  child: TextField(
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: const InputDecoration(
                                      hintText: "Phone Number",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (val) {
                                      contact['phone'] = val;
                                    },
                                  ),
                                ),

                                IconButton(
                                  icon: const Icon(Icons.call, color: Colors.greenAccent),
                                  onPressed: () {
                                    // future call feature
                                  },
                                ),

                                // 💬 SMS Icon
                                IconButton(
                                  icon: const Icon(Icons.message, color: Colors.blueAccent),
                                  onPressed: () {
                                    // future sms feature
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteContact(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: isValid()
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const HomeScreen(),
                              ),
                            );
                          }
                        : null,
                    child: const Text(
                      "SAVE & CONTINUE",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}