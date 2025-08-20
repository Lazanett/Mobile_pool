import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  User? user;

  // 🔑 Connexion Google
  Future<void> _loginWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // 🌐 Web : popup Google directement via Firebase
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

        userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // 📱 Mobile (Android/iOS) : GoogleSignIn + Credential Firebase
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
      }

      setState(() {
        user = userCredential.user;
      });
    } catch (e) {
      debugPrint("Erreur Google Sign-In: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion: $e")),
      );
    }
  }

  // 🔒 Déconnexion
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
    setState(() {
      user = null;
    });
  }

  void _loginWithGithub() {
    debugPrint("Login avec GitHub (à implémenter)");
  }

  @override
  Widget build(BuildContext context) {
    user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/image.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: user == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- Bouton Google ---
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _loginWithGoogle,
                        icon: const Icon(Icons.login),
                        label: const Text(
                          "Login with Google",
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Bouton GitHub ---
                    SizedBox(
                      width: 250,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: _loginWithGithub,
                        icon: const Icon(Icons.code),
                        label: const Text(
                          "Login with GitHub",
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(user!.photoURL ?? ""),
                      radius: 40,
                    ),
                    const SizedBox(height: 10),
                    Text("Bonjour, ${user!.displayName ?? 'Utilisateur'}"),
                    Text(user!.email ?? ""),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _logout,
                      child: const Text("Déconnexion"),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
