import 'package:flutter/material.dart';

class IndoorSportsScreen extends StatelessWidget {
  const IndoorSportsScreen({super.key});

  final List<Map<String, dynamic>> indoorSports = const [
    {
      'name': 'Table Tennis 🏓',
      'icon': Icons.sports_tennis,
      'description': 'Fast-paced racquet sport played on a table.',
      'venue': 'Indoor Sports Hall',
      'equipment': 'Table Tennis Racket, Ball, Table',
    },
    {
      'name': 'Badminton (Indoor)',
      'icon': Icons.sports_tennis,
      'description': 'Racquet sport played indoors with shuttlecock.',
      'venue': 'Indoor Badminton Court',
      'equipment': 'Racquet, Shuttlecock, Net',
    },
    {
      'name': 'Chess ♟️',
      'icon': Icons.casino,
      'description': 'Strategy board game for two players.',
      'venue': 'Common Room',
      'equipment': 'Chess Board, Pieces',
    },
    {
      'name': 'Carrom Board',
      'icon': Icons.games,
      'description': 'Tabletop game of finger flicking disks.',
      'venue': 'Common Room',
      'equipment': 'Carrom Board, Striker, Coins',
    },
    {
      'name': 'Snooker/Billiards 🎱',
      'icon': Icons.sports,
      'description': 'Cue sport played on a rectangular table.',
      'venue': 'Games Room',
      'equipment': 'Cue Stick, Balls, Table',
    },
    {
      'name': 'Squash',
      'icon': Icons.sports,
      'description': 'Racquet sport played by two players in a four-walled court.',
      'venue': 'Squash Court',
      'equipment': 'Squash Racquet, Ball',
    },
    {
      'name': 'Gymnastics',
      'icon': Icons.directions_run,
      'description': 'Sport involving exercises requiring balance, strength, flexibility.',
      'venue': 'Gymnastics Hall',
      'equipment': 'Mats, Parallel Bars, Rings',
    },
    {
      'name': 'Weight Lifting',
      'icon': Icons.fitness_center,
      'description': 'Sport in which athletes lift heavy weights.',
      'venue': 'Gymnasium',
      'equipment': 'Barbells, Dumbbells, Weight Plates',
    },
    {
      'name': 'Arm Wrestling',
      'icon': Icons.fitness_center,
      'description': 'Sport with two participants competing to pin each other\'s arm.',
      'venue': 'Gymnasium',
      'equipment': 'Arm Wrestling Table',
    },
    {
      'name': 'E-Gaming/Esports 🎮',
      'icon': Icons.videogame_asset,
      'description': 'Organized video gaming competitions.',
      'venue': 'Computer Lab/Gaming Zone',
      'equipment': 'Computers, Consoles, Headsets',
    },
    {
      'name': 'Darts',
      'icon': Icons.games,
      'description': 'Target sport played by throwing small missiles.',
      'venue': 'Common Room',
      'equipment': 'Dartboard, Darts',
    },
    {
      'name': 'Board Games',
      'icon': Icons.games,
      'description': 'Ludo, Scrabble, and other board games.',
      'venue': 'Common Room',
      'equipment': 'Board Games Pieces',
    },
    {
      'name': 'Yoga',
      'icon': Icons.self_improvement,
      'description': 'Group of physical, mental, and spiritual practices.',
      'venue': 'Yoga Hall',
      'equipment': 'Yoga Mats',
    },
    {
      'name': 'Taekwondo/Karate 🥋',
      'icon': Icons.sports_martial_arts,
      'description': 'Korean martial art involving punching and kicking techniques.',
      'venue': 'Martial Arts Hall',
      'equipment': 'Uniform, Protective Gear',
    },
    {
      'name': 'Wrestling (Indoor)',
      'icon': Icons.sports_mma,
      'description': 'Combat sport involving grappling techniques.',
      'venue': 'Wrestling Mat Hall',
      'equipment': 'Wrestling Mat, Uniform',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Indoor Sports'),
        backgroundColor: const Color(0xFF00A99D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Indoor Sports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
            ),
            const SizedBox(height: 8),
            const Text(
              'These sports are played indoors in halls or common rooms.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: indoorSports.length,
                itemBuilder: (context, index) {
                  final sport = indoorSports[index];
                  return Card(
                    elevation: 3,
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
                        child: Icon(sport['icon'], color: const Color(0xFF00A99D), size: 28),
                      ),
                      title: Text(
                        sport['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            sport['description'],
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                sport['venue'],
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.sports, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                sport['equipment'],
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}