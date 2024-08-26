import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ink_wander/models/prompts.dart';
import 'package:ink_wander/screens/text_display.dart';
import 'package:ink_wander/widgets/favorite_prompt_tile.dart';

class FavoritesFirestore {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static Future<String> addToFavorites(
      String userId, String promptText, String category) async {
    final prompt = Prompt(
      prompt: promptText,
      category: category,
      userId: userId,
      createdAt: DateTime.now(),
      isFavorite: true,
    );

    final docRef = await firestore.collection('prompts').add(prompt.toMap());
    final generatedId = docRef.id;

    return generatedId;
  }

  Future<QuerySnapshot> getFavoritePrompts(String userId,
      [DocumentSnapshot? startAfter]) {
    Query query = FavoritesFirestore.firestore
        .collection('prompts')
        .where('userId', isEqualTo: userId)
        .where('isFavorite', isEqualTo: true)
        .limit(5);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.get();
  }

  Future<String> _getFullPromptByUser(String userId) async {
    final querySnapshot = await FavoritesFirestore.firestore
        .collection('prompts')
        .where('userId', isEqualTo: userId)
        .where('isFavorite', isEqualTo: true)
        .limit(1) // Limit to 1 document
        .get();

    if (querySnapshot.docs.isEmpty) {
      return ''; // Or return a default value as needed
    }

    final docSnapshot = querySnapshot.docs.first;
    final promptData = docSnapshot.data();

    final fullPrompt = promptData['prompt'] as String;
    return fullPrompt;
  }

  Future<void> deleteFavoritePrompt(BuildContext context, userId) async {
    // Validate user ID presence
    if (userId.isEmpty) {
      throw Exception('Missing user ID');
    }

    try {
      // Build the query based on user ID and favorite flag
      final querySnapshot = await FavoritesFirestore.firestore
          .collection('prompts')
          .where('userId', isEqualTo: userId)
          .where('isFavorite', isEqualTo: true)
          .limit(1)
          .get();

      // Check if any documents were found
      if (querySnapshot.docs.isEmpty) {
        // print('No favorite prompt found for this user.');
        return; // Handle case where no matching prompt is found
      }

      // Get the document snapshot and ID
      final docSnapshot = querySnapshot.docs.first;
      docSnapshot.id;

      // Delete the document
      await docSnapshot.reference.delete();

      // print('Favorite prompt (document ID: $documentId) deleted successfully.');
    } on FirebaseException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
        ),
      );
    }
  }

  Future<void> showFavoritePromptsDialog(
      BuildContext context, bool isDarkMode) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      // Handle case where user is not signed in
      return;
    }

    final fullPrompt = await _getFullPromptByUser(userId);

    if (fullPrompt == '') {
      // Handle case where user has no favorites
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have no favorited prompts yet!'),
        ),
      );
      return;
    }

    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          child: SizedBox(
            width: double.infinity,
            height: 650,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Your Favorites',
                    style: TextStyle(
                      fontSize: 25.0,
                      fontFamily: 'Margarine',
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: FavoritePromptsList(
                    userId: userId,
                    isDarkMode: isDarkMode,
                    fullPrompt: fullPrompt,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    width: 100.0,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? const Color.fromARGB(255, 179, 53, 53)
                            : const Color.fromARGB(255, 230, 19, 19),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}

class FavoritePromptsList extends StatefulWidget {
  final String userId;
  final bool isDarkMode;
  final String fullPrompt;

  const FavoritePromptsList({
    super.key,
    required this.userId,
    required this.isDarkMode,
    required this.fullPrompt,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FavoritePromptsListState createState() => _FavoritePromptsListState();
}

class _FavoritePromptsListState extends State<FavoritePromptsList> {
  final List<Prompt> _favorites = [];
  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMoreFavorites();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      debugPrint('End of scroll reached. Loading more favorites...');
      _loadMoreFavorites();
    }
  }

  Future<void> _loadMoreFavorites() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    final querySnapshot = await FavoritesFirestore()
        .getFavoritePrompts(widget.userId, _lastDocument);

    final newPrompts = querySnapshot.docs.map((doc) {
      final promptData = doc.data() as Map<String, dynamic>;
      final prompt = Prompt.fromMap(promptData);
      final oneLinePrompt = prompt.prompt.substring(0, 120) +
          (prompt.prompt.length > 120 ? '...' : '');
      return prompt.copyWith(prompt: oneLinePrompt);
    }).toList();

    setState(() {
      _favorites.addAll(newPrompts);
      _isLoading = false;
      _hasMore = querySnapshot.docs.length == 5;
      _lastDocument =
          querySnapshot.docs.isNotEmpty ? querySnapshot.docs.last : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _favorites.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _favorites.length) {
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox.shrink();
        }

        final prompt = _favorites[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: FavoritePromptTile(
            prompt: prompt,
            isDarkMode: widget.isDarkMode,
            onTap: () async {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TextDisplay(
                    prompt: widget.fullPrompt,
                    category: prompt.category,
                    isFavorite: prompt.isFavorite,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
