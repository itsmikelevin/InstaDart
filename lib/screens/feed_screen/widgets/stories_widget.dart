import 'package:flutter/material.dart';
import 'package:instagram/models/models.dart';
import 'package:instagram/screens/feed_screen/widgets/story_circle.dart';
import 'package:instagram/services/services.dart';
import '../../../models/user_model.dart';

class StoriesWidget extends StatefulWidget {
  final List<User> users;
  final String currentUserId;
  final Function goToCameraScreen;
  const StoriesWidget(this.users, this.currentUserId, this.goToCameraScreen);

  @override
  _StoriesWidgetState createState() => _StoriesWidgetState();
}

class _StoriesWidgetState extends State<StoriesWidget> {
  bool _isLoading = false;
  List<User> _followingUsers = [];
  List<Story> _stories = [];

  @override
  void initState() {
    super.initState();
    _getStories();
  }

  Future<void> _getStories() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    List<User> followingUsersWithStories = [];

    List<Story> stories = [];
    for (User user in widget.users) {
      List<Story> userStories =
          await StoriesService.getStoriesByUserId(user.id, true);
      if (!mounted) return;

      if (userStories != null && userStories.isNotEmpty) {
        followingUsersWithStories.add(user);

        for (Story story in userStories) {
          stories.add(story);
        }
      } else {
        if (widget.currentUserId == user.id) {
          Story story = Story(
            authorId: widget.currentUserId,
            views: {},
          );
          followingUsersWithStories.insert(0, user);
          stories.insert(0, story);
        } else {
          // Story story = Story(authorId: widget.currentUserId);
          // followingUsersWithStories.insert(0, user);
          // stories.insert(0, story);
        }
      }
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _followingUsers = followingUsersWithStories;
      _stories = stories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_isLoading
        ? GestureDetector(
            onTap: () {},
            child: Container(
                height: 88.0,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(left: 5.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: _followingUsers.length,
                  itemBuilder: (BuildContext context, int index) {
                    User user = _followingUsers[index];
                    List<Story> userStories = _stories
                        .where((Story story) => story.authorId == user.id)
                        .toList();

                    return StoryCircle(
                      currentUserId: widget.currentUserId,
                      user: user,
                      userStories: userStories,
                      goToCameraScreen: widget.goToCameraScreen,
                    );
                  },
                )),
          )
        : Container(
            height: 88,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
