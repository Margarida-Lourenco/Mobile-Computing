import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_repository.dart';
import '../data/sample_opportunities.dart';
import '../models/opportunity.dart';
import '../models/reward_progress.dart';
import '../models/community_impact.dart';
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
import 'notifications_screen.dart';
import '../models/app_notification.dart';
import '../widgets/sheets/attendees_sheet.dart';

class HomeShell extends StatefulWidget {
  final bool connected;
  const HomeShell({super.key, this.connected = false});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  FirebaseRepository? repository;
  final List<StreamSubscription<dynamic>> subscriptions = [];
  Timer? clockRefresh;
  bool loading = false, saving = false;
  String? loadError;
  List<AppNotification> notices = [];
  bool noticesLoading = false;
  int? memberCount;
  CommunityImpact? get communityImpact => !widget.connected ||
          loading ||
          loadError != null
      ? null
      : CommunityImpact.fromEvents(opportunities, memberCount, DateTime.now());
  String? impactStatus = 'Connect Firebase to view community totals.';
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
    _initializeMember();
    loading = true;
    loadError = null;
    memberCount = null;
    impactStatus = 'Loading community totals…';
    subscriptions.add(repository!.memberCount().listen((value) {
      if (mounted) {
        setState(() {
          memberCount = value;
          impactStatus =
              value == null ? 'Member count is being prepared.' : null;
        });
      }
    }, onError: (Object error) {
      if (mounted) {
        setState(() {
          memberCount = null;
          impactStatus = 'Member count unavailable. Please retry.';
        });
      }
    }));
    watch(repository!.events(), (items) {
      opportunities = items;
      loading = false;
    });
    watch(repository!.profile(), (value) => profile = value);
    watch(repository!.membership('favorites'), (value) => favorites = value);
    watch(repository!.membership('joined'), (value) => joined = value);
    noticesLoading = true;
    watch(repository!.notifications(), (value) {
      notices = value;
      noticesLoading = false;
    });
  }

  Future<void> _initializeMember() async {
    final store = repository!;
    try {
      await store.ensureProfile();
    } catch (error) {
      if (mounted) {
        setState(
            () => loadError = 'Could not load your profile. Please retry.');
      }
      return;
    }
    try {
      await store.registerMember();
    } catch (error) {
      // A stats permission/network problem must not block signing in or shifts.
      debugPrint('Member count sync failed: $error');
      if (mounted) {
        setState(() => impactStatus = 'Member count is still syncing.');
      }
    }
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
      clockRefresh = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) setState(() {});
      });
    }
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
    clockRefresh?.cancel();
    searchController.dispose();
    super.dispose();
  }

  List<Opportunity> get filtered {
    final query = searchController.text.toLowerCase();

    return opportunities.where((opportunity) {
      if (!opportunity.isAvailable(DateTime.now())) return false;
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
                          isMyPage: navIndex == 4,
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
              unreadCount: notices.where((n) => !n.read).length,
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
        return NotificationsScreen(
            notifications: notices,
            loading: noticesLoading,
            onOpen: (notice) {
              if (widget.connected) {
                perform(() => repository!.markNotificationRead(notice.id));
              }
              final matches =
                  opportunities.where((e) => e.id == notice.eventId);
              if (matches.isNotEmpty) {
                _showDetails(matches.first);
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(notice.message)));
              }
            });
      case 4:
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
          onSignOut: widget.connected && !saving
              ? () => perform(() => FirebaseAuth.instance.signOut())
              : null,
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
          rewards: rewardProgress,
          communityImpact: communityImpact,
          impactStatus: impactStatus,
          onImpact: () => setState(() => navIndex = 4),
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

  void _showDetails(Opportunity initial) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.transparent,
        builder: (_) => StreamBuilder<List<Opportunity>>(
            stream: widget.connected
                ? repository!.events()
                : Stream.value(opportunities),
            initialData: opportunities,
            builder: (sheetContext, snapshot) {
              final item = (snapshot.data ?? [])
                      .where((e) => e.id == initial.id)
                      .firstOrNull ??
                  initial;
              final owner = widget.connected && item.ownerId == repository!.uid;
              return OpportunityDetailsSheet(
                  item: item,
                  isFavorite: favorites.contains(item.id),
                  isJoined: joined.contains(item.id),
                  onAttendees: owner
                      ? () {
                          Navigator.pop(sheetContext);
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => AttendeesSheet(
                                  title: item.title,
                                  attendees: repository!.attendees(item.id)));
                        }
                      : null,
                  onEdit: owner
                      ? () {
                          Navigator.pop(sheetContext);
                          _showPost(item);
                        }
                      : null,
                  onDelete: owner
                      ? () async {
                          Navigator.pop(sheetContext);
                          final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                      title: const Text('Cancel this event?'),
                                      content: const Text(
                                          'It will be removed from Discover and volunteers will receive a notification.'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(c, false),
                                            child: const Text('Keep event')),
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(c, true),
                                            child: const Text('Cancel event'))
                                      ]));
                          if (confirmed == true) {
                            perform(() => repository!.deleteEvent(item));
                          }
                        }
                      : null,
                  onFavorite: () {
                    _toggleFavorite(item.id);
                    Navigator.pop(sheetContext);
                  },
                  onJoin: () {
                    if (canWrite) {
                      final joining = !joined.contains(item.id);
                      perform(() => repository!.setAttendance(item.id, joining),
                          onSuccess: joining
                              ? () => showJoinConfirmation(context)
                              : null);
                    }
                    Navigator.pop(sheetContext);
                  },
                  onInvite: () {
                    Navigator.pop(sheetContext);
                    _showInvite(item);
                  });
            }));
  }

  void _showInvite(Opportunity item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => InviteSheet(item: item),
    );
  }

  RewardProgress get rewardProgress =>
      RewardProgress.fromShifts(opportunities, joined, DateTime.now());

  void _showRewards() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (_) => RewardsSheet(rewards: rewardProgress),
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
            onSave: (event, photo) => repository!
                .saveEvent(event, photo: photo, update: existing != null),
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
