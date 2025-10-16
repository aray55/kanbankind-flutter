# KanbanKit - دليل الميزات الجديدة

## 📋 نظرة عامة

تم إضافة ميزات متقدمة جديدة إلى تطبيق KanbanKit تشمل:
- 💬 نظام التعليقات (Comments)
- 📎 نظام المرفقات (Attachments)
- 📊 سجل النشاطات (Activity Log)
- 🖼️ معرض الصور (Image Gallery)
- 📄 عارض الملفات (File Viewer)

---

## 💬 نظام التعليقات

### المكونات

#### 1. CommentWidget
عرض تعليق واحد مع إمكانية التعديل والحذف.

```dart
CommentWidget(
  comment: commentModel,
  onEdit: () => _editComment(),
  onDelete: () => _deleteComment(),
  showActions: true,
)
```

#### 2. CommentsListWidget
قائمة جميع التعليقات مع إمكانية الإضافة.

```dart
CommentsListWidget(
  cardId: cardId,
  showAddComment: true,
  showHeader: true,
)
```

#### 3. AddCommentWidget
حقل إدخال قابل للتوسع لإضافة تعليقات جديدة.

```dart
AddCommentWidget(cardId: cardId)
```

### الاستخدام

```dart
// في Card Details Modal
Tab(text: LocalKeys.comments.tr),

// في TabBarView
CommentsListWidget(
  cardId: card.id!,
  showAddComment: true,
  showHeader: false,
),
```

---

## 📎 نظام المرفقات

### المكونات

#### 1. AttachmentWidget
عرض مرفق واحد مع معاينة وأزرار الإجراءات.

```dart
AttachmentWidget(
  attachment: attachmentModel,
  onView: () => _viewFile(),
  onDelete: () => _deleteFile(),
  showActions: true,
)
```

#### 2. AttachmentsListWidget
قائمة جميع المرفقات مع إمكانية الإضافة.

```dart
AttachmentsListWidget(
  cardId: cardId,
  showAddButton: true,
  showHeader: true,
)
```

#### 3. FileViewerScreen
عارض ملفات بشاشة كاملة.

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => FileViewerScreen(
      attachment: attachment,
    ),
  ),
);
```

#### 4. ImageGalleryScreen
معرض صور مع إمكانية التنقل والتكبير.

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ImageGalleryScreen(
      images: imagesList,
      initialIndex: 0,
    ),
  ),
);
```

### أنواع الملفات المدعومة

- 📷 **Images**: jpg, jpeg, png, gif, bmp, webp, svg
- 📄 **Documents**: pdf, doc, docx, xls, xlsx, ppt, pptx, txt
- 🎥 **Videos**: mp4, avi, mov, wmv, flv, mkv
- 🎵 **Audio**: mp3, wav, ogg, flac, m4a

---

## 📊 سجل النشاطات

### المكونات

#### 1. ActivityItemWidget
عرض نشاط واحد مع أيقونة ملونة.

```dart
ActivityItemWidget(activity: activityModel)
```

#### 2. ActivityTimelineWidget
عرض Timeline مجمع حسب التاريخ.

```dart
ActivityTimelineWidget(
  cardId: cardId,
  showHeader: true,
  limit: 50,
)
```

### أنواع الإجراءات

| الإجراء | اللون | الأيقونة |
|---------|-------|----------|
| Created | 🟢 أخضر | add_circle_outline |
| Updated | 🔵 أزرق | edit_outlined |
| Deleted | 🔴 أحمر | delete_outline |
| Moved | 🟣 بنفسجي | swap_horiz |
| Archived | 🟠 برتقالي | archive_outlined |
| Restored | 🔷 تركواز | restore |
| Completed | 🟢 أخضر | check_circle_outline |
| Uncompleted | ⚪ رمادي | radio_button_unchecked |

### أنواع الكيانات

- Board (لوحة)
- List (قائمة)
- Card (بطاقة)
- Checklist (قائمة تحقق)
- Comment (تعليق)
- Attachment (مرفق)
- Label (تسمية)

---

## 🎴 Card Detail Modal المحدث

### CardDetailModalTabbed

نسخة محدثة من Card Detail Modal مع 4 تبويبات:

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => CardDetailModalTabbed(
    card: card,
  ),
);
```

### التبويبات

1. **📋 Details** - المعلومات الأساسية
   - Status
   - Due Date
   - Labels
   - Description
   - Checklists
   - Actions

2. **💬 Comments** - التعليقات
   - قائمة التعليقات
   - إضافة تعليق جديد
   - تعديل وحذف التعليقات

3. **📎 Attachments** - المرفقات
   - قائمة المرفقات
   - إضافة ملفات/صور
   - عرض وحذف المرفقات

4. **📊 Activity** - سجل النشاطات
   - Timeline مجمع حسب التاريخ
   - جميع الإجراءات على البطاقة

---

## 🔧 التكامل مع التطبيق

### 1. تحديث CardBinding

تأكد من إضافة Controllers الجديدة في `card_binding.dart`:

```dart
Get.lazyPut<CommentController>(() => CommentController());
Get.lazyPut<AttachmentController>(() => AttachmentController());
Get.lazyPut<ActivityLogController>(() => ActivityLogController());
```

### 2. استبدال Card Detail Modal

في الملفات التي تستخدم `CardDetailModal`، استبدلها بـ `CardDetailModalTabbed`:

```dart
// القديم
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => CardDetailModal(card: card),
);

// الجديد
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => CardDetailModalTabbed(card: card),
);
```

### 3. إضافة Dependencies

تأكد من إضافة هذه الـ packages في `pubspec.yaml`:

```yaml
dependencies:
  timeago: ^3.6.1  # لعرض الوقت النسبي
  file_picker: ^6.1.1  # لاختيار الملفات
```

---

## 🎨 التخصيص

### تخصيص الألوان

يمكنك تخصيص ألوان أنواع الإجراءات في `ActivityItemWidget`:

```dart
Color _getActionColor(ThemeData theme) {
  switch (activity.actionType) {
    case ActionType.created:
      return Colors.green;  // يمكن تغييره
    // ...
  }
}
```

### تخصيص أنواع الملفات

يمكنك إضافة امتدادات ملفات جديدة في `AttachmentsListWidget`:

```dart
String _determineFileType(String? extension) {
  final imageExtensions = ['jpg', 'jpeg', 'png', /* أضف المزيد */];
  // ...
}
```

---

## 📝 ملاحظات مهمة

### 1. Activity Logging

لتسجيل النشاطات تلقائياً، يجب استدعاء `ActivityLogController` في جميع العمليات:

```dart
// مثال: عند إنشاء بطاقة
await activityLogController.logCardActivity(
  cardId: cardId,
  actionType: ActionType.created,
  description: 'Created new card',
);
```

### 2. File Storage

المرفقات يتم حفظها في مسار الملف المحلي. تأكد من:
- إدارة الأذونات بشكل صحيح
- حذف الملفات عند الحذف النهائي
- النسخ الاحتياطي للملفات المهمة

### 3. Performance

لتحسين الأداء:
- استخدم `limit` في `ActivityTimelineWidget`
- قم بتحميل المرفقات بشكل lazy
- استخدم pagination للتعليقات الكثيرة

---

## 🐛 استكشاف الأخطاء

### مشكلة: التعليقات لا تظهر

**الحل:**
```dart
// تأكد من تحميل التعليقات
commentController.loadCommentsForCard(cardId);
```

### مشكلة: الملفات لا تفتح

**الحل:**
```dart
// تحقق من وجود الملف
if (attachment.fileExists) {
  // افتح الملف
}
```

### مشكلة: Activity Log فارغ

**الحل:**
```dart
// تأكد من تسجيل النشاطات
await activityLogController.logCardActivity(...);
```

---

## 🚀 الميزات المستقبلية

- [ ] Push Notifications للتعليقات الجديدة
- [ ] Rich Text Editor للتعليقات
- [ ] File Upload Progress
- [ ] Share Functionality
- [ ] Download Manager
- [ ] Video Player
- [ ] PDF Viewer
- [ ] Audio Player
- [ ] Mentions في التعليقات (@user)
- [ ] Reactions على التعليقات (👍, ❤️, etc.)

---

## 📚 المراجع

- [GetX Documentation](https://pub.dev/packages/get)
- [File Picker Documentation](https://pub.dev/packages/file_picker)
- [Timeago Documentation](https://pub.dev/packages/timeago)

---

## 👨‍💻 المساهمة

لإضافة ميزات جديدة أو إصلاح أخطاء:

1. Fork المشروع
2. أنشئ branch جديد (`git checkout -b feature/AmazingFeature`)
3. Commit التغييرات (`git commit -m 'Add some AmazingFeature'`)
4. Push إلى Branch (`git push origin feature/AmazingFeature`)
5. افتح Pull Request

---

## 📄 الترخيص

هذا المشروع مرخص تحت MIT License.

---

تم إنشاء هذا الدليل في: أكتوبر 2025
