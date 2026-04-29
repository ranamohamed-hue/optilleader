import 'package:flutter/material.dart';

class DoctorProfileDataPage extends StatelessWidget {
  const DoctorProfileDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryNavy = Color(0xFF1A237E); // الكحلي
    const Color accentGold = Color(0xFFC6A700); // الذهبي
    const Color lightBeige = Color(0xFFF5F5DC); // البيج

    return Scaffold(
      backgroundColor: lightBeige,
      body: CustomScrollView(
        slivers: [
          // الهيدر (صورة الدكتور واسمه)
          SliverAppBar(
            expandedHeight: 140.0,
            pinned: true,
            backgroundColor: primaryNavy,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: accentGold, size: 35),
                    ),
                    const SizedBox(width: 15),
                    const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dr. Sara Mohamed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text("Basic Profile Info", style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              // 1. General Information Card
              _buildSectionCard(
                icon: Icons.badge_outlined,
                title: "General Information",
                children: [
                  _buildField("Full Name", "Enter full name"),
                  _buildField("Phone Number", "+20 123 456 789"),
                  Row(
                    children: [
                      Expanded(child: _buildField("Gender", "Male")),
                      const SizedBox(width: 10),
                      Expanded(child: _buildField("Status", "Active")),
                    ],
                  ),
                  _buildField("Date of Birth", "DD/MM/YYYY"),
                  _buildField("Current Employer", "Company or Institution name"),
                ],
              ),

              // 2. Social Data Card
              _buildSectionCard(
                icon: Icons.groups_outlined,
                title: "Social Data",
                children: [
                  _buildField("Marital Status", "Single, Married, etc."),
                  _buildField("Number of Children", "e.g. 2"),
                ],
              ),

              // 3. Contact Details Card
              _buildSectionCard(
                icon: Icons.contact_mail_outlined,
                title: "Contact Details",
                children: [
                  _buildField("Email Address", "sara@example.com"),
                  _buildField("Home Address", "City, District, St."),
                ],
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFC6A700), size: 22),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 30),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF5F5DC).withOpacity(0.3),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}