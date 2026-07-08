import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:reuseu/dto/datas.dart';
import 'package:reuseu/endpoints/endpoints.dart';

final _supabase = Supabase.instance.client;

// ============================================================
// ProductService
// ============================================================
class ProductService {
  /// Ambil semua produk yang tersedia, beserta seller & gambarnya
  static Future<List<ProductDto>> fetchProducts() async {
    final data = await _supabase
        .from(Endpoints.tableProducts)
        .select('''
          *,
          profiles!seller_id ( id, username, full_name, avatar_url, location, phone ),
          product_images ( id, product_id, image_url, order_index )
        ''')
        .eq('status', 'available')
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((item) => ProductDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Ambil produk berdasarkan kategori
  static Future<List<ProductDto>> fetchProductsByCategory(
    String category,
  ) async {
    final data = await _supabase
        .from(Endpoints.tableProducts)
        .select('''
          *,
          profiles!seller_id ( id, username, full_name, avatar_url, location, phone ),
          product_images ( id, product_id, image_url, order_index )
        ''')
        .eq('status', 'available')
        .eq('category', category)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((item) => ProductDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Ambil produk milik user yang sedang login (untuk halaman Lapak)
  static Future<List<ProductDto>> fetchMyProducts() async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from(Endpoints.tableProducts)
        .select('''
          *,
          product_images ( id, product_id, image_url, order_index )
        ''')
        .eq('seller_id', userId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((item) => ProductDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Tambah produk baru beserta gambar-gambarnya
  static Future<ProductDto> addProduct({
    required String name,
    required String description,
    required int price,
    required String condition,
    required String category,
    required String location,
    required List<String> imageUrls,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    // Insert produk ke tabel products
    final result = await _supabase
        .from(Endpoints.tableProducts)
        .insert({
          'seller_id': userId,
          'name': name,
          'description': description,
          'price': price,
          'condition': condition,
          'category': category,
          'location': location,
        })
        .select()
        .single();

    final product = ProductDto.fromJson(result as Map<String, dynamic>);

    // Insert semua gambar ke tabel product_images
    if (imageUrls.isNotEmpty) {
      final imageRows = imageUrls
          .asMap()
          .entries
          .map(
            (e) => {
              'product_id': product.id,
              'image_url': e.value,
              'order_index': e.key,
            },
          )
          .toList();
      await _supabase.from(Endpoints.tableProductImages).insert(imageRows);
    }

    return product;
  }

  /// Upload gambar (bytes) ke Storage — bekerja di web & mobile
  static Future<String> uploadProductImageBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final userId = _supabase.auth.currentUser!.id;
    final storagePath = '$userId/$fileName';

    await _supabase.storage
        .from(Endpoints.bucketProductImages)
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    return _supabase.storage
        .from(Endpoints.bucketProductImages)
        .getPublicUrl(storagePath);
  }

  /// Hapus produk beserta gambarnya
  static Future<void> deleteProduct(String productId) async {
    // Hapus dulu product_images, lalu product (karena FK)
    await _supabase
        .from(Endpoints.tableProductImages)
        .delete()
        .eq('product_id', productId);
    await _supabase.from(Endpoints.tableProducts).delete().eq('id', productId);
  }

  /// Update status produk (available / sold)
  static Future<void> updateProductStatus(
    String productId,
    String status,
  ) async {
    await _supabase
        .from(Endpoints.tableProducts)
        .update({'status': status})
        .eq('id', productId);
  }

  /// Update detail produk
  static Future<void> updateProduct({
    required String productId,
    required String name,
    required String description,
    required int price,
    required String condition,
    required String category,
    required String location,
  }) async {
    await _supabase
        .from(Endpoints.tableProducts)
        .update({
          'name': name,
          'description': description,
          'price': price,
          'condition': condition,
          'category': category,
          'location': location,
        })
        .eq('id', productId);
  }
}

// ============================================================
// WishlistService
// ============================================================
class WishlistService {
  /// Ambil semua wishlist user yang sedang login
  static Future<List<WishlistDto>> fetchWishlists() async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from(Endpoints.tableWishlists)
        .select('''
          *,
          products (
            *,
            profiles!seller_id ( id, username, full_name, avatar_url, location, phone ),
            product_images ( id, product_id, image_url, order_index )
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((item) => WishlistDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Cek apakah produk sudah di-wishlist user
  static Future<bool> isWishlisted(String productId) async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from(Endpoints.tableWishlists)
        .select('id')
        .eq('user_id', userId)
        .eq('product_id', productId);

    return (data as List).isNotEmpty;
  }

  /// Toggle wishlist (tambah / hapus)
  static Future<bool> toggleWishlist(String productId) async {
    final userId = _supabase.auth.currentUser!.id;
    final isAlreadySaved = await isWishlisted(productId);

    if (isAlreadySaved) {
      await _supabase
          .from(Endpoints.tableWishlists)
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
      return false;
    } else {
      await _supabase.from(Endpoints.tableWishlists).insert({
        'user_id': userId,
        'product_id': productId,
      });
      return true;
    }
  }

  /// Hapus satu item dari wishlist langsung
  static Future<void> removeFromWishlist(String productId) async {
    final userId = _supabase.auth.currentUser!.id;
    await _supabase
        .from(Endpoints.tableWishlists)
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }
}

// ============================================================
// ChatService
// ============================================================
class ChatService {
  /// Ambil semua chat user yang sedang login
  static Future<List<ChatDto>> fetchChats() async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from(Endpoints.tableChats)
        .select('''
          *,
          buyer:profiles!buyer_id ( id, username, full_name, avatar_url ),
          seller:profiles!seller_id ( id, username, full_name, avatar_url ),
          products ( id, name )
        ''')
        .or('buyer_id.eq.$userId,seller_id.eq.$userId')
        .order('last_message_at', ascending: false);

    return (data as List<dynamic>)
        .map((item) => ChatDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Ambil semua pesan dalam satu chat
  static Future<List<MessageDto>> fetchMessages(String chatId) async {
    final data = await _supabase
        .from(Endpoints.tableMessages)
        .select('*')
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);

    return (data as List<dynamic>)
        .map((item) => MessageDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Kirim pesan baru
  static Future<MessageDto> sendMessage({
    required String chatId,
    required String content,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    final result = await _supabase
        .from(Endpoints.tableMessages)
        .insert({'chat_id': chatId, 'sender_id': userId, 'content': content})
        .select()
        .single();

    return MessageDto.fromJson(result as Map<String, dynamic>);
  }

  /// Buat atau ambil chat yang sudah ada antara buyer & seller untuk produk tertentu
  static Future<ChatDto> getOrCreateChat({
    required String sellerId,
    required String productId,
  }) async {
    final buyerId = _supabase.auth.currentUser!.id;

    // Cek apakah chat sudah ada
    final existing = await _supabase
        .from(Endpoints.tableChats)
        .select('*')
        .eq('buyer_id', buyerId)
        .eq('seller_id', sellerId)
        .eq('product_id', productId);

    if ((existing as List).isNotEmpty) {
      return ChatDto.fromJson(existing.first as Map<String, dynamic>);
    }

    // Buat chat baru
    final result = await _supabase
        .from(Endpoints.tableChats)
        .insert({
          'buyer_id': buyerId,
          'seller_id': sellerId,
          'product_id': productId,
        })
        .select()
        .single();

    return ChatDto.fromJson(result as Map<String, dynamic>);
  }

  /// Subscribe realtime ke pesan baru dalam chat
  static RealtimeChannel subscribeToMessages({
    required String chatId,
    required void Function(MessageDto message) onNewMessage,
  }) {
    return _supabase
        .channel('messages:$chatId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: Endpoints.tableMessages,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_id',
            value: chatId,
          ),
          callback: (payload) {
            final message = MessageDto.fromJson(
              payload.newRecord as Map<String, dynamic>,
            );
            onNewMessage(message);
          },
        )
        .subscribe();
  }
}

// ============================================================
// TransactionService
// ============================================================
class TransactionService {
  /// Ambil riwayat transaksi user (baik sebagai buyer maupun seller)
  static Future<List<TransactionDto>> fetchTransactions() async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from(Endpoints.tableTransactions)
        .select('''
          *,
          buyer:profiles!buyer_id ( id, username, full_name, avatar_url ),
          seller:profiles!seller_id ( id, username, full_name, avatar_url ),
          products ( id, name, product_images ( image_url, order_index ) )
        ''')
        .or('buyer_id.eq.$userId,seller_id.eq.$userId')
        .order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((item) => TransactionDto.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Buat transaksi baru
  static Future<TransactionDto> createTransaction({
    required String sellerId,
    required String productId,
    required int price,
  }) async {
    final buyerId = _supabase.auth.currentUser!.id;

    final result = await _supabase
        .from(Endpoints.tableTransactions)
        .insert({
          'buyer_id': buyerId,
          'seller_id': sellerId,
          'product_id': productId,
          'price': price,
          'status': 'pending',
        })
        .select()
        .single();

    return TransactionDto.fromJson(result as Map<String, dynamic>);
  }

  /// Update status transaksi
  static Future<void> updateStatus({
    required String transactionId,
    required String status,
  }) async {
    await _supabase
        .from(Endpoints.tableTransactions)
        .update({'status': status})
        .eq('id', transactionId);
  }
}

// ============================================================
// ProfileService
// ============================================================
class ProfileService {
  /// Ambil profile user yang sedang login
  static Future<ProfileDto> fetchMyProfile() async {
    final userId = _supabase.auth.currentUser!.id;

    final data = await _supabase
        .from(Endpoints.tableProfiles)
        .select('*')
        .eq('id', userId)
        .single();

    return ProfileDto.fromJson(data as Map<String, dynamic>);
  }

  /// Update profile
  static Future<void> updateProfile({
    String? username,
    String? fullName,
    String? phone,
    String? location,
    String? avatarUrl,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    final updates = <String, dynamic>{};
    if (username != null) updates['username'] = username;
    if (fullName != null) updates['full_name'] = fullName;
    if (phone != null) updates['phone'] = phone;
    if (location != null) updates['location'] = location;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _supabase
        .from(Endpoints.tableProfiles)
        .update(updates)
        .eq('id', userId);
  }
}

// ============================================================
// AuthService
// ============================================================
class AuthService {
  /// Register akun baru
  static Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  /// Login
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  /// Logout
  static Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// Cek apakah user sudah login
  static bool get isLoggedIn => _supabase.auth.currentUser != null;

  /// ID user yang sedang login
  static String? get currentUserId => _supabase.auth.currentUser?.id;
}
