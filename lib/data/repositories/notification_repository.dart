import '../models/notification_model.dart';

class NotificationRepository {
  final List<NotificationItem> _notifications = [];

  NotificationRepository() {
    _initializeSeedData();
  }

  void _initializeSeedData() {
    final now = DateTime.now();
    final userId = 'user_001';

    final seedNotifications = [
      NotificationItem(
        id: 'notif_001',
        userId: userId,
        type: 'budget_warning',
        title: 'Budget Alert',
        message:
            'You have used 75% of your Food budget for this month.',
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationItem(
        id: 'notif_002',
        userId: userId,
        type: 'goal_reminder',
        title: 'Savings Goal Update',
        message:
            'You are 30% towards your Emergency Fund goal. Keep it up!',
        isRead: false,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationItem(
        id: 'notif_003',
        userId: userId,
        type: 'weekly_summary',
        title: 'Weekly Summary',
        message:
            'Last week you spent UGX 125,000. This is 15% less than the previous week.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      NotificationItem(
        id: 'notif_004',
        userId: userId,
        type: 'budget_warning',
        title: 'Budget Alert',
        message:
            'You have exceeded your Transport budget by UGX 12,000 this month.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      NotificationItem(
        id: 'notif_005',
        userId: userId,
        type: 'goal_reminder',
        title: 'Goal Deadline Approaching',
        message:
            'Your New Laptop goal is due in 4 months. Current progress: 20%',
        isRead: false,
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      NotificationItem(
        id: 'notif_006',
        userId: userId,
        type: 'tip',
        title: 'Money Saving Tip',
        message:
            'Try preparing meals at home to save an average of UGX 50,000 per month.',
        isRead: true,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ];

    _notifications.addAll(seedNotifications);
  }

  Future<List<NotificationItem>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List.unmodifiable(_notifications);
  }

  Future<NotificationItem?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _notifications.firstWhere((notif) => notif.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<NotificationItem>> getByUserId(String userId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _notifications
        .where((notif) => notif.userId == userId)
        .toList();
  }

  Future<int> getUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _notifications.where((notif) => !notif.isRead).length;
  }

  Future<void> create(NotificationItem notification) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _notifications.add(notification);
  }

  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _notifications.indexWhere((notif) => notif.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  Future<void> markAllAsRead() async {
    await Future.delayed(const Duration(milliseconds: 50));
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _notifications.removeWhere((notif) => notif.id == id);
  }
}
