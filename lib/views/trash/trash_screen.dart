import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/trash_controller.dart';
import '../../models/trash_item_model.dart';
import '../widgets/trash/trash_item_widget.dart';
import '../widgets/responsive_text.dart';
import '../components/empty_state.dart';

/// Trash Screen
/// Purpose: Display all deleted items with restore and permanent delete options
/// Features: Search, filter by type, bulk operations, statistics

class TrashScreen extends StatelessWidget {
  TrashScreen({Key? key}) : super(key: key);

  final TrashController _trashController = Get.put(TrashController());
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Search and filter section
          _buildSearchAndFilter(context),
          
          // Statistics section
          _buildStatistics(context),
          
          // Items list
          Expanded(
            child: _buildItemsList(context),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const AppText(
        'سلة المحذوفات',
        variant: AppTextVariant.h2,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      actions: [
        // Refresh button
        IconButton(
          onPressed: () => _trashController.refresh(),
          icon: const Icon(Icons.refresh),
          tooltip: 'تحديث',
        ),
        
        // More options menu
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'empty_trash':
                _trashController.emptyTrash();
                break;
              case 'clean_old':
                _showCleanOldDialog(context);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'empty_trash',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_sweep,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('إفراغ السلة'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clean_old',
              child: Row(
                children: [
                  Icon(Icons.cleaning_services, size: 20),
                  SizedBox(width: 8),
                  Text('تنظيف العناصر القديمة'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build search and filter section
  Widget _buildSearchAndFilter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'البحث في سلة المحذوفات...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => _trashController.isSearching
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _trashController.clearSearch();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            ),
            onChanged: (value) => _trashController.searchTrashItems(value),
          ),
          
          const SizedBox(height: 12),
          
          // Filter chips
          Obx(() {
            final filterOptions = _trashController.filterOptions;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: filterOptions.map((option) {
                  final isSelected = _trashController.selectedFilter == option['value'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${option['label']} (${option['count']})'),
                      selected: isSelected,
                      onSelected: (selected) {
                        _trashController.setFilter(option['value']);
                      },
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build statistics section
  Widget _buildStatistics(BuildContext context) {
    return Obx(() {
      final stats = _trashController.trashStats;
      if (stats.isEmpty) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppText(
                'إجمالي العناصر المحذوفة: ${stats['total'] ?? 0}',
                variant: AppTextVariant.body2,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Build items list
  Widget _buildItemsList(BuildContext context) {
    return Obx(() {
      if (_trashController.isLoading) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final items = _trashController.filteredTrashItems;

      if (items.isEmpty) {
        return _buildEmptyState(context);
      }

      return RefreshIndicator(
        onRefresh: () => _trashController.refresh(),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return TrashItemWidget(
              key: ValueKey('trash_item_${item.type}_${item.id}'),
              item: item,
              onRestore: () => _trashController.restoreItem(item),
              onPermanentDelete: () => _trashController.permanentlyDeleteItem(item),
              onTap: () => _showItemDetails(context, item),
            );
          },
        ),
      );
    });
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context) {
    return Obx(() {
      if (_trashController.isSearching) {
        return EmptyState(
          icon: Icons.search_off,
          title: 'لا توجد نتائج',
          subtitle: 'لم يتم العثور على عناصر تطابق البحث "${_trashController.searchQuery}"',
          actionText: 'مسح البحث',
          onActionPressed: () {
            _searchController.clear();
            _trashController.clearSearch();
          },
        );
      }

      if (_trashController.selectedFilter != 'all') {
        final filterOptions = _trashController.filterOptions;
        final currentFilter = filterOptions.firstWhere(
          (option) => option['value'] == _trashController.selectedFilter,
          orElse: () => {'label': 'المحدد'},
        );
        
        return EmptyState(
          icon: Icons.filter_list_off,
          title: 'لا توجد عناصر',
          subtitle: 'لا توجد عناصر محذوفة من نوع "${currentFilter['label']}"',
          actionText: 'عرض الكل',
          onActionPressed: () => _trashController.setFilter('all'),
        );
      }

      return const EmptyState(
        icon: Icons.delete_outline,
        title: 'سلة المحذوفات فارغة',
        subtitle: 'لا توجد عناصر محذوفة حالياً.\nالعناصر المحذوفة ستظهر هنا.',
      );
    });
  }

  /// Build floating action button
  Widget? _buildFloatingActionButton(BuildContext context) {
    return Obx(() {
      if (!_trashController.hasTrashItems) return const SizedBox.shrink();

      return FloatingActionButton.extended(
        onPressed: () => _trashController.emptyTrash(),
        icon: const Icon(Icons.delete_sweep),
        label: const Text('إفراغ السلة'),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      );
    });
  }

  /// Show item details dialog
  void _showItemDetails(BuildContext context, TrashItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(item.typeIcon),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type
              _buildDetailRow(context, 'النوع', item.typeDisplayName),
              
              // Parent info
              if (item.parentInfo != null && item.parentInfo!.isNotEmpty)
                _buildDetailRow(context, 'ينتمي إلى', item.parentInfo!),
              
              // Description
              if (item.description != null && item.description!.isNotEmpty)
                _buildDetailRow(context, 'الوصف', item.description!),
              
              // Dates
              _buildDetailRow(context, 'تاريخ الإنشاء', _formatDate(item.createdAt)),
              if (item.updatedAt != null)
                _buildDetailRow(context, 'آخر تحديث', _formatDate(item.updatedAt!)),
              _buildDetailRow(context, 'تاريخ الحذف', _formatDate(item.deletedAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _trashController.restoreItem(item);
            },
            child: const Text('استعادة'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _trashController.permanentlyDeleteItem(item);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('حذف نهائي'),
          ),
        ],
      ),
    );
  }

  /// Build detail row
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Show clean old items dialog
  void _showCleanOldDialog(BuildContext context) {
    int selectedDays = 30;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('تنظيف العناصر القديمة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('حذف العناصر المحذوفة منذ أكثر من:'),
              const SizedBox(height: 16),
              DropdownButton<int>(
                value: selectedDays,
                isExpanded: true,
                items: [7, 14, 30, 60, 90].map((days) {
                  return DropdownMenuItem(
                    value: days,
                    child: Text('$days ${days == 1 ? 'يوم' : 'أيام'}'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedDays = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _trashController.cleanOldItems(olderThanDays: selectedDays);
              },
              child: const Text('تنظيف'),
            ),
          ],
        ),
      ),
    );
  }
}
