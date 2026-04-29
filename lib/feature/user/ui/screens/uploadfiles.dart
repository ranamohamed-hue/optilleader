import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: UploadFilePage(),
    debugShowCheckedModeBanner: false,
  ));
}

class UploadFilePage extends StatelessWidget {
  const UploadFilePage({super.key});

  final Color primaryDark = const Color(0xFF1E2746);
  final Color accentGold = const Color(0xFFD4AF37);
  final Color backgroundColor = const Color(0xFFE6D4B0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: accentGold, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Upload Document', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(color: accentGold, height: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Upload your research or certificates",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E2746))),
            const SizedBox(height: 20),

            // منطقة رفع الملفات (Dashed Border effect using Container decoration)
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accentGold, width: 2, style: BorderStyle.solid), // تقدري تستخدمي package dotted_border هنا لشكل أحسن
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 60, color: primaryDark),
                  const SizedBox(height: 12),
                  const Text("Click to select a file", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const Text("PDF, DOCX or JPG (Max 10MB)", 
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // حقول البيانات
            _buildInputField("Document Title", "e.g. Machine Learning Paper"),
            const SizedBox(height: 15),
            _buildInputField("Category", "e.g. Research, Conference, etc."),
            const SizedBox(height: 15),
            _buildInputField("Description", "Brief details about the file", maxLines: 3),

            const SizedBox(height: 40),

            // زر الرفع
            SPrimaryButton(
              text: "Upload Now",
              color: primaryDark,
              textColor: accentGold,
              onPressed: () {
                // هنا نربط الـ Logic بتاع Firebase
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: primaryDark, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryDark.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentGold, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget للزرار عشان تستخدميه في كل حتة
class SPrimaryButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const SPrimaryButton({super.key, required this.text, required this.color, required this.textColor, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}