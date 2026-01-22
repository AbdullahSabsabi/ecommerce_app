import 'package:clothesecommerce/features/order/data/api/order_api.dart';
import 'package:clothesecommerce/features/order/data/models/order_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrdersApi ordersApi;
  OrderCubit(this.ordersApi) : super(OrderInitial());

  // 1️⃣ جلب كل الطلبات (Admin)
  Future<void> getAllOrders() async {
    emit(OrderLoading());
    try {
      final orders = await ordersApi.getAllOrders();
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // 2️⃣ جلب الطلبات الخاصة بمستخدم
  Future<void> getOrdersByUser(int userId) async {
    emit(OrderLoading());
    try {
      final orders = await ordersApi.getOrdersByUser(userId);
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError("حدث خطأ أثناء جلب الطلبات: $e"));
    }
  }

  // 3️⃣ إنشاء طلب جديد
  Future<void> createOrderFromJson(Map<String, dynamic> json) async {
    emit(OrderLoading());
    try {
      final newOrder = await ordersApi.createOrderJson(json);
      emit(OrderOperationSuccess('تم إنشاء الطلب بنجاح'));
      emit(OrderLoadedSingle(newOrder));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> createOrder(Order order) async {
    emit(OrderLoading());
    try {
      final newOrder = await ordersApi.createOrder(order);

      emit(OrderOperationSuccess('تم إنشاء الطلب بنجاح'));
      emit(OrderLoadedSingle(newOrder));
    } catch (e) {
      emit(OrderError("خطأ أثناء إنشاء الطلب: $e"));
    }
  }

  // 4️⃣ جلب تفاصيل طلب محدد
  Future<void> getOrderById(int id) async {
    emit(OrderLoading());
    try {
      final order = await ordersApi.getOrderById(id);
      emit(OrderLoadedSingle(order));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  // 5️⃣ تعديل طلب (مثلاً تحديث الحالة)
  // Cubit
  Future<void> updateOrder(Order order) async {
    emit(OrderLoading());
    try {
      // استدعاء API لتحديث الطلب
      final updatedOrder = await ordersApi.updateOrder(order);

      // نجاح العملية: رسالة قصيرة
      emit(OrderOperationSuccess('تم تحديث الطلب بنجاح'));

      // تحميل نسخة الطلب المعدل
      emit(OrderLoadedSingle(updatedOrder));
    } catch (e) {
      emit(OrderError('فشل تعديل الطلب: ${e.toString()}'));
    }
  }

  // 6️⃣ حذف طلب
  Future<void> deleteOrder(int id) async {
    emit(OrderLoading());
    try {
      await ordersApi.deleteOrder(id);
      emit(OrderOperationSuccess('تم حذف الطلب بنجاح'));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
