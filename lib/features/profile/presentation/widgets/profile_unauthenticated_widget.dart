import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:local_happens/core/constants/app_text_styles.dart';

class ProfileUnauthenticatedWidget extends StatelessWidget {
  const ProfileUnauthenticatedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFBFAF9),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          const SizedBox(height: 132),
          // Логотип
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0ED),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF79867D),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 64,
                height: 64,
                child: Image.asset('lib/assets/images/logo.png'),
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text('LocalHappens', style: AppTextStyles.headline),
          const SizedBox(height: 2),
          const Text('Знаходь цікаве поруч', style: AppTextStyles.value),

          const SizedBox(height: 40),

          Text('Вітаємо!'),
          Center(
            child: Text(
              'Увійдіть, щоб додавати події, зберігати улюблене та керувати своїми подіями',
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/login'),
            child: Text('Увійти / Зареєструватись'),
          ),
        ],
      ),
    );
  }
}
