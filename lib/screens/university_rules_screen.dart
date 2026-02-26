import 'package:flutter/material.dart';

class UniversityRulesScreen extends StatelessWidget {
  const UniversityRulesScreen({super.key});

  final List<Map<String, dynamic>> rules = const [
    {
      'title': 'Sportsmanship Code',
      'rules': [
        'Respect opponents, officials, and teammates at all times.',
        'Accept victory with humility and defeat with dignity.',
        'Never argue with officials\' decisions.',
        'Help injured opponents regardless of team.',
      ],
      'icon': Icons.groups,
    },
    {
      'title': 'Attendance Rules',
      'rules': [
        'Attendance is mandatory for all scheduled matches.',
        'Report at least 30 minutes before match time.',
        'In case of emergency, inform sports coordinator 24 hours in advance.',
        'Three unexcused absences lead to disqualification.',
      ],
      'icon': Icons.calendar_today,
    },
    {
      'title': 'Dress Code',
      'rules': [
        'Wear proper sports attire and shoes.',
        'University-provided jerseys must be worn for official matches.',
        'No jewelry, watches, or accessories during play.',
        'Proper safety gear must be used where required.',
      ],
      'icon': Icons.checkroom,
    },
    {
      'title': 'Equipment Rules',
      'rules': [
        'Handle all sports equipment with care.',
        'Report damaged equipment immediately.',
        'Return equipment after use in proper condition.',
        'Personal equipment must meet safety standards.',
      ],
      'icon': Icons.sports,
    },
    {
      'title': 'Conduct Rules',
      'rules': [
        'No foul language or abusive behavior.',
        'No smoking, drugs, or alcohol in sports areas.',
        'Maintain discipline in changing rooms and stands.',
        'Follow instructions of coaches and officials.',
      ],
      'icon': Icons.gavel,
    },
    {
      'title': 'Safety Rules',
      'rules': [
        'Warm-up properly before any activity.',
        'Use protective gear (helmets, pads, guards) when required.',
        'Stop playing if injured and seek medical help.',
        'Stay hydrated during practice and matches.',
      ],
      'icon': Icons.health_and_safety,
    },
    {
      'title': 'Eligibility Rules',
      'rules': [
        'Only registered students can participate.',
        'Valid student ID must be presented when requested.',
        'Maintain minimum 2.0 CGPA to participate.',
        'Follow academic eligibility criteria.',
      ],
      'icon': Icons.school,
    },
    {
      'title': 'Fair Play Rules',
      'rules': [
        'No performance-enhancing drugs allowed.',
        'No match-fixing or point shaving.',
        'Play to win but within rules.',
        'Report any unfair practices immediately.',
      ],
      'icon': Icons.thumb_up,
    },
  ];

  final List<String> motivationalQuotes = const [
    "The harder the battle, the sweeter the victory.",
    "Champions keep playing until they get it right.",
    "You miss 100% of the shots you don't take.",
    "It's not whether you get knocked down, it's whether you get up.",
    "The only way to prove you are a good sportsman is be humble when you win and accept when you lose.",
    "Practice like you've never won, perform like you've never lost.",
    "Sports do not build character, they reveal it.",
    "Winning isn't everything, but wanting to win is.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('University Sports Rules'),
        backgroundColor: const Color(0xFF00A99D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Sports Rules & Guidelines',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Rules and regulations for all sports activities at the university',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 25),
            
            // Motivational Quote
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00A99D).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00A99D).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Color(0xFF00A99D)),
                      SizedBox(width: 8),
                      Text(
                        'Motivation Corner',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    motivationalQuotes[DateTime.now().day % motivationalQuotes.length],
                    style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 25),
            
            // All Rules
            const Text(
              'Sports Rules',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            
            ...rules.map((rule) => _buildRuleCard(rule)).toList(),
            
            const SizedBox(height: 30),
            
            // Important Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Important Notice',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Violation of any rule may result in:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  _buildPenaltyItem('First offense: Warning'),
                  _buildPenaltyItem('Second offense: Match suspension'),
                  _buildPenaltyItem('Third offense: Tournament disqualification'),
                  _buildPenaltyItem('Serious offenses: Sports ban for entire semester'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Contact Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contact_support, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'For Queries',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Sports Coordinator Office:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 5),
                  Text('Location: Sports Complex, Room 101'),
                  Text('Phone: 042-1234567 Ext. 234'),
                  Text('Email: sports@university.edu.pk'),
                  Text('Hours: 9:00 AM - 5:00 PM (Monday-Friday)'),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleCard(Map<String, dynamic> rule) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A99D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(rule['icon'], color: const Color(0xFF00A99D)),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    rule['title'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            ...rule['rules'].map<Widget>((ruleText) => _buildRuleItem(ruleText)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 90, 90, 90)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.close, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}