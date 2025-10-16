import 'package:get/get.dart';
import '../models/trash_item_model.dart';
import '../data/repository/trash_repository.dart';
import '../core/services/dialog_service.dart';

/// Trash Controller
/// Purpose: Manage deleted items state and operations
/// Features: Load, restore, permanently delete, search, and filter trash items

class TrashController extends GetxController {
  final TrashRepository _trashRepository = TrashRepository();
  final DialogService _dialogService = Get.find<DialogService>();

  // Observable lists
  final RxList<TrashItemModel> _allTrashItems = <TrashItemModel>[].obs;
  final RxList<TrashItemModel> _filteredTrashItems = <TrashItemModel>[].obs;

  // Loading and search states
  final RxBool _isLoading = false.obs;
  final RxBool _isSearching = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _selectedFilter = 'all'.obs;

  // Statistics
  final RxMap<String, int> _trashStats = <String, int>{}.obs;

  // Getters
  List<TrashItemModel> get allTrashItems => _allTrashItems;
  List<TrashItemModel> get filteredTrashItems => _filteredTrashItems;
  bool get isLoading => _isLoading.value;
  bool get isSearching => _isSearching.value;
  String get searchQuery => _searchQuery.value;
  String get selectedFilter => _selectedFilter.value;
  Map<String, int> get trashStats => _trashStats;

  // Computed properties
  int get totalTrashItems => _allTrashItems.length;
  bool get hasTrashItems => _allTrashItems.isNotEmpty;
  bool get isFiltered => _selectedFilter.value != 'all' || _searchQuery.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    loadTrashItems();
    loadTrashStatistics();
  }

  /// Load all deleted items
  Future<void> loadTrashItems({bool showLoading = true}) async {
    if (showLoading) _isLoading.value = true;

    try {
      final items = await _trashRepository.getAllDeletedItems();
      _allTrashItems.assignAll(items);
      _applyFilters();
      await loadTrashStatistics();
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: 'خطأ',
        message: 'خطأ في تحميل سلة المحذوفات: $e',
      );
    } finally {
      if (showLoading) _isLoading.value = false;
    }
  }

  /// Load trash statistics
  Future<void> loadTrashStatistics() async {
    try {
      final stats = await _trashRepository.getTrashStatistics();
      _trashStats.assignAll(stats);
    } catch (e) {
      print('Error loading trash statistics: $e');
    }
  }

  /// Search trash items
  Future<void> searchTrashItems(String query) async {
    _searchQuery.value = query.trim();
    _isSearching.value = query.trim().isNotEmpty;

    if (query.trim().isEmpty) {
      _applyFilters();
      return;
    }

    try {
      final searchResults = await _trashRepository.searchDeletedItems(query);
      _filteredTrashItems.assignAll(_applyTypeFilter(searchResults));
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: 'خطأ',
        message: 'خطأ في البحث: $e',
      );
    }
  }

  /// Clear search
  void clearSearch() {
    _searchQuery.value = '';
    _isSearching.value = false;
    _applyFilters();
  }

  /// Set filter by type
  void setFilter(String filter) {
    _selectedFilter.value = filter;
    _applyFilters();
  }

  /// Apply current filters
  void _applyFilters() {
    List<TrashItemModel> items = List.from(_allTrashItems);

    // Apply type filter
    items = _applyTypeFilter(items);

    // Apply search filter if searching
    if (_isSearching.value && _searchQuery.value.isNotEmpty) {
      final query = _searchQuery.value.toLowerCase();
      items = items.where((item) {
        return item.title.toLowerCase().contains(query) ||
            (item.description?.toLowerCase().contains(query) ?? false) ||
            (item.parentInfo?.toLowerCase().contains(query) ?? false) ||
            item.typeDisplayName.toLowerCase().contains(query);
      }).toList();
    }

    _filteredTrashItems.assignAll(items);
  }

  /// Apply type filter
  List<TrashItemModel> _applyTypeFilter(List<TrashItemModel> items) {
    if (_selectedFilter.value == 'all') {
      return items;
    }
    return items.where((item) => item.type == _selectedFilter.value).toList();
  }

  /// Restore an item
  Future<void> restoreItem(TrashItemModel item) async {
    try {
      final success = await _trashRepository.restoreItem(item);
      if (success) {
        _allTrashItems.remove(item);
        _applyFilters();
        await loadTrashStatistics();
        _dialogService.showSuccessSnackbar(
          title: 'نجح',
          message: 'تم استعادة ${item.typeDisplayName} "${item.title}" بنجاح',
        );
      } else {
        _dialogService.showErrorSnackbar(
          title: 'خطأ',
          message: 'فشل في استعادة العنصر',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: 'خطأ',
        message: 'خطأ في استعادة العنصر: $e',
      );
    }
  }

  /// Permanently delete an item
  Future<void> permanentlyDeleteItem(TrashItemModel item) async {
    final confirmed = await _dialogService.confirm(
      title: 'حذف نهائي',
      message: 'هل أنت متأكد من حذف "${item.title}" نهائياً؟\nلا يمكن التراجع عن هذا الإجراء.',
      confirmText: 'حذف نهائي',
      cancelText: 'إلغاء',
    );

    if (!confirmed) return;

    try {
      final success = await _trashRepository.permanentlyDeleteItem(item);
      if (success) {
        _allTrashItems.remove(item);
        _applyFilters();
        await loadTrashStatistics();
        _dialogService.showSuccessSnackbar(
          title: 'نجح',
          message: 'تم حذف ${item.typeDisplayName} "${item.title}" نهائياً',
        );
      } else {
        _dialogService.showErrorSnackbar(
          title: 'خطأ',
          message: 'فشل في حذف العنصر نهائياً',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: 'خطأ',
        message: 'خطأ في حذف العنصر نهائياً: $e',
      );
    }
  }

  /// Empty entire trash
  Future<void> emptyTrash() async {
    if (_allTrashItems.isEmpty) {
      _dialogService.showSnack(
        title: 'معلومات',
        message: 'سلة المحذوفات فارغة بالفعل',
      );
      return;
    }

    final confirmed = await _dialogService.confirm(
      title: 'إفراغ سلة المحذوفات',
      message: 'هل أنت متأكد من حذف جميع العناصر نهائياً؟\nسيتم حذف ${_allTrashItems.length} عنصر ولا يمكن التراجع عن هذا الإجراء.',
      confirmText: 'إفراغ السلة',
      cancelText: 'إلغاء',
    );

    if (!confirmed) return;

    try {
      _isLoading.value = true;
      final deletedCount = await _trashRepository.emptyTrash();
      _allTrashItems.clear();
      _filteredTrashItems.clear();
      _trashStats.clear();
      await loadTrashStatistics();
      _dialogService.showSuccessSnackbar(
        title: 'نجح',
        message: 'تم حذف $deletedCount عنصر نهائياً من سلة المحذوفات',
      );
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: 'خطأ',
        message: 'خطأ في إفراغ سلة المحذوفات: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Clean old deleted items
  Future<void> cleanOldItems({int olderThanDays = 30}) async {
    final confirmed = await _dialogService.confirm(
      title: 'تنظيف العناصر القديمة',
      message: 'هل تريد حذف العناصر المحذوفة منذ أكثر من $olderThanDays يوم نهائياً؟',
      confirmText: 'تنظيف',
      cancelText: 'إلغاء',
    );

    if (!confirmed) return;

    try {
      _isLoading.value = true;
      final cleanedCount = await _trashRepository.cleanOldDeletedItems(
        olderThanDays: olderThanDays,
      );
      
      if (cleanedCount > 0) {
        await loadTrashItems(showLoading: false);
        _dialogService.showSuccessSnackbar(
          title: 'نجح',
          message: 'تم تنظيف $cleanedCount عنصر قديم من سلة المحذوفات',
        );
      } else {
        _dialogService.showSnack(
          title: 'معلومات',
          message: 'لا توجد عناصر قديمة للتنظيف',
        );
      }
    } catch (e) {
      _dialogService.showErrorSnackbar(
        title: 'خطأ',
        message: 'خطأ في تنظيف العناصر القديمة: $e',
      );
    } finally {
      _isLoading.value = false;
    }
  }

  /// Refresh trash items
  Future<void> refresh() async {
    await loadTrashItems(showLoading: false);
  }

  /// Get items by type
  List<TrashItemModel> getItemsByType(String type) {
    return _allTrashItems.where((item) => item.type == type).toList();
  }

  /// Get available filter options
  List<Map<String, dynamic>> get filterOptions {
    final options = [
      {'value': 'all', 'label': 'الكل', 'count': _allTrashItems.length},
    ];

    final typeCounts = <String, int>{};
    for (final item in _allTrashItems) {
      typeCounts[item.type] = (typeCounts[item.type] ?? 0) + 1;
    }

    final typeLabels = {
      'board': 'اللوحات',
      'list': 'القوائم',
      'card': 'البطاقات',
      'checklist': 'قوائم التحقق',
      'checklist_item': 'عناصر التحقق',
      'label': 'التسميات',
    };

    for (final entry in typeCounts.entries) {
      if (entry.value > 0) {
        options.add({
          'value': entry.key,
          'label': typeLabels[entry.key] ?? entry.key,
          'count': entry.value,
        });
      }
    }

    return options;
  }
}
