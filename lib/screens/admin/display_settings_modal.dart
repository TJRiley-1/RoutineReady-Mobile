import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme_constants.dart';
import '../../data/transition_presets.dart';
import '../../models/display_settings.dart';
import '../../providers/school_provider.dart';

class DisplaySettingsModal extends ConsumerStatefulWidget {
  const DisplaySettingsModal({super.key});

  @override
  ConsumerState<DisplaySettingsModal> createState() =>
      _DisplaySettingsModalState();
}

class _DisplaySettingsModalState extends ConsumerState<DisplaySettingsModal> {
  late DisplaySettings _settings;

  @override
  void initState() {
    super.initState();
    _settings =
        ref.read(schoolProvider).valueOrNull?.displaySettings ??
            const DisplaySettings();
  }

  void _update(DisplaySettings s) {
    setState(() => _settings = s);
    ref.read(schoolProvider.notifier).updateDisplaySettings(s);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Display Settings',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
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
                      // Display mode
                      const Text('Display Mode',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                              value: 'horizontal',
                              label: Text('Horizontal')),
                          ButtonSegment(
                              value: 'multi-row',
                              label: Text('Multi-Row')),
                          ButtonSegment(
                              value: 'auto-pan',
                              label: Text('Auto-Pan')),
                        ],
                        selected: {_settings.mode},
                        onSelectionChanged: (v) =>
                            _update(_settings.copyWith(mode: v.first)),
                      ),
                      const SizedBox(height: 16),

                      if (_settings.mode == 'multi-row') ...[
                        Text('Rows: ${_settings.rows}'),
                        Slider(
                          value: _settings.rows.toDouble(),
                          min: 1,
                          max: 4,
                          divisions: 3,
                          onChanged: (v) =>
                              _update(_settings.copyWith(rows: v.round())),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Transition type
                      const Text('Transition Type',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                              value: 'progress-line',
                              label: Text('Progress Line')),
                          ButtonSegment(
                              value: 'mascot',
                              label: Text('Mascot Road')),
                        ],
                        selected: {_settings.transitionType},
                        onSelectionChanged: (v) =>
                            _update(_settings.copyWith(
                                transitionType: v.first)),
                      ),
                      const SizedBox(height: 16),

                      if (_settings.transitionType == 'mascot') ...[
                        // Sprite picker
                        const Text('Sprite',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: spritePresets.map((s) {
                            final isSelected =
                                _settings.selectedSprite == s.id;
                            return GestureDetector(
                              onTap: () => _update(_settings.copyWith(
                                  selectedSprite: s.id)),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.brandPrimary
                                        : AppColors.brandBorder,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: isSelected
                                      ? AppColors.brandPrimaryBg
                                      : Colors.white,
                                ),
                                child: Center(
                                    child: Text(s.emoji,
                                        style: const TextStyle(
                                            fontSize: 24))),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // Surface picker
                        const Text('Surface',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: surfacePresets.map((s) {
                            final isSelected =
                                _settings.selectedSurface == s.id;
                            return GestureDetector(
                              onTap: () => _update(_settings.copyWith(
                                  selectedSurface: s.id)),
                              child: Container(
                                width: 80,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: s.gradientColors),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.brandPrimary
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Text(
                                    s.label,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: s.id == 'tarmac'
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        Text('Road Height: ${_settings.roadHeight}px'),
                        Slider(
                          value: _settings.roadHeight.toDouble(),
                          min: 16,
                          max: 64,
                          divisions: 12,
                          onChanged: (v) => _update(
                              _settings.copyWith(roadHeight: v.round())),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Resolution
                      const Text('Resolution',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _resolutionButton(2560, 1080, 'Ultra-wide'),
                          _resolutionButton(1920, 1080, 'Full HD'),
                          _resolutionButton(1280, 720, 'HD'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                  labelText: 'Width'),
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(
                                  text: '${_settings.width}'),
                              onSubmitted: (v) {
                                final w = int.tryParse(v);
                                if (w != null && w > 0) {
                                  _update(_settings.copyWith(width: w));
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('x'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                  labelText: 'Height'),
                              keyboardType: TextInputType.number,
                              controller: TextEditingController(
                                  text: '${_settings.height}'),
                              onSubmitted: (v) {
                                final h = int.tryParse(v);
                                if (h != null && h > 0) {
                                  _update(_settings.copyWith(height: h));
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Scale
                      Text('Scale: ${_settings.scale}%'),
                      Slider(
                        value: _settings.scale.toDouble(),
                        min: 25,
                        max: 200,
                        divisions: 35,
                        onChanged: (v) =>
                            _update(_settings.copyWith(scale: v.round())),
                      ),
                      const SizedBox(height: 16),

                      // Auto-pan tile height
                      if (_settings.mode == 'auto-pan') ...[
                        Text(
                            'Task Tile Height: ${_settings.autoPanTileHeight}%'),
                        Slider(
                          value: _settings.autoPanTileHeight.toDouble(),
                          min: 30,
                          max: 90,
                          divisions: 12,
                          onChanged: (v) => _update(_settings.copyWith(
                              autoPanTileHeight: v.round())),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Clock toggle
                      SwitchListTile(
                        title: const Text('Show Live Clock'),
                        value: _settings.showClock,
                        onChanged: (v) =>
                            _update(_settings.copyWith(showClock: v)),
                      ),

                      // Banner heights
                      Text(
                          'Top Banner Height: ${_settings.topBannerHeight}px'),
                      Slider(
                        value: _settings.topBannerHeight.toDouble(),
                        min: 24,
                        max: 120,
                        divisions: 24,
                        onChanged: (v) => _update(
                            _settings.copyWith(topBannerHeight: v.round())),
                      ),
                      Text(
                          'Bottom Banner Height: ${_settings.bottomBannerHeight}px'),
                      Slider(
                        value: _settings.bottomBannerHeight.toDouble(),
                        min: 24,
                        max: 120,
                        divisions: 24,
                        onChanged: (v) => _update(_settings.copyWith(
                            bottomBannerHeight: v.round())),
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

  Widget _resolutionButton(int w, int h, String label) {
    final isSelected = _settings.width == w && _settings.height == h;
    return OutlinedButton(
      onPressed: () => _update(_settings.copyWith(width: w, height: h)),
      style: OutlinedButton.styleFrom(
        backgroundColor:
            isSelected ? AppColors.brandPrimaryBg : Colors.white,
        side: BorderSide(
          color:
              isSelected ? AppColors.brandPrimary : AppColors.brandBorder,
        ),
      ),
      child: Text('$label\n${w}x$h',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11)),
    );
  }
}
