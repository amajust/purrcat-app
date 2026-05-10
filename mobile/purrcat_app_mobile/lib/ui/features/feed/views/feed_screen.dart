import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

import '../../../../data/models/feed_model.dart';
import '../../../../data/services/firestore_service.dart';
import '../../../../ui/core/theme.dart';
import '../../../../ui/shared/app_logo.dart';
import '../../../../ui/shared/post_card.dart';
import '../../../../ui/shared/login_modal.dart';

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

  StreamSubscription<List<Post>>? _postsSub;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _postsSub = FirestoreService().getPosts().listen((posts) {
      if (mounted) {
        setState(() => _posts = posts);
      }
    });
  }

  @override
  void dispose() {
    _postsSub?.cancel();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    final completer = Completer<void>();
    FirestoreService().getPosts().first.then((posts) {
      if (mounted) {
        setState(() => _posts = posts);
      }
      completer.complete();
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: brandPink,
      child: CustomScrollView(
        slivers: [
          // Top App Bar
          SliverAppBar(
            backgroundColor: backgroundColor,
            elevation: 0,
            title: const AppLogo(),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: headingColor),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: headingColor,
                ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: _stories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
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
                  onLoginRequired: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const LoginModal(),
                    );
                  },
                );
              },
              childCount: _posts.length,
            ),
          ),
        ],
      ),
    );
  }
}
