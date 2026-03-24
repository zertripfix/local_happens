import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:local_happens/features/auth/domain/entities/user_role.dart';
import 'package:local_happens/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:local_happens/features/auth/presentation/cubit/auth_state.dart';

class _NavItem {
  final String iconPath;
  final String label;

  const _NavItem({required this.iconPath, required this.label});
}

class NavigationBarWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavigationBarWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final isAdmin = authState is Authenticated
        ? authState.user.role == UserRole.admin
        : false;

    final items = [
      _NavItem(iconPath: 'lib/assets/icons/home_icon.svg', label: 'Головна'),
      _NavItem(iconPath: 'lib/assets/icons/map_icon.svg', label: 'Карта'),
      _NavItem(iconPath: 'lib/assets/icons/heart_icon.svg', label: 'Обране'),
      _NavItem(iconPath: 'lib/assets/icons/profile_icon.svg', label: 'Профіль'),
      if (isAdmin)
        _NavItem(iconPath: 'lib/assets/icons/admin_icon.svg', label: 'Admin'),
    ];

    return _CustomNavBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
    );
  }
}

class _CustomNavBar extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final Function(int) onTap;

  const _CustomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.15),
            border: Border(
              top: BorderSide(
                color: colorScheme.surface.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: true,
            top: false,
            child: SizedBox(
              height: 60,
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      final isSelected = index == currentIndex;

                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onTap(index),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                item.iconPath,
                                colorFilter: ColorFilter.mode(
                                  isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                  BlendMode.srcIn,
                                ),
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final itemWidth = constraints.maxWidth / items.length;
                        const indicatorWidth = 20.0;
                        final leftOffset =
                            (currentIndex * itemWidth) +
                            (itemWidth / 2) -
                            (indicatorWidth / 2);

                        return Stack(
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              top: 0,
                              left: leftOffset,
                              child: Container(
                                width: indicatorWidth,
                                height: 3,
                                decoration: BoxDecoration(
                                  color: colorScheme.onSurface,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
