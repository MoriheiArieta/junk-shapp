import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:junk_shapp/views/screens/register_new_staff_screen.dart';

class NonOwnerPersonnelScreen extends StatefulWidget {
  final dynamic junkShopData;

  const NonOwnerPersonnelScreen({super.key, this.junkShopData});

  @override
  State<NonOwnerPersonnelScreen> createState() =>
      _NonOwnerPersonnelScreenState();
}

class _NonOwnerPersonnelScreenState extends State<NonOwnerPersonnelScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier("");

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchQueryNotifier.value = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchQueryNotifier.dispose();
    super.dispose();
  }

  Stream<DocumentSnapshot> get _junkShopStream {
    return _firestore
        .collection('junk_shops')
        .doc(widget.junkShopData['junkShopId'])
        .snapshots();
  }

  Stream<List<Map<String, dynamic>>> _fetchPersonnelStream(
      List<dynamic> staffIds) async* {
    if (staffIds.isEmpty) {
      yield [];
      return;
    }

    yield* _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: staffIds)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xffff6600),
        centerTitle: true,
        title: Text(
          widget.junkShopData['junkShopName'] ?? 'Personnel',
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _junkShopStream,
        builder: (context, junkShopSnapshot) {
          if (!junkShopSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final staffIds =
              List<dynamic>.from(junkShopSnapshot.data!['junkShopStaff'] ?? []);

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _fetchPersonnelStream(staffIds),
            builder: (context, personnelSnapshot) {
              if (!personnelSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final personnelList = personnelSnapshot.data ?? [];

              return Column(
                children: [
                  const Divider(
                    thickness: 1,
                    height: 1,
                    color: Colors.deepOrange,
                  ),
                  Container(
                    width: screenWidth,
                    decoration: const BoxDecoration(color: Color(0xfffe6600)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Personnel",
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: screenWidth * 0.72,
                            height: screenHeight * 0.04,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                hintText: "Search personnel...",
                                hintStyle: GoogleFonts.quicksand(
                                    color: Colors.white70, fontSize: 14),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: personnelList.isEmpty
                        ? const Center(
                            child: Text(
                              "No personnel found",
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : ValueListenableBuilder<String>(
                            valueListenable: _searchQueryNotifier,
                            builder: (context, searchQuery, _) {
                              final filteredPersonnel = searchQuery.isEmpty
                                  ? personnelList
                                  : personnelList.where((personnel) {
                                      final fullName =
                                          (personnel['fullName'] ?? '')
                                              .toString()
                                              .toLowerCase();
                                      return fullName
                                          .contains(searchQuery.toLowerCase());
                                    }).toList();

                              return filteredPersonnel.isEmpty
                                  ? const Center(
                                      child: Text("Personnel not found"),
                                    )
                                  : ListView.builder(
                                      itemCount: filteredPersonnel.length,
                                      itemBuilder: (context, index) {
                                        final personnel =
                                            filteredPersonnel[index];
                                        return ListTile(
                                          shape: const Border(
                                            bottom: BorderSide(),
                                          ),
                                          leading: CachedNetworkImage(
                                            imageUrl:
                                                personnel['profileImage'] ?? '',
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    CircleAvatar(
                                              backgroundImage: imageProvider,
                                              radius: 30,
                                            ),
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const CircleAvatar(
                                              radius: 20,
                                              child: Icon(Icons.person),
                                            ),
                                          ),
                                          title: Text(
                                            personnel['fullName'] ?? 'Unknown',
                                            style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            "Role: ${personnel['staffRole'] ?? 'Unknown'}",
                                            style: GoogleFonts.quicksand(),
                                          ),
                                        );
                                      },
                                    );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
