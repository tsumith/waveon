import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:waveon/auth/logic/auth_provider.dart';
import 'package:waveon/auth/logic/auth_service.dart';
import 'package:shimmer/shimmer.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {

 Future<void> _launchPrivacyPolicy() async {
    // url_launcher implementation to external privacy policy hidden.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Privacy Policy link abstracted for public repo.')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLoading = authProvider.isLoadingProfile;
    final profileData = authProvider.userProfile;

    final username = profileData?['username'] ?? "";
    final email = profileData?['email'] ?? authProvider.user?.email ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),
            isLoading
                ? const _ProfileSkeleton()
                : _buildHeader(username, email),

            const SizedBox(height: 40),

            _buildProfileTile(
              icon: Icons.edit_rounded,
              title: "Change Username",
              onTap: () => _showChangeUsernameDialog(context),
            ),

            _buildProfileTile(
              icon: Icons.person_remove_rounded,
              title: "Delete Account",
              color: Colors.redAccent,
              onTap: () => _showDeleteAccountDialog(context),
            ),

            _buildProfileTile(
              icon: Icons.privacy_tip_rounded,
              title: "Privacy Policy",
              color: Colors.white70,
              onTap: _launchPrivacyPolicy,
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.white10, indent: 30, endIndent: 30),
            const SizedBox(height: 10),

            _buildProfileTile(
              icon: Icons.logout_rounded,
              title: "Logout",
              color: Colors.white60,
              onTap: () => Provider.of<AuthProvider>(
                context,
                listen: false,
              ).logout(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white24,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String username, String email) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00C6FF).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 46,
              backgroundColor: Colors.white12,
              child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            username,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showChangeUsernameDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            "Change Username",
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "New username",
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (controller.text.trim().length >= 3) {
                  final newUsername = controller.text.trim();
                  final navigator = Navigator.of(context);
                  dialogContext.pop();
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00C6FF),
                      ),
                    ),
                  );
                  try {
                    await AuthService.instance.changeUsername(newUsername);

                    if (context.mounted) {
                      await Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).refreshProfile();
                      navigator.pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Username updated successfully!"),
                        ),
                      );
                    }
                  } catch (e) {
                    navigator.pop();
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                }
              },
              child: const Text(
                "Save",
                style: TextStyle(color: Color(0xFF00C6FF)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            "Delete Account",
            style: TextStyle(color: Colors.redAccent),
          ),
          content: const Text(
            "Are you sure? This will permanently delete your account and username.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                dialogContext.pop();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(
                    child: CircularProgressIndicator(color: Colors.redAccent),
                  ),
                );

                try {
                  await AuthService.instance.deleteAccount();

                  if (context.mounted) {
                    navigator.pop();
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).logout(context);
                  }
                } catch (e) {
                  navigator.pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                "Delete Forever",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 140,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 180,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
