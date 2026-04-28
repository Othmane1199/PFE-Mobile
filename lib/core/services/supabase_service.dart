import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';
import '../models/client.dart';
import '../models/service.dart';
import '../models/order.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Authentication
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password, {Map<String, dynamic>? data}) async {
    return await _client.auth.signUp(email: email, password: password, data: data);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  User? get currentUser => _client.auth.currentUser;
  
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> updateUserMetadata(Map<String, dynamic> metadata) async {
    await _client.auth.updateUser(UserAttributes(data: metadata));
  }

  // Products Table
  Future<List<Product>> getProducts() async {
    final response = await _client.from('products').select().order('created_at', ascending: false);
    return response.map((e) => Product.fromMap(e)).toList();
  }

  Future<void> addProduct(Product product) async {
    await _client.from('products').insert(product.toMap());
  }

  Future<void> updateProduct(Product product) async {
    await _client.from('products').update(product.toMap()).eq('id', product.id);
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  // Clients Table
  Future<List<Client>> getClients() async {
    final response = await _client.from('clients').select().order('created_at', ascending: false);
    return response.map((e) => Client.fromMap(e)).toList();
  }

  Future<Client> createClient(Client client) async {
    final response = await _client.from('clients').insert(client.toMap()).select().single();
    return Client.fromMap(response);
  }

  Future<void> updateClient(Client client) async {
    await _client.from('clients').update(client.toMap()).eq('id', client.id);
  }

  Future<void> deleteClient(String id) async {
    await _client.from('clients').delete().eq('id', id);
  }

  // Services Table
  Future<List<ServiceTask>> getServices() async {
    final response = await _client.from('services').select().order('created_at', ascending: false);
    return response.map((e) => ServiceTask.fromMap(e)).toList();
  }

  Future<void> addService(ServiceTask service) async {
    await _client.from('services').insert(service.toMap());
  }

  Future<void> updateService(ServiceTask service) async {
    await _client.from('services').update(service.toMap()).eq('id', service.id);
  }

  Future<void> deleteService(String id) async {
    await _client.from('services').delete().eq('id', id);
  }

  // Orders Table
  Future<List<Order>> getOrders() async {
    final response = await _client.from('orders').select().order('created_at', ascending: false);
    
    // We should ideally fetch all order_items and map them
    // For simplicity without complex joins, we do separate calls or a single items call.
    final itemsResponse = await _client.from('order_items').select();
    final allItems = itemsResponse.map((e) => OrderItem.fromMap(e)).toList();

    return response.map((orderMap) {
      final orderId = orderMap['id'].toString();
      final orderItems = allItems.where((i) => i.orderId == orderId).toList();
      return Order.fromMap(orderMap, orderItems);
    }).toList();
  }

  Future<void> createOrder(Order order) async {
    // 1. Create order
    final orderResp = await _client.from('orders').insert(order.toMap()).select().single();
    final newOrderId = orderResp['id'].toString();

    // 2. Insert items and update stock
    for (var item in order.items) {
      await _client.from('order_items').insert({
        'order_id': newOrderId,
        'product_id': item.productId,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
      });

      // Fetch current product to update stock
      final prodResp = await _client.from('products').select().eq('id', item.productId).single();
      final currentStock = prodResp['stock_quantity'] as int? ?? 0;
      final newStock = currentStock - item.quantity;
      if(newStock >= 0) {
        await _client.from('products').update({'stock_quantity': newStock}).eq('id', item.productId);
      }
    }
  }

  Future<void> deleteOrder(String id) async {
    await _client.from('orders').delete().eq('id', id);
  }
}
