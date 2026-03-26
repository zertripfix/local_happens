import 'package:flutter/material.dart';
import 'package:local_happens/features/events/presentation/models/events_filter_model.dart';
import 'package:local_happens/core/constants/app_colors.dart';
import 'package:local_happens/core/constants/app_text_styles.dart';

class EventsFilterSheet extends StatefulWidget {
  final EventsFilterModel initialFilters;
  final List<String> availableCities;
  final ValueChanged<EventsFilterModel> onApply;
  final VoidCallback onReset;
  final ScrollController? scrollController;

  const EventsFilterSheet({
    super.key,
    required this.initialFilters,
    required this.availableCities,
    required this.onApply,
    required this.onReset,
    this.scrollController,
  });

  @override
  State<EventsFilterSheet> createState() => _EventsFilterSheetState();
}

class _EventsFilterSheetState extends State<EventsFilterSheet> {
  late EventsFilterModel _localFilters;
  late TextEditingController _customCityController;
  late bool _isCustomCityMode;

  final List<Map<String, dynamic>> _timeOptions = [
    {'label': 'Сьогодні', 'value': EventsTimeFilter.today},
    {'label': 'Завтра', 'value': EventsTimeFilter.tomorrow},
    {'label': 'Ці вихідні', 'value': EventsTimeFilter.weekend},
    {'label': 'Цей тиждень', 'value': EventsTimeFilter.week},
    {'label': 'Цей місяць', 'value': EventsTimeFilter.month},
  ];

  @override
  void initState() {
    super.initState();
    _localFilters = widget.initialFilters;
    _customCityController = TextEditingController(
      text: widget.initialFilters.selectedCustomCity ?? '',
    );
    _isCustomCityMode = (widget.initialFilters.selectedCustomCity ?? '')
        .trim()
        .isNotEmpty;
  }

  @override
  void dispose() {
    _customCityController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final now = DateTime.now();
    final firstDate = DateTime(2024);
    final lastDate = DateTime(2100);

    DateTime initialDate;

    if (isFrom) {
      initialDate = _localFilters.dateFrom ?? now;
    } else {
      initialDate = _localFilters.dateTo ?? _localFilters.dateFrom ?? now;
    }

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate == null) return;

    setState(() {
      if (isFrom) {
        _localFilters = _localFilters.copyWith(
          selectedTimeFilter: EventsTimeFilter.custom,
          dateFrom: pickedDate,
          dateTo:
              _localFilters.dateTo != null &&
                  _localFilters.dateTo!.isBefore(pickedDate)
              ? pickedDate
              : _localFilters.dateTo,
        );
      } else {
        _localFilters = _localFilters.copyWith(
          selectedTimeFilter: EventsTimeFilter.custom,
          dateFrom:
              _localFilters.dateFrom != null &&
                  _localFilters.dateFrom!.isAfter(pickedDate)
              ? pickedDate
              : _localFilters.dateFrom,
          dateTo: pickedDate,
        );
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Оберіть дату';
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  bool get _isCustomDateSelected =>
      _localFilters.selectedTimeFilter == EventsTimeFilter.custom;

  BoxDecoration _chipDecoration(bool isSelected) {
    return BoxDecoration(
      color: isSelected
          ? AppColors.accent.withOpacity(0.1)
          : AppColors.secondaryBackground,
      borderRadius: BorderRadius.circular(100),
      border: Border.all(
        color: isSelected
            ? AppColors.accent.withOpacity(0.2)
            : Colors.transparent,
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        decoration: _chipDecoration(isSelected),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.foreground),
              const SizedBox(width: 4),
            ],
            Text(label, style: AppTextStyles.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.section),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.secondaryBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.mutedForeground,
                ),
                const SizedBox(width: 10),
                Text(
                  _formatDate(value),
                  style: value == null
                      ? AppTextStyles.section
                      : AppTextStyles.value.copyWith(
                          color: AppColors.foreground,
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final sortedCities = [
      'Київ',
      'Харків',
      'Одеса',
      'Львів',
      'Вінниця',
      'Дніпро',
      'Кривий ріг',
      'Запоріжжя',
      'Миколаїв',
      'Херсон',
    ];

    final autocompleteCities =
        {
            ...sortedCities.map((city) => city.trim()),
            ...widget.availableCities.map((city) => city.trim()),
          }.where((city) => city.isNotEmpty).toList()
          ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Фільтри', style: AppTextStyles.title),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 16),
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: 13),
            const Text('Коли', style: AppTextStyles.section),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeOptions.map((option) {
                final isSelected =
                    _localFilters.selectedTimeFilter == option['value'];

                return _buildChip(
                  label: option['label'],
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      final isAlreadySelected =
                          _localFilters.selectedTimeFilter == option['value'];

                      _localFilters = isAlreadySelected
                          ? _localFilters.copyWith(
                              selectedTimeFilter: EventsTimeFilter.none,
                              clearDateFrom: true,
                              clearDateTo: true,
                            )
                          : _localFilters.copyWith(
                              selectedTimeFilter: option['value'],
                              clearDateFrom: true,
                              clearDateTo: true,
                            );
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            _buildChip(
              label: 'Вибрати дати',
              isSelected: _isCustomDateSelected,
              onTap: () {
                setState(() {
                  if (_isCustomDateSelected) {
                    _localFilters = _localFilters.copyWith(
                      selectedTimeFilter: EventsTimeFilter.none,
                      clearDateFrom: true,
                      clearDateTo: true,
                    );
                  } else {
                    _localFilters = _localFilters.copyWith(
                      selectedTimeFilter: EventsTimeFilter.custom,
                    );
                  }
                });
              },
            ),
            if (_isCustomDateSelected) ...[
              const SizedBox(height: 24),
              _buildDateField(
                label: 'Дата від',
                value: _localFilters.dateFrom,
                onTap: () => _pickDate(isFrom: true),
              ),
              const SizedBox(height: 24),
              _buildDateField(
                label: 'Дата по',
                value: _localFilters.dateTo,
                onTap: () => _pickDate(isFrom: false),
              ),
            ],
            const SizedBox(height: 24),
            const Text('Місто', style: AppTextStyles.section),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sortedCities.map((city) {
                final isSelected = _localFilters.selectedCity == city;

                return _buildChip(
                  label: city,
                  isSelected: isSelected,
                  icon: Icons.location_on_outlined,
                  onTap: () {
                    setState(() {
                      final isAlreadySelected =
                          _localFilters.selectedCity == city;

                      if (isAlreadySelected) {
                        _localFilters = _localFilters.copyWith(
                          clearSelectedCity: true,
                        );
                      } else {
                        _isCustomCityMode = false;
                        _localFilters = _localFilters.copyWith(
                          selectedCity: city,
                          clearSelectedCustomCity: true,
                        );
                        _customCityController.clear();
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            _buildChip(
              label: 'Вибрати інше місто',
              isSelected: _isCustomCityMode,
              onTap: () {
                setState(() {
                  if (_isCustomCityMode) {
                    _isCustomCityMode = false;
                    _customCityController.clear();
                    _localFilters = _localFilters.copyWith(
                      clearSelectedCustomCity: true,
                    );
                  } else {
                    _isCustomCityMode = true;
                    _localFilters = _localFilters.copyWith(
                      clearSelectedCity: true,
                    );
                  }
                });
              },
            ),
            if (_isCustomCityMode) ...[
              const SizedBox(height: 24),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  final query = textEditingValue.text.trim().toLowerCase();

                  if (query.isEmpty) {
                    return const Iterable<String>.empty();
                  }

                  return autocompleteCities.where(
                    (city) => city.toLowerCase().contains(query),
                  );
                },
                onSelected: (city) {
                  setState(() {
                    _localFilters = _localFilters.copyWith(
                      selectedCustomCity: city,
                      clearSelectedCity: true,
                    );
                  });
                },
                fieldViewBuilder:
                    (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        style: AppTextStyles.value.copyWith(
                          color: AppColors.foreground,
                        ),
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (value) {
                          setState(() {
                            _localFilters = _localFilters.copyWith(
                              selectedCustomCity: value.trim(),
                              clearSelectedCity: true,
                            );
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Оберіть місто',
                          hintStyle: AppTextStyles.section,
                          filled: true,
                          fillColor: AppColors.secondaryBackground,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      );
                    },
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _localFilters = _localFilters.reset();
                        _customCityController.clear();
                        _isCustomCityMode = false;
                      });
                      widget.onReset();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text('Скинути', style: AppTextStyles.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApply(_localFilters);
                    },
                    child: Text(
                      'Застосувати',
                      style: AppTextStyles.primary.copyWith(
                        color: AppColors.background,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
