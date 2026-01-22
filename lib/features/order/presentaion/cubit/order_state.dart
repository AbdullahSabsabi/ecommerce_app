import 'package:clothesecommerce/features/order/data/models/order_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Order> orders;
  OrderLoaded(this.orders);
}

class OrderLoadedSingle extends OrderState {
  final Order order;
  OrderLoadedSingle(this.order);
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}

class OrderOperationSuccess extends OrderState {
  final String message;
  OrderOperationSuccess(this.message);
}
