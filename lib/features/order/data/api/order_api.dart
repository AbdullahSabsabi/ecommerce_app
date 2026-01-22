import 'package:clothesecommerce/core/models/user_model.dart';
import 'package:clothesecommerce/features/order/data/models/order_model.dart';
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class OrdersApi {
  final Dio _dio;

  OrdersApi(this._dio);

  // 1️⃣ جلب كل الطلبات (لـ Admin)
  Future<List<Order>> getAllOrders() async {
    try {
      final response = await _dio.get('Orders');
      return (response.data as List)
          .map((orderJson) => Order.fromJson(orderJson))
          .toList();
    } on DioError catch (e) {
      throw ApiException(
        'فشل جلب كل الطلبات: ${e.response?.statusCode ?? ''} ${e.message}',
      );
    } catch (e) {
      throw ApiException('حدث خطأ غير متوقع أثناء جلب كل الطلبات');
    }
  }

  // 2️⃣ جلب كل الطلبات الخاصة بمستخدم محدد
  Future<List<Order>> getOrdersByUser(int userId) async {
    try {
      final response = await _dio.get('Orders/ByUser/$userId');

      // نتأكد أن response.data قائمة
      if (response.data is! List) {
        throw ApiException('تنسيق البيانات غير صحيح عند جلب الطلبات');
      }

      return (response.data as List).map((orderJson) {
        final jsonMap = orderJson as Map<String, dynamic>;

        // إذا لم يأتِ المستخدم ضمن JSON نستخدم User.empty()
        if (jsonMap['user'] == null) {
          jsonMap['user'] = User.empty().toJson();
        }

        return Order.fromJson(jsonMap);
      }).toList();
    } on DioError catch (e) {
      throw ApiException(
        'فشل جلب طلبات المستخدم: ${e.response?.statusCode ?? ''} ${e.message}',
      );
    } catch (e) {
      throw ApiException('حدث خطأ غير متوقع أثناء جلب طلبات المستخدم: $e');
    }
  }

  //3️⃣ إنشاء طلب جديد
  Future<Order> createOrder(Order order) async {
    try {
      final response = await _dio.post('Orders', data: order.toJson());

      // تأكد أن الريسبونس هو Map
      final data = response.data as Map<String, dynamic>;

      return Order.fromJson(data);
    } on DioError catch (e) {
      throw ApiException(
        'فشل إنشاء الطلب: ${e.response?.statusCode ?? ''} ${e.message}',
      );
    } catch (e) {
      throw ApiException('حدث خطأ غير متوقع أثناء إنشاء الطلب: $e');
    }
  }

  Future<Order> createOrderJson(Map<String, dynamic> json) async {
    try {
      final response = await _dio.post('Orders', data: json);
      return Order.fromJson(response.data);
    } on DioError catch (e) {
      throw ApiException(
        'فشل إنشاء الطلب: ${e.response?.statusCode ?? ''} ${e.message}',
      );
    } catch (e) {
      throw ApiException('حدث خطأ غير متوقع أثناء إنشاء الطلب');
    }
  }

  // 4️⃣ جلب تفاصيل طلب محدد
  Future<Order> getOrderById(int id) async {
    try {
      final response = await _dio.get('Orders/$id');
      return Order.fromJson(response.data);
    } on DioError catch (e) {
      throw ApiException(
        'فشل جلب تفاصيل الطلب: ${e.response?.statusCode ?? ''} ${e.message}',
      );
    } catch (e) {
      throw ApiException('حدث خطأ غير متوقع أثناء جلب تفاصيل الطلب');
    }
  }

  // 5️⃣ تعديل طلب (مثلاً تحديث الحالة)
  Future<Order> updateOrder(Order order) async {
    try {
      final response = await _dio.put(
        'Orders/${order.id}',
        data: order.toJson(), // إرسال الجسم الكامل كما شرحنا
      );

      return Order.fromJson(response.data);
    } on DioError catch (e) {
      throw ApiException(
        'فشل تعديل الطلب: ${e.response?.statusCode ?? ''} ${e.message}',
      );
    } catch (e) {
      throw ApiException('حدث خطأ غير متوقع أثناء تعديل الطلب');
    }
  }

  // 6️⃣ حذف طلب
  Future<void> deleteOrder(int id) async {
    try {
      await _dio.delete('Orders/$id');
    } on DioError catch (e) {
      throw ApiException(
        'فشل حذف الطلب: ${e.response?.statusCode ?? ''} ${e.message}',
      );
    } catch (e) {
      throw ApiException('حدث خطأ غير متوقع أثناء حذف الطلب');
    }
  }
}
