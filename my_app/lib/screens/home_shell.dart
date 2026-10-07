import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_repository.dart';
import '../data/sample_opportunities.dart';
import '../models/opportunity.dart';
import '../widgets/join_confirmation.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/header.dart';
import '../widgets/sheets/area_picker_sheet.dart';
import '../widgets/sheets/invite_sheet.dart';
import '../widgets/sheets/opportunity_details_sheet.dart';
import '../widgets/sheets/post_opportunity_sheet.dart';
import '../widgets/sheets/rewards_sheet.dart';
import 'discover_screen.dart';
import 'edit_info_screen.dart';
import 'map_screen.dart';
import 'my_page_screen.dart';

class HomeShell extends StatefulWidget {
  final bool connected;
  const HomeShell({super.key, this.connected = false});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  FirebaseRepository? repository;
  final List<StreamSubscription<dynamic>> subscriptions = [];
  bool loading = false, saving = false;
  String? loadError;
  void watch<T>(Stream<T> stream, void Function(T) apply) {
    subscriptions.add(stream.listen((value) {
      if (mounted) setState(() => apply(value));
    }, onError: (Object e) {
      if (mounted) {
        setState(() {
          loading = false;
          loadError =
              'Could not load your data. Check connection and Firebase rules.';
        });
      }
    }));
  }

  void connect() {
    for (final s in subscriptions) {
      s.cancel();
    }
    subscriptions.clear();
    repository = FirebaseRepository();
    repository!.ensureProfile().catchError((Object e) {
      if (mounted) {
        setState(() => loadError =
            'Could not initialize your profile. Check Firebase rules and retry.');
      }
    });
    loading = true;
    loadError = null;
    watch(repository!.events(), (items) {
      opportunities = items;
      loading = false;
    });
    watch(repository!.profile(), (value) => profile = value);
    watch(repository!.membership('favorites'), (value) => favorites = value);
    watch(repository!.membership('joined'), (value) => joined = value);
  }

  Future<void> perform(Future<void> Function() action,
      {VoidCallback? onSuccess}) async {
    if (saving) return;
    setState(() => saving = true);
    try {
      await action();
      if (mounted) onSuccess?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save changes: $e')));
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  bool get canWrite {
    if (widget.connected) return true;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Preview mode: connect Firebase to save changes.')));
    return false;
  }

  final searchController = TextEditingController();

  List<Opportunity> opportunities = List.of(sampleOpportunities);
  Set<String> favorites = {};
  Set<String> joined = {};
  Set<String> posted = {};
  String category = 'All';
  String area = 'Majorna';
  int navIndex = 0;
  ProfileInfo profile = const ProfileInfo(
      name: 'Linnea Mårtensson', location: 'Gothenburg, Sweden');

  @override
  void initState() {
    super.initState();
    if (widget.connected) {
      opportunities = [];
      profile = const ProfileInfo(name: 'Member', location: '');
      connect();
    }
  }

  Future<void> _editProfile() async {
    if (!widget.connected) {
      final info = await Navigator.push<ProfileInfo>(context,
          MaterialPageRoute(builder: (_) => EditInfoScreen(profile: profile)));
      if (info != null && mounted) setState(() => profile = info);
      return;
    }
    await Navigator.push<ProfileInfo>(
        context,
        MaterialPageRoute(
            builder: (_) => EditInfoScreen(
                profile: profile, onSave: repository!.saveProfile)));
  }

  @override
  void dispose() {
    for (final s in subscriptions) {
      s.cancel();
    }
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
              ? (opportunity.startsAt == null
                  ? opportunity.date == 'Today'
                  : DateUtils.isSameDay(opportunity.startsAt, DateTime.now()))
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
                    padding: const EdgeInsets.fromLTRB(AppSpacing.s20,
                        AppSpacing.s12, AppSpacing.s20, AppSpacing.s100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        AppHeader(
                          isMyPage: navIndex == 3,
                          area: area,
                          firstName: profile.firstName,
                          onArea: _showAreaPicker,
                        ),
                        const SizedBox(height: 2),
                        if (!widget.connected)
                          const Padding(
                              padding: EdgeInsets.all(AppSpacing.s8),
                              child: Text(
                                  'Preview mode · Firebase is not connected. See FIREBASE_SETUP.md.')),
                        if (widget.connected)
                          Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                  onPressed: saving
                                      ? null
                                      : () => perform(() =>
                                          FirebaseAuth.instance.signOut()),
                                  child: const Text('Sign out'))),
                        if (saving || loading) const LinearProgressIndicator(),
                        if (loadError != null)
                          Column(children: [
                            Text(loadError!),
                            TextButton(
                                onPressed: () => setState(connect),
                                child: const Text('Retry'))
                          ]),
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
          area: area,
          onOpen: _showDetails,
        );
      case 3:
        return MyPageScreen(
          opportunities: opportunities,
          joined: joined.intersection(opportunities.map((e) => e.id).toSet()),
          favorites:
              favorites.intersection(opportunities.map((e) => e.id).toSet()),
          posted: widget.connected
              ? opportunities
                  .where((e) => e.ownerId == repository!.uid)
                  .map((e) => e.id)
                  .toSet()
              : posted,
          profile: profile,
          onEditInfo: _editProfile,
          onOpen: _showDetails,
          onFavorite: _toggleFavorite,
          onRewards: _showRewards,
          onPost: _showPost,
        );
      case 0:
      default:
        return DiscoverScreen(
          opportunities: filtered,
          favorites:
              favorites.intersection(opportunities.map((e) => e.id).toSet()),
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

  void _toggleFavorite(String id) {
    if (!canWrite) return;
    perform(() =>
        repository!.setMembership('favorites', id, !favorites.contains(id)));
  }

  void _showDetails(Opportunity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => OpportunityDetailsSheet(
        item: item,
        onEdit: widget.connected && item.ownerId == repository!.uid
            ? () {
                Navigator.pop(context);
                _showPost(item);
              }
            : null,
        onDelete: widget.connected && item.ownerId == repository!.uid
            ? () async {
                Navigator.pop(context);
                final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                            title: const Text('Delete this event?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(c, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () => Navigator.pop(c, true),
                                  child: const Text('Delete'))
                            ]));
                if (confirmed == true) {
                  perform(() => repository!.deleteEvent(item));
                }
              }
            : null,
        isFavorite: favorites.contains(item.id),
        isJoined: joined.contains(item.id),
        onFavorite: () {
          _toggleFavorite(item.id);
          Navigator.pop(context);
        },
        onJoin: () {
          if (canWrite) {
            final joining = !joined.contains(item.id);
            perform(() => repository!.setMembership('joined', item.id, joining),
                onSuccess:
                    joining ? () => showJoinConfirmation(context) : null);
          }
          Navigator.pop(context);
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
      backgroundColor: AppColors.transparent,
      builder: (_) => InviteSheet(item: item),
    );
  }

  void _showRewards() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => const RewardsSheet(),
    );
  }

  void _showAreaPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => AreaPickerSheet(
        currentArea: area,
        onSelected: (value) => setState(() => area = value),
      ),
    );
  }

  void _showPost([Opportunity? existing]) {
    if (!canWrite) return;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.transparent,
        builder: (_) => PostOpportunitySheet(
            existing: existing,
            newId: repository!.newEventId,
            onSave: (event, photo) =>
                repository!.saveEvent(event, photo, update: existing != null),
            onPublished: (_) {
              if (mounted) {
                setState(() {
                  category = 'All';
                  navIndex = 0;
                });
              }
            }));
  }
}
