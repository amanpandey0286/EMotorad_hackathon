import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Ride {
  final int id;
  final String startLocation;
  final String endLocation;
  final String image;
  bool bookmarked;

  Ride({
    required this.id,
    required this.startLocation,
    required this.endLocation,
    required this.image,
    this.bookmarked = false,
  });
}

class RideHistoryScreen extends StatefulWidget {
  @override
  _RideHistoryScreenState createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  List<Ride> rides = [];
  ScrollController _scrollController = ScrollController();
  bool showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _fetchRides();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >= 100 &&
        !_scrollController.position.outOfRange) {
      setState(() {
        showScrollToTopButton = true;
      });
    } else {
      setState(() {
        showScrollToTopButton = false;
      });
    }
  }

  Future<void> _fetchRides() async {
    try {
      final response = await http.get(
        Uri.parse('http://flutter.dev.emotorad.com/get_routes'),
        headers: {
          'Authorization': 'amanpy.8756@gmail.com',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        List<Ride> fetchedRides = [];

        responseData.forEach((rideData) {
          Ride ride = Ride(
            id: rideData['id'],
            startLocation: rideData['start_loc'],
            endLocation: rideData['end_loc'],
            image: rideData['image'],
            bookmarked: rideData['bookmarked'] ?? false,
          );
          fetchedRides.add(ride);
        });

        setState(() {
          rides = fetchedRides;
        });
      } else {
        throw Exception('Failed to fetch rides');
      }
    } catch (error) {
      print('Error fetching rides: $error');
    }
  }

  void _toggleBookmark(Ride ride) {
    setState(() {
      ride.bookmarked = !ride.bookmarked;
    });
    _updateBookmarkStatus(ride.id, ride.bookmarked);
  }

  Future<void> _updateBookmarkStatus(int rideId, bool isBookmarked) async {
    try {
      final response = await http.put(
        Uri.parse('http://flutter.dev.emotorad.com/bookmark_route/$rideId'),
        headers: {
          'Authorization': 'amanpy.8756@gmail.com',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'bookmarked': isBookmarked}),
      );
    } catch (error) {
      print('Error updating bookmark status: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Suggested Routes',
          style: TextStyle(color: Colors.black),
        ),
      ),
      floatingActionButton: showScrollToTopButton
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              },
              child: Icon(Icons.arrow_upward),
            )
          : null,
      body: ListView.builder(
        controller: _scrollController,
        itemCount: rides.length,
        itemBuilder: (context, index) {
          return RideCard(
            ride: rides[index],
            onBookmarkPressed: () {
              _toggleBookmark(rides[index]);
            },
          );
        },
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback onBookmarkPressed;

  const RideCard({
    Key? key,
    required this.ride,
    required this.onBookmarkPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        child: Column(children: [
          Image.network(ride.image),
          Card(
            child: Row(
              children: [
                Column(
                  children: [
                    Icon(Icons.pin_drop, color: Colors.greenAccent),
                    Icon(Icons.pin_drop, color: Colors.redAccent),
                  ],
                ),
                SizedBox(
                  width: 20.0,
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Text(ride.startLocation),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Text(ride.endLocation),
                    ),
                  ],
                ),
                Expanded(child: Container()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: IconButton(
                    icon: Icon(
                      ride.bookmarked
                          ? Icons.favorite
                          : Icons.favorite_border_outlined,
                      color: ride.bookmarked ? Colors.red : null,
                    ),
                    onPressed: onBookmarkPressed,
                  ),
                ),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
