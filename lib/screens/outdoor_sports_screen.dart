import 'package:flutter/material.dart';

class OutdoorSportsScreen extends StatelessWidget {
  const OutdoorSportsScreen({super.key});

  final List<Map<String, dynamic>> outdoorSports = const [
    {
      'name': 'Cricket 🏏',
      'icon': Icons.sports_cricket,
      'description': 'Team sport played between two teams of eleven players.',
      'venue': 'Main Cricket Ground',
      'equipment': 'Bat, Ball, Stumps, Pads, Helmet',
    },
    {
      'name': 'Football ⚽',
      'icon': Icons.sports_soccer,
      'description': 'Played between two teams of eleven players with a spherical ball.',
      'venue': 'Football Stadium',
      'equipment': 'Football, Goal Posts, Shin Guards',
    },
    {
      'name': 'Hockey 🏑',
      'icon': Icons.sports_hockey,
      'description': 'Team sport played on grass or artificial turf.',
      'venue': 'Hockey Field',
      'equipment': 'Hockey Stick, Ball, Protective Gear',
    },
    {
      'name': 'Athletics',
      'icon': Icons.directions_run,
      'description': 'Various track and field events including races, jumps, throws.',
      'venue': 'Athletics Track',
      'equipment': 'Running Spikes, Shot Put, Javelin',
    },
    {
      'name': 'Kabaddi',
      'icon': Icons.sports_kabaddi,
      'description': 'Contact team sport originated in ancient India.',
      'venue': 'Kabaddi Court',
      'equipment': 'Court Markings',
    },
    {
      'name': 'Badminton (Outdoor)',
      'icon': Icons.sports_tennis,
      'description': 'Racquet sport played using racquets to hit a shuttlecock.',
      'venue': 'Outdoor Badminton Courts',
      'equipment': 'Racquet, Shuttlecock, Net',
    },
    {
      'name': 'Basketball 🏀',
      'icon': Icons.sports_basketball,
      'description': 'Team sport played on a rectangular court.',
      'venue': 'Basketball Court',
      'equipment': 'Basketball, Hoop',
    },
    {
      'name': 'Volleyball 🏐',
      'icon': Icons.sports_volleyball,
      'description': 'Team sport in which two teams hit a ball over a net.',
      'venue': 'Volleyball Court',
      'equipment': 'Volleyball, Net',
    },
    {
      'name': 'Handball',
      'icon': Icons.sports_handball,
      'description': 'Team sport played by hitting a ball with hands.',
      'venue': 'Handball Court',
      'equipment': 'Handball, Goal Posts',
    },
    {
      'name': 'Baseball/Softball',
      'icon': Icons.sports_baseball,
      'description': 'Bat-and-ball sport played between two teams.',
      'venue': 'Baseball Diamond',
      'equipment': 'Bat, Ball, Gloves, Bases',
    },
    {
      'name': 'Tennis (Lawn) 🎾',
      'icon': Icons.sports_tennis,
      'description': 'Racquet sport played individually or between two teams.',
      'venue': 'Tennis Courts',
      'equipment': 'Tennis Racquet, Tennis Balls, Net',
    },
    {
      'name': 'Throwball',
      'icon': Icons.sports,
      'description': 'Non-contact ball sport played across a net.',
      'venue': 'Throwball Court',
      'equipment': 'Throwball, Net',
    },
    {
      'name': 'Futsal (Outdoor)',
      'icon': Icons.sports_soccer,
      'description': 'Indoor variant of association football.',
      'venue': 'Futsal Court',
      'equipment': 'Futsal Ball, Goals',
    },
    {
      'name': 'Tug of War',
      'icon': Icons.fitness_center,
      'description': 'Sport that pits two teams against each other in a test of strength.',
      'venue': 'Open Ground',
      'equipment': 'Rope, Markings',
    },
    {
      'name': 'Cycling/Road Race',
      'icon': Icons.directions_bike,
      'description': 'Sport of racing bicycles on roads.',
      'venue': 'University Campus Roads',
      'equipment': 'Bicycle, Helmet',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outdoor Sports'),
        backgroundColor: const Color(0xFF00A99D),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Outdoor Sports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
            ),
            const SizedBox(height: 8),
            const Text(
              'These sports are played in open grounds or outdoor areas.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: outdoorSports.length,
                itemBuilder: (context, index) {
                  final sport = outdoorSports[index];
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