import 'package:ai_chat/services/ai_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  static final List<Map<String, dynamic>> _messages = []; // {'from': 'user'/'ai', 'text': ''}
  static final List<List<Map<String, dynamic>>> _history = [];
  bool _isLoading = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _hasTyped = false;

  void _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'from': 'user', 'text': message});
      _messages.add({'from': 'ai', 'text': '...' });
    });

    _audioPlayer.play(AssetSource('sound/sendsound.mp3'));

    try {
      final ai = ChatAiService();
      final result = await ai.connectAi(message);
      setState(() {
        _messages.removeLast();
        _messages.add({'from': 'ai', 'text': utf8.decode(result.runes.toList())});
      });
      _audioPlayer.play(AssetSource('sound/getsound.mp3'));
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add({'from': 'ai', 'text': 'Hata: ${e.toString()}'});
      });
     // _audioPlayer.play(AssetSource('sound/sendsound.mp3'));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: Text('Gülseren Gpt', style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        backgroundColor: Colors.grey.shade900,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey.shade900),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    if (_messages.isNotEmpty) _history.insert(0, List.from(_messages));
                    _messages.clear();
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Yeni Sohbet', style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Roboto')),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.chat_bubble_outline, color: Colors.white),
              title: Text('Yeni Sohbet', style: TextStyle(color: Colors.white, fontFamily: 'Roboto')),
              onTap: () {
                Navigator.pop(context); // closes drawer
                setState(() {
                  if (_messages.isNotEmpty) _history.insert(0, List.from(_messages));
                  _messages.clear();
                });
              },
            ),
            Divider(color: Colors.white24),
            ..._history.asMap().entries.map((entry) {
              final index = entry.key;
              return ListTile(
                leading: Icon(Icons.history, color: Colors.white70),
                title: Text('Sohbet ${index + 1}', style: TextStyle(color: Colors.white70, fontFamily: 'Roboto')),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _messages
                      ..clear()
                      ..addAll(entry.value);
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['from'] == 'user';
                  return Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser)
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage('assets/ai.png'),
                        ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blueGrey.shade700 : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            msg['text'],
                            style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'Roboto'),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      if (isUser)
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: AssetImage('assets/avatarx.png'),
                        ),
                    ],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.4),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintText: 'Mesajınızı yazın',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : () {
                      _sendMessage();
                      _controller.clear();
                    },
                  ),
                ),
                onChanged: (text) {
                  _audioPlayer.play(AssetSource('sound/pop.mp3'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
