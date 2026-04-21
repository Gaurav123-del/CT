import 'dart:async';
import 'package:flutter/material.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {

  int countdown = 10;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown == 0) {
        t.cancel();
      } else {
        setState(() => countdown--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        width: double.infinity,
        height: double.infinity,

        color: countdown % 2 == 0
            ? Colors.red.shade900
            : Colors.red.shade700,

        child: SafeArea(
          child: Column(
            children: [

              const SizedBox(height: 30),

              const Text(
                "🚨 EMERGENCY ALERT",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // ⏱️ Countdown
              Text(
                "Auto alert in $countdown sec",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const Spacer(),

              GestureDetector(
                onTap: () {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "SOS",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                "Emergency detected from voice input",
                style: TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 10),

              const Text(
                "Sending alerts to your contacts...",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [

                  Column(
                    children: const [
                      Icon(Icons.call, color: Colors.white, size: 30),
                      SizedBox(height: 5),
                      Text("Call", style: TextStyle(color: Colors.white)),
                    ],
                  ),

                  Column(
                    children: const [
                      Icon(Icons.message, color: Colors.white, size: 30),
                      SizedBox(height: 5),
                      Text("Message", style: TextStyle(color: Colors.white)),
                    ],
                  ),

                  Column(
                    children: const [
                      Icon(Icons.location_on, color: Colors.white, size: 30),
                      SizedBox(height: 5),
                      Text("Location", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "I'M SAFE",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}