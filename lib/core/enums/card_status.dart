import 'package:get/get.dart';

enum CardStatus {
  backlog,
  todo,
  inProgress,
  blocked,
  inReview,
  done;

  String get value {
    switch (this) {
      case CardStatus.backlog:
        return 'backlog';
      case CardStatus.todo:
        return 'todo';
      case CardStatus.inProgress:
        return 'in_progress';
      case CardStatus.blocked:
        return 'blocked';
      case CardStatus.inReview:
        return 'in_review';
      case CardStatus.done:
        return 'done';
    }
  }

  String getDisplayName() {
    switch (this) {
      case CardStatus.backlog:
        return 'backlog'.tr;
      case CardStatus.todo:
        return 'todo'.tr;
      case CardStatus.inProgress:
        return 'inProgress'.tr;
      case CardStatus.blocked:
        return 'blocked'.tr;
      case CardStatus.inReview:
        return 'inReview'.tr;
      case CardStatus.done:
        return 'done'.tr;
    }
  }

  static CardStatus fromString(String value) {
    switch (value) {
      case 'backlog':
        return CardStatus.backlog;
      case 'todo':
        return CardStatus.todo;
      case 'in_progress':
        return CardStatus.inProgress;
      case 'blocked':
        return CardStatus.blocked;
      case 'in_review':
        return CardStatus.inReview;
      case 'done':
        return CardStatus.done;
      default:
        return CardStatus.todo;
    }
  }
}
