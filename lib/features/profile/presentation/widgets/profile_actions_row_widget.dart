import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_happens/features/auth/presentation/cubit/auth_cubit.dart';

class ProfileActionsRowWidget extends StatelessWidget {
  const ProfileActionsRowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProfileActionCard(
            icon: Icons.add,
            label: 'Створити подію',
            onTap: () => context.push('/events/create'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProfileActionCard(
            icon: Icons.logout,
            label: 'Вийти',
            onTap: () => context.read<AuthCubit>().signOut(),
          ),
        ),
      ],
    );
  }
}

class _ProfileActionCard extends StatelessWidget {
  const _ProfileActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: Card.filled(
        margin: EdgeInsets.zero,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(icon), Text(label)],
          ),
        ),
      ),
    );
  }
}
