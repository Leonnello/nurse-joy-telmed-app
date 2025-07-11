import 'package:flutter/material.dart';
import 'package:nursejoyapp/shared/widgets/app_bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:nursejoyapp/shared/widgets/app_drawer.dart';

class AppScaffold extends StatefulWidget {
  final Widget body;
  final String title;
  final int selectedIndex;
  final Function(int) onItemTapped;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    required this.selectedIndex,
    required this.onItemTapped,
    this.actions,
    this.showBackButton = false,
    this.onBackPressed,
    this.floatingActionButton,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold>
    with TickerProviderStateMixin {
  late AnimationController _appBarController;
  late Animation<double> _appBarAnimation;

  @override
  void initState() {
    super.initState();

    _appBarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _appBarAnimation = CurvedAnimation(
      parent: _appBarController,
      curve: Curves.easeInOut,
    );


    _appBarController.forward();
  }

  @override
  void dispose() {
    _appBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      extendBodyBehindAppBar: false, // Changed to false to prevent body from going behind app bar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 24), // Account for custom app bar height
        child: _buildAppBar(),
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: widget.selectedIndex,
        onTap: widget.onItemTapped,
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100),
      child: AnimatedBuilder(
        animation: _appBarAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF58f0d7),
                  Color(0xFF4dd0e1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF58f0d7).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    // Leading Button
                    _buildAppBarButton(
                      icon: widget.showBackButton
                          ? Icons.arrow_back_ios_rounded
                          : Icons.menu_rounded,
                      onPressed: widget.showBackButton
                          ? (widget.onBackPressed ?? () => context.pop())
                          : () => Scaffold.of(context).openDrawer(),
                    ),

                    // Title Section
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              width: 40,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Actions
                    if (widget.actions != null) ...widget.actions!,
                    if (widget.actions == null)
                      _buildAppBarButton(
                        icon: Icons.notifications_rounded,
                        onPressed: () {
                          context.go('/activity-list');
                        },
                        showBadge: true,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBarButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool showBadge = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                if (showBadge)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      // Let the Scaffold handle the padding with SafeArea
      child: SafeArea(
        top: true,
        bottom: false,
        child: widget.body,
      ),
    );
  }
}
