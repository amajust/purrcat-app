import 'package:flutter/material.dart';

import '../models/feed_model.dart';
import '../components/post_card.dart';
import '../components/pet_chip.dart';
import '../components/feed_header.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // Mock data for demonstration
  final List<Post> _posts = [
    Post(
      id: '1',
      userId: 'user1',
      userName: 'Siska',
      userAvatar: '',
      content: 'Kucingku baru saja melahirkan 4 anak! Lucu banget semua 🐱❤️',
      images: [],
      likes: 124,
      comments: 23,
      shares: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isLiked: false,
    ),
    Post(
      id: '2',
      userId: 'user2',
      userName: 'Pak Iwan',
      userAvatar: '',
      content: 'Persian kitten available! Umur 3 bulan, sudah vaksin. Harga nego.',
      images: [],
      likes: 89,
      comments: 15,
      shares: 12,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isLiked: true,
    ),
    Post(
      id: '3',
      userId: 'user3',
      userName: 'Bimo',
      userAvatar: '',
      content: 'Tips grooming kucing di rumah: Gunakan sikat lembut dan lakukan secara rutin!',
      images: [],
      likes: 256,
      comments: 34,
      shares: 28,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isLiked: false,
    ),
  ];

  int _selectedPetIndex = 0;

  final List<PetStory> _petStories = [
    PetStory(name: 'Semua', color: const Color(0xFFA03A57)),
    PetStory(name: 'Lucy', color: Colors.blue),
    PetStory(name: 'Max', color: Colors.green),
    PetStory(name: 'Bella', color: Colors.purple),
    PetStory(name: 'Charlie', color: Colors.pink),
    PetStory(name: 'Luna', color: Colors.teal),
    PetStory(name: 'Oscar', color: Colors.amber),
    PetStory(name: 'Milo', color: Colors.red),
  ];

  void _toggleLike(int index) {
    setState(() {
      final post = _posts[index];
      _posts[index] = post.copyWith(
        likes: post.isLiked ? post.likes - 1 : post.likes + 1,
        isLiked: !post.isLiked,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FeedHeader(
        title: 'PurrGram',
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFA03A57),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.pets,
            color: Colors.white,
            size: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Pet Chip Row (Story section)
          Container(
            height: 90,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _petStories.length,
              itemBuilder: (context, index) {
                return PetChip(
                  name: _petStories[index].name,
                  color: _petStories[index].color,
                  isSelected: index == _selectedPetIndex,
                  onTap: () {
                    setState(() {
                      _selectedPetIndex = index;
                    });
                  },
                );
              },
            ),
          ),
          // Divider
          const Divider(height: 1, color: Colors.grey),
          // Feed List
          Expanded(
            child: ListView.builder(
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  post: _posts[index],
                  index: index,
                  onLike: () => _toggleLike(index),
                  onComment: () {},
                  onShare: () {},
                  onSave: () {},
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFA03A57),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA03A57).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to create post
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}
