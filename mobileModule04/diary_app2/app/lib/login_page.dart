import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app/profile_page.dart';
import 'package:app/main.dart';
import 'services/populate_test_data.dart';

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
      User? user;

      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({'prompt': 'select_account'});

        final userCredential =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);

        user = await _signInWithProvider(userCredential.credential!);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        user = await _signInWithProvider(credential);
      }

      setState(() {
        this.user = user;
      });

      if (user != null) {
        await populateTestDataForUser(user.email!);
        Navigator.pushReplacementNamed(context, '/profile');
      }

    } catch (e) {
      debugPrint("Error Google Sign-In: $e");
    }
  }


  // 🔑 Connexion GitHub
  Future<void> _loginWithGithub() async {
    try {
      User? user;

      if (kIsWeb) {
        final githubProvider = GithubAuthProvider();
        githubProvider.addScope('read:user');
        githubProvider.setCustomParameters({'prompt': 'select_account'});

        final userCredential =
            await FirebaseAuth.instance.signInWithPopup(githubProvider);

        user = await _signInWithProvider(userCredential.credential!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("GitHub login not supported on mobile")),
        );
        return;
      }

      setState(() {
        this.user = user;
      });

      if (user != null) {
        Navigator.pushReplacementNamed(context, '/profile');
      }

    } catch (e) {
      debugPrint("Error GitHub Sign-In: $e");
    }
  }

  Future<User?> _signInWithProvider(AuthCredential credential) async {
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        // ⚠️ Le même email existe déjà avec un autre provider
        final email = e.email!;
        final pendingCred = e.credential;

        final signInMethods =
            await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

        if (signInMethods.contains('google.com')) {
          // 🔑 Se connecter avec Google puis lier GitHub
          final googleUser = await GoogleSignIn().signIn();
          final googleAuth = await googleUser!.authentication;
          final googleCred = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final userCredential =
              await FirebaseAuth.instance.signInWithCredential(googleCred);

          await userCredential.user!.linkWithCredential(pendingCred!);
          return userCredential.user;
        } else if (signInMethods.contains('github.com')) {
          // 🔑 Se connecter avec GitHub puis lier Google
          final githubProvider = GithubAuthProvider();
          final userCredential =
              await FirebaseAuth.instance.signInWithPopup(githubProvider);

          await userCredential.user!.linkWithCredential(pendingCred!);
          return userCredential.user;
        }
      }
      rethrow;
    }
  }



  @override
  Widget build(BuildContext context) {
    user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // ✅ Redirection automatique vers ProfilePage
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilePage()),
        );
      });
    }

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
          ),
        ),
      ),
    );
  }
}
