import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_keyboard/in_app_keyboard.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'In-App Keyboard Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
      ),
      builder: (context, child) {
        return KeyboardOverlay(child: child!);
      },
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom In-App Keyboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Modern Input System",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("This system replaces the native keyboard entirely."),
            const SizedBox(height: 32),
            
            const InAppTextField(
              keyboardType: KeyboardType.text,
              decoration: InputDecoration(
                labelText: 'Full Name (Intent: Text)',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            const InAppTextField(
              keyboardType: KeyboardType.number,
              decoration: InputDecoration(
                labelText: 'Amount (Intent: Number)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            const InAppTextField(
              keyboardType: KeyboardType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email (Intent: Email + Shortcuts)',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            const InAppTextField(
              keyboardType: KeyboardType.text,
              layout: LayoutVariant.arabic,
              decoration: InputDecoration(
                labelText: 'Arabic (Intent: Text, Layout: Arabic)',
                prefixIcon: Icon(Icons.language),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            const InAppTextField(
              keyboardType: KeyboardType.password,
              decoration: InputDecoration(
                labelText: 'Secure Password (Intent: Password)',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 40),
            
            Center(
              child: Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton.icon(
                    onPressed: () {
                      ref.read(keyboardControllerProvider.notifier).hide();
                      FocusScope.of(context).unfocus();
                    },
                    icon: const Icon(Icons.keyboard_hide),
                    label: const Text("Dismiss Keyboard"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 300), // Space for keyboard
          ],
        ),
      ),
    );
  }
}
