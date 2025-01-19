import 'package:flutter/material.dart';
import 'package:mood_tracker/services/auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum LoginButtonType { google, apple, guest }

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900, // Set a clean background color
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Spacer(),
              const Text(
                'Mood Tracker',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you having a good day today?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              // Image can be wrapped in a Container for better styling
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                ),
                child: Image.asset(
                  'assets/images/manic.jpeg',
                  height: 250,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              // Anonymous Login Button
              LoginButton(
                buttonType: LoginButtonType.guest,
                text: 'Continue as Guest',
                icon: FontAwesomeIcons.user,
                loginMethod: AuthService().anonLogin,
              ),
              // Google Sign-In Button
              LoginButton(
                buttonType: LoginButtonType.google,
                text: 'Sign in with Google',
                icon: FontAwesomeIcons.google,
                loginMethod: AuthService().googleLogin,
              ),
              // Apple Sign-In Button
              // Only show if on ios
              if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                LoginButton(
                  buttonType: LoginButtonType.apple,
                  text: 'Sign in with Apple',
                  icon: FontAwesomeIcons.apple,
                  loginMethod: AuthService().appleLogin,
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  final LoginButtonType buttonType;
  final Color color;
  final IconData icon;
  final String text;
  final Function loginMethod;

  LoginButton({
    super.key,
    required this.buttonType,
    required this.text,
    required this.icon,
    required this.loginMethod,
  }) : color = _getColor(buttonType);

  static Color _getColor(LoginButtonType type) {
    switch (type) {
      case LoginButtonType.google:
        return Colors.white;
      case LoginButtonType.apple:
        return Colors.black;
      case LoginButtonType.guest:
        return Colors.deepPurple;
      default:
        return Colors.deepPurpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine text color based on button type
    Color textColor;
    BoxBorder? border;
    Widget leadingIcon;

    switch (buttonType) {
      case LoginButtonType.google:
        textColor = Colors.black87;
        border = Border.all(color: Colors.grey.shade300);
        leadingIcon = FaIcon(
          icon,
          color: Colors.red,
        );
        break;
      case LoginButtonType.apple:
        textColor = Colors.white;
        border = null; // No border for Apple button
        leadingIcon = FaIcon(
          icon,
          color: Colors.white,
        );
        break;
      case LoginButtonType.guest:
        textColor = Colors.white;
        border = null; // No border for Guest button
        leadingIcon = FaIcon(
          icon,
          color: Colors.white,
        );
        break;
      default:
        textColor = Colors.white;
        border = null;
        leadingIcon = FaIcon(
          icon,
          color: Colors.white,
        );
    }

    // Define button styles
    BoxDecoration decoration;
    if (buttonType == LoginButtonType.guest) {
      decoration = BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
    } else {
      decoration = BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => loginMethod(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: decoration,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Leading icon
              leadingIcon,
              const SizedBox(width: 12),
              // Button text
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
