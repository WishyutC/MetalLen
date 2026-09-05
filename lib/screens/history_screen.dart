import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../models/inspection.dart';
import '../theme/app_tokens.dart';
import '../widgets/inspection_row.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _searchController = TextEditingController();
  InspectionStatus? _filter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Inspection> get _visible {
    final query = _searchController.text.trim().toLowerCase();
    return MockData.inspections.where((item) {
      final matchesStatus = _filter == null || item.status == _filter;
      final matchesSearch = query.isEmpty ||
          item.partId.toLowerCase().contains(query) ||
          item.flaw.toLowerCase().contains(query);
      return matchesStatus && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppTokens.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.history_rounded,
                        color: AppTokens.accentContent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Inspection history',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${MockData.inspections.length} records',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: .58),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search part ID or flaw type',
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                      ...InspectionStatus.values.map(
                        (status) => _FilterChip(
                          label: _statusLabel(status),
                          selected: _filter == status,
                          onTap: () => setState(() => _filter = status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_visible.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No inspections match this search.')),
            )
          else
            ...['Today', 'Yesterday'].expand((group) {
              final records =
                  _visible.where((item) => item.group == group).toList();
              if (records.isEmpty) return <Widget>[];
              return <Widget>[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 2),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            group,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${records.length} inspections',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: .55),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  sliver: SliverList.separated(
                    itemCount: records.length,
                    itemBuilder: (_, index) => InspectionRow(
                      inspection: records[index],
                      onTap: () => _showPreparedDetail(context, records[index]),
                    ),
                    separatorBuilder: (_, __) => const Divider(height: 1),
                  ),
                ),
              ];
            }),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  void _showPreparedDetail(BuildContext context, Inspection item) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.partId,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text('${item.flaw} · ${item.line} · ${item.time}'),
              const SizedBox(height: 14),
              const Text(
                'Result-detail route prepared',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Text(
                'A future result view can receive this inspection record, image, CNN probabilities, and reviewer decision.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(InspectionStatus status) =>
      status.name[0].toUpperCase() + status.name.substring(1);
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          selectedColor: AppTokens.accent,
          labelStyle: TextStyle(
            color: selected ? AppTokens.accentContent : null,
            fontWeight: FontWeight.w700,
          ),
          showCheckmark: false,
        ),
      );
}
