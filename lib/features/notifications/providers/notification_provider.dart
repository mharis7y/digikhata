import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> loadNotifications() async {
    _setLoading(true);
    _clearError();
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      _notifications = (response as List).map((n) => AppNotification.fromJson(n)).toList();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendInAppNotification({
    required String title,
    required String body,
    String type = 'info',
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('notifications')
          .insert({
            'owner_id': userId,
            'title': title,
            'body': body,
            'type': type,
            'is_read': false,
          })
          .select()
          .single();

      final newNotification = AppNotification.fromJson(response);
      _notifications.insert(0, newNotification);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to send notification: $e');
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      try {
        await _supabase
            .from('notifications')
            .update({'is_read': true})
            .eq('id', id);

        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      } catch (e) {
        debugPrint('Failed to mark notification as read: $e');
      }
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('owner_id', userId)
          .eq('is_read', false);

      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to mark all notifications as read: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
