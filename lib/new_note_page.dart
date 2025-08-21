import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewNotePage extends StatefulWidget {
  final Map<String, dynamic>? note;
  final String? docId;

  const NewNotePage({Key? key, this.note, this.docId}) : super(key: key);

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  double fontSize = 16;
  bool isBold = false;
  bool isItalic = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?['title'] ?? '');
    contentController = TextEditingController(text: widget.note?['content'] ?? '');
  }

  Future<void> saveNote() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    final date = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Boş alanları doldurun")),
      );
      return;
    }

    try {
      final notesRef = FirebaseFirestore.instance.collection('notes');

      if (widget.docId != null) {
        // 🔁 Güncelleme
        await notesRef.doc(widget.docId).update({
          'title': title,
          'content': content,
          'date': date,
        });
      } else {
        // ➕ Yeni not
        await notesRef.add({
          'title': title,
          'content': content,
          'date': date,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt başarısız")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Not Düzenle', style: TextStyle(color: Colors.cyanAccent)),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔠 Stil ayarları
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.format_bold, color: isBold ? Colors.green : Colors.redAccent),
                  onPressed: () => setState(() => isBold = !isBold),
                ),
                IconButton(
                  icon: Icon(Icons.format_italic, color: isItalic ? Colors.green : Colors.redAccent),
                  onPressed: () => setState(() => isItalic = !isItalic),
                ),
                IconButton(
                  icon: const Icon(Icons.text_increase, color: Colors.greenAccent),
                  onPressed: () => setState(() => fontSize += 2),
                ),
                IconButton(
                  icon: const Icon(Icons.text_decrease, color: Colors.orangeAccent),
                  onPressed: () => setState(() {
                    if (fontSize > 10) fontSize -= 2;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 📝 Başlık
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Başlık',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 📄 İçerik
            TextField(
              controller: contentController,
              maxLines: null,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
              ),
              decoration: const InputDecoration(
                hintText: 'Not içeriği',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.redAccent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🧠 Görsel
            SizedBox(
              child: Image.asset('assets/3.gif', fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),

            // 💾 Kaydet butonu
            ElevatedButton.icon(
              icon: const Icon(Icons.save,color: Colors.white,),
              label: const Text("Kaydet",style: TextStyle(color: Colors.white),),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: saveNote,
            ),
          ],
        ),
      ),
    );
  }
}
