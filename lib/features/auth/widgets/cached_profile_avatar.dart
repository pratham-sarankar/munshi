import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class CachedProfileAvatar extends StatelessWidget {
  const CachedProfileAvatar({
    required this.imageUrl, super.key,
    this.radius = 20,
    this.iconSize = 20,
  });

  final String? imageUrl;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Icon(
              Iconsax.user_bold,
              size: iconSize,
              color: colorScheme.onSurfaceVariant,
            )
          : ClipOval(
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                fadeOutDuration: const Duration(milliseconds: 100),
                memCacheWidth: (radius * 6).toInt(), // Optimize memory usage
                memCacheHeight: (radius * 6).toInt(),
                placeholder: (context, url) => Container(
                  width: radius * 2,
                  height: radius * 2,
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Iconsax.user_bold,
                    size: iconSize,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                errorWidget: (context, url, error) {
                  log('Failed to load profile image: $error');
                  return Container(
                    width: radius * 2,
                    height: radius * 2,
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Iconsax.user_bold,
                      size: iconSize,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
