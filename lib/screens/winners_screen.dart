import 'package:flutter/material.dart';

class WinnersScreen extends StatelessWidget {
  const WinnersScreen({super.key});

  final List<Map<String, dynamic>> winners = const [
    {
      'sport': 'Cricket Tournament 2024',
      'position': '🏆 Champions',
      'team': 'Computer Science Department',
      'members': 'Ali Khan (Captain), Ahmed Raza, Bilal Shah, Hassan Malik, Usman Khan',
      'image': 'assets/cricket_winners.jpg',
      'description': 'Won the final match against Electrical Engineering by 45 runs.',
    },
    {
      'sport': 'Football League 2024',
      'position': '🥇 First Position',
      'team': 'Sports Sciences Department',
      'members': 'Rashid Ali (Captain), Farhan Ahmed, Kamran Shah, Zain Malik',
      'image': 'assets/football_winners.jpg',
      'description': 'Secured victory with 3-2 score in the final match.',
    },
    {
      'sport': 'Badminton Singles 2024',
      'position': '🥇 Gold Medal',
      'team': 'Muhammad Asif',
      'members': 'Individual Winner',
      'image': 'assets/badminton_winner.jpg',
      'description': 'Defeated defending champion in straight sets.',
    },
    {
      'sport': '100m Race',
      'position': '🥇 First',
      'team': 'Ahmed Hassan',
      'members': 'Individual - Business Administration',
      'image': 'assets/race_winner.jpg',
      'description': 'Completed race in 11.2 seconds.',
    },
    {
      'sport': '100m Race',
      'position': '🥈 Second',
      'team': 'Bilal Ahmed',
      'members': 'Individual - Computer Science',
      'image': 'assets/race_winner.jpg',
      'description': 'Completed race in 11.5 seconds.',
    },
    {
      'sport': '100m Race',
      'position': '🥉 Third',
      'team': 'Zain Malik',
      'members': 'Individual - Engineering',
      'image': 'assets/race_winner.jpg',
      'description': 'Completed race in 11.8 seconds.',
    },
    {
      'sport': 'Table Tennis',
      'position': '🥇 Gold Medal',
      'team': 'Sara Khan',
      'members': 'Individual - Media Studies',
      'image': 'assets/tabletennis_winner.jpg',
      'description': 'Won women\'s singles championship.',
    },
    {
      'sport': 'Basketball',
      'position': '🏆 Champions',
      'team': 'Medical Sciences',
      'members': 'Team of 12 players',
      'image': 'assets/basketball_winners.jpg',
      'description': 'Won the inter-department basketball tournament.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Winners Gallery'),
        backgroundColor: const Color(0xFF00A99D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sports Winners 2024',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Celebrating the achievements of our talented athletes',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            // Cricket Winners Section
            _buildWinnerSection(
              title: 'Cricket Champions 2024 🏏',
              winner: winners[0],
            ),
            
            const SizedBox(height: 30),
            
            // All Winners List
            const Text(
              'All Winners',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 15),
            
            ...winners.map((winner) => _buildWinnerCard(winner)).toList(),
            
            const SizedBox(height: 30),
            
            // Trophy Room Info
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
                      Icon(Icons.emoji_events, color: Color(0xFF00A99D)),
                      SizedBox(width: 8),
                      Text(
                        'Trophy Room',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'All winning trophies and medals are displayed in the University Sports Trophy Room. Visitors are welcome during office hours.',
                    style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 92, 92, 92)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Location: Sports Complex, Ground Floor',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerSection({required String title, required Map<String, dynamic> winner}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A99D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00A99D).withOpacity(0.3)),
                ),
                child: const Icon(Icons.emoji_events, size: 50, color: Color(0xFF00A99D)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      winner['position'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      winner['team'],
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      winner['members'],
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      winner['description'],
                      style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 97, 97, 97), fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCard(Map<String, dynamic> winner) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF00A99D).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              _getPositionEmoji(winner['position']),
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          winner['sport'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              winner['position'],
              style: const TextStyle(fontSize: 14, color: Color(0xFF00A99D), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              winner['team'],
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  String _getPositionEmoji(String position) {
    if (position.contains('🏆')) return '🏆';
    if (position.contains('🥇')) return '🥇';
    if (position.contains('🥈')) return '🥈';
    if (position.contains('🥉')) return '🥉';
    return '🎖️';
  }
}