import 'package:flutter/material.dart';
import '../services/authentication_client.dart';
import '../pages/home_page.dart';
import '../pages/sport_status_page.dart';
import '../pages/food_status_page.dart';
import '../theme/nutriwave_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      title: 'Today\'s Nutrients',
      icon: Icons.restaurant,
      page: const HomePage(),
    ),
    NavigationItem(
      title: 'Food Status',
      icon: Icons.fastfood,
      page: const FoodStatusPage(),
    ),
    NavigationItem(
      title: 'Sport Status',
      icon: Icons.sports_gymnastics,
      page: const SportStatusPage(),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    Navigator.pop(context); // Close drawer
  }

  void _logout() {
    AuthenticationClient().clearToken();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _navigationItems.map((item) => item.page).toList(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_navigationItems[_selectedIndex].title),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            // Trigger refresh on current page
            // This would need to be implemented in each page
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'logout') {
              _logout();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ],
          icon: const Icon(Icons.account_circle),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF3fc97c),
                  const Color(0xFF1c4c44),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.restaurant,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'NutriWave',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Your nutrition companion',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _navigationItems.length,
              itemBuilder: (context, index) {
                final item = _navigationItems[index];
                final isSelected = index == _selectedIndex;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isSelected 
                        ? const Color(0xFF3fc97c).withOpacity(0.1)
                        : Colors.transparent,
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF3fc97c).withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        item.icon,
                        color: isSelected 
                            ? const Color(0xFF3fc97c)
                            : Theme.of(context).iconTheme.color,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        color: isSelected 
                            ? const Color(0xFF3fc97c)
                            : Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    onTap: () => _onItemTapped(index),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Logout Section
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                _logout();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class NavigationItem {
  final String title;
  final IconData icon;
  final Widget page;

  NavigationItem({
    required this.title,
    required this.icon,
    required this.page,
  });
}