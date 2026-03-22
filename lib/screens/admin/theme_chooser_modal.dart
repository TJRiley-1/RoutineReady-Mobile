import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_constants.dart';
import '../../data/preset_themes.dart';
import '../../models/theme_config.dart';
import '../../providers/school_provider.dart';
import '../../utils/theme_utils.dart';

class ThemeChooserModal extends ConsumerWidget {
  final VoidCallback onCreateCustom;
  final ValueChanged<ThemeConfig> onEditCustom;

  const ThemeChooserModal({
    super.key,
    required this.onCreateCustom,
    required this.onEditCustom,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolState = ref.watch(schoolProvider).valueOrNull;
    if (schoolState == null) return const SizedBox.shrink();

    final currentTheme = schoolState.currentTheme;
    final customThemes = schoolState.customThemes;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Choose Theme',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Preset Themes',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: presetThemes.entries.map((entry) {
                          return _ThemePreviewCard(
                            theme: entry.value,
                            isSelected: currentTheme == entry.key,
                            onTap: () {
                              ref
                                  .read(schoolProvider.notifier)
                                  .updateCurrentTheme(entry.key);
                            },
                          );
                        }).toList(),
                      ),
                      if (customThemes.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text('Custom Themes',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: customThemes.map((theme) {
                            return _ThemePreviewCard(
                              theme: theme,
                              isSelected: currentTheme == theme.id,
                              onTap: () {
                                ref
                                    .read(schoolProvider.notifier)
                                    .updateCurrentTheme(theme.id);
                              },
                              onEdit: () => onEditCustom(theme),
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: onCreateCustom,
                          icon: const Icon(Icons.add),
                          label: const Text('Create Custom Theme'),
                        ),
                      ),
                    ],
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

class _ThemePreviewCard extends StatelessWidget {
  final ThemeConfig theme;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const _ThemePreviewCard({
    required this.theme,
    required this.isSelected,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final bgFrom = parseHexColor(theme.bgGradientFrom);
    final bgTo = parseHexColor(theme.bgGradientTo);
    final borderColor = parseHexColor(theme.cardBorderColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgFrom, bgTo],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.brandBorder,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(theme.emoji,
                style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              theme.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: borderColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Sample task card
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: parseHexColor(theme.cardBgColor),
                border: Border.all(
                    color: borderColor,
                    width: theme.borderWidthValue),
                borderRadius:
                    BorderRadius.circular(theme.borderRadius * 0.5),
              ),
              child: Text(
                'Sample Task',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: mapFontWeight(theme.fontWeight),
                ),
              ),
            ),
            if (onEdit != null) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onEdit,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
