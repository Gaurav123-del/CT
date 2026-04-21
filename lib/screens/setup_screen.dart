import 'package:flutter/material.dart';
import 'contacts_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool voice1Recorded = false;
  bool voice2Recorded = false;

  void recordVoice(int index) {
    setState(() {
      if (index == 1) {
        voice1Recorded = true;
      } else {
        voice2Recorded = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Voice Sample $index Recorded ✅"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF1c1c1c)],
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

                // 🔙 Back Button + Title
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Setup Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 👤 Name Input
                const Text(
                  "Your Name",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 8),

                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter your name",
                    hintStyle: const TextStyle(color: Colors.grey),

                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "Voice Samples",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Record 2 voice samples for emergency detection",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 20),

                _voiceCard(
                  title: "Sample 1",
                  isRecorded: voice1Recorded,
                  onTap: () => recordVoice(1),
                ),

                const SizedBox(height: 15),

                _voiceCard(
                  title: "Sample 2",
                  isRecorded: voice2Recorded,
                  onTap: () => recordVoice(2),
                ),

                const Spacer(),

                // 🚀 Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ContactsScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "CONTINUE",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
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

  Widget _voiceCard({
    required String title,
    required bool isRecorded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isRecorded ? Colors.greenAccent : Colors.grey.shade800,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isRecorded ? Icons.check_circle : Icons.mic,
              color: isRecorded ? Colors.greenAccent : Colors.grey,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                isRecorded
                    ? "$title Recorded"
                    : "Tap to record $title",
                style: TextStyle(
                  color: isRecorded ? Colors.greenAccent : Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}