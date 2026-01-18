import 'dart:math';
import 'package:flutter/material.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final List<String> _attachments = [];
  final int _maxAttachments = 3;

  String _generateReference() {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void _pickAttachment() {
    if (_attachments.length >= _maxAttachments) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 3 attachments allowed.')),
      );
      return;
    }
    setState(() {
      _attachments.add('attachment_${_attachments.length + 1}.pdf');
    });
  }

  void _sendEmail() {
    final String name = _nameController.text.trim();
    final String customerEmail = _emailController.text.trim();
    final String body = _bodyController.text.trim();
    final String reference = _generateReference();

    if (name.isEmpty || customerEmail.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    final String subject = "Drinnk & Deriv Issue - $name - #$reference";

    // Simulate sending email to support
    print('Sending email to: appsolootlee8@gmail.com');
    print('Subject: $subject');
    print('Body: $body');
    print('Attachments: $_attachments');

    // Simulate sending confirmation email to customer
    print('Sending confirmation email to: $customerEmail');
    print('Subject: Support Request Received - #$reference');
    print('Body: Hi $name, we have received your information. Your reference is #$reference. Turnaround is 3-5 working days.');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Support request sent! Reference: #$reference')),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact Us',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Turnaround time: 3-5 working days',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Your Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Message',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Attachments (Max 3, 3MB each)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ..._attachments.map((file) => Chip(
                      label: Text(file),
                      onDeleted: () {
                        setState(() {
                          _attachments.remove(file);
                        });
                      },
                    )),
                if (_attachments.length < _maxAttachments)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 20),
                    label: const Text('Add File'),
                    onPressed: _pickAttachment,
                  ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _sendEmail,
                child: const Text('SEND SUPPORT REQUEST'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
