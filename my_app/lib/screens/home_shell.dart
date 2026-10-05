import 'package:flutter/material.dart';
import '../data/sample_opportunities.dart';
import '../models/opportunity.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/header.dart';
import '../widgets/sheets/area_picker_sheet.dart';
import '../widgets/sheets/invite_sheet.dart';
import '../widgets/sheets/opportunity_details_sheet.dart';
import '../widgets/sheets/post_opportunity_sheet.dart';
import '../widgets/sheets/rewards_sheet.dart';
import 'discover_screen.dart';
import 'map_screen.dart';
import 'my_page_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final searchController = TextEditingController();

  List<Opportunity> opportunities = List.of(sampleOpportunities);
  Set<int> favorites = {3};
  Set<int> joined = {2};
  Set<int> posted = {};
  String category = 'All';
  String area = 'Majorna';
  int navIndex = 0;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Opportunity> get filtered {
    final query = searchController.text.toLowerCase();

    return opportunities.where((opportunity) {
      final matchesSearch = '${opportunity.title} '
              '${opportunity.organization} '
              '${opportunity.place}'
          .toLowerCase()
          .contains(query);

      final matchesCategory = category == 'All'
          ? true
          : category == 'Today'
              ? opportunity.date == 'Today'
              : opportunity.category == category;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        AppHeader(
                          isMyPage: navIndex == 3,
                          area: area,
                          onArea: _showAreaPicker,
                        ),
                        const SizedBox(height: 2),
                        _currentScreen(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            AppBottomNav(
              index: navIndex,
              onTap: _onNavigation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _currentScreen() {
    switch (navIndex) {
      case 1:
        return MapScreen(
          opportunities: filtered,
          onOpen: _showDetails,
        );
      case 3:
        return MyPageScreen(
          opportunities: opportunities,
          joined: joined,
          favorites: favorites,
          posted: posted,
          onOpen: _showDetails,
          onFavorite: _toggleFavorite,
          onRewards: _showRewards,
          onPost: _showPost,
        );
      case 0:
      default:
        return DiscoverScreen(
          opportunities: filtered,
          favorites: favorites,
          category: category,
          searchController: searchController,
          onSearch: (_) => setState(() {}),
          onCategory: (value) => setState(() => category = value),
          onOpen: _showDetails,
          onFavorite: _toggleFavorite,
          onImpact: () => setState(() => navIndex = 3),
          onRewards: _showRewards,
        );
    }
  }

  void _onNavigation(int index) {
    if (index == 2) {
      _showPost();
    } else {
      setState(() => navIndex = index);
    }
  }

  void _toggleFavorite(int id) {
    setState(() {
      favorites.contains(id)
          ? favorites.remove(id)
          : favorites.add(id);
    });
  }

  void _showDetails(Opportunity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OpportunityDetailsSheet(
        item: item,
        isFavorite: favorites.contains(item.id),
        isJoined: joined.contains(item.id),
        onFavorite: () {
          _toggleFavorite(item.id);
          Navigator.pop(context);
        },
        onJoin: () {
          setState(() {
            joined.contains(item.id)
                ? joined.remove(item.id)
                : joined.add(item.id);
          });
        },
        onInvite: () {
          Navigator.pop(context);
          _showInvite(item);
        },
      ),
    );
  }

  void _showInvite(Opportunity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InviteSheet(item: item),
    );
  }

  void _showRewards() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RewardsSheet(),
    );
  }

  void _showAreaPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AreaPickerSheet(
        currentArea: area,
        onSelected: (value) => setState(() => area = value),
      ),
    );
  }

  void _showPost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostOpportunitySheet(
        onPublished: (opportunity) {
          setState(() {
            opportunities.insert(0, opportunity);
            posted.add(opportunity.id);
            category = 'All';
            navIndex = 0;
          });

          Future.delayed(
            const Duration(milliseconds: 150),
            () => _showDetails(opportunity),
          );
        },
      ),
    );
  }
}
