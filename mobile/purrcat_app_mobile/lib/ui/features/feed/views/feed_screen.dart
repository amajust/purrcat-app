import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/models/feed_model.dart';
import '../../../../ui/core/theme.dart';
import '../../../../ui/shared/post_card.dart';



class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<String> _stories = [
    'https://i.pravatar.cc/150?img=1',
    'https://i.pravatar.cc/150?img=2',
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=4',
    'https://i.pravatar.cc/150?img=5',
  ];

  final List<Post> _posts = [
    Post(
      id: '1',
      userId: '1',
      userName: 'Dr. Sarah Whiskers',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      content: 'Beautiful day at the park! My cat Luna loves the sunshine 🌞',
      images: ['https://picsum.photos/400/500?random=1'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 1284,
      comments: 45,
      shares: 12,
      isLiked: false,
    ),
    Post(
      id: '2',
      userId: '2',
      userName: 'Tommy Paws',
      userAvatar: 'https://i.pravatar.cc/150?img=2',
      content: 'Just adopted this cute kitten! Meet Milo 🐱 #kitten #adoptdontshop',
      images: ['https://picsum.photos/400/500?random=2'],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      likes: 2341,
      comments: 89,
      shares: 23,
      isLiked: false,
    ),
    Post(
      id: '3',
      userId: '3',
      userName: 'Whiskers & Co',
      userAvatar: 'https://i.pravatar.cc/150?img=3',
      content: 'Cat grooming tips for summer! Keep your feline friend cool and comfortable 💕',
      images: ['https://picsum.photos/400/500?random=3'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      likes: 892,
      comments: 34,
      shares: 8,
      isLiked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Top App Bar
          SliverAppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            title: Text(
              'PurrCat',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: brandPink,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: headingColor),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: headingColor),
                onPressed: () {},
              ),
            ],
            pinned: true,
          ),

          // Stories Section
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: _stories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Add Story Button
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          DottedBorder(
                            color: brandPink,
                            strokeWidth: 2,
                            dashPattern: const [6, 3],
                            radius: const Radius.circular(50),
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: backgroundColor,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: brandPink,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ADD',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: bodyColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // User Story Item
                  final storyIndex = index - 1;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: brandPink,
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: CachedNetworkImageProvider(
                              _stories[storyIndex],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'USER${storyIndex + 1}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: bodyColor,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Posts Section
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return PostCard(
                  post: _posts[index],
                  onLike: () {
                    setState(() {
                      _posts[index].isLiked = !_posts[index].isLiked;
                      _posts[index].likes += _posts[index].isLiked ? 1 : -1;
                    });
                  },
                );
              },
              childCount: _posts.length,
            ),
          ),
        ],
      ),

      // FAB
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 40),
        child: FloatingActionButton(
          onPressed: () => context.push('/feed/create'),
          backgroundColor: brandPink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

