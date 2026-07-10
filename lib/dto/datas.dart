// ============================================================
// ProfileDto — mapping tabel 'profiles'
// ============================================================
class ProfileDto {
  final String id;
  final String? username;
  final String? fullName;
  final String? avatarUrl;
  final String? phone;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileDto({
    required this.id,
    this.username,
    this.fullName,
    this.avatarUrl,
    this.phone,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    return ProfileDto(
      id: json['id'] as String,
      username: json['username'] as String?,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'phone': phone,
      'location': location,
    };
  }
}

// ============================================================
// ProductDto — mapping tabel 'products'
// ============================================================
class ProductDto {
  final String id;
  final String sellerId;
  final String name;
  final String? description;
  final int price;
  final String condition;
  final String category;
  final String? location;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // relasi (dari join query)
  final ProfileDto? seller;
  final List<ProductImageDto> images;

  ProductDto({
    required this.id,
    required this.sellerId,
    required this.name,
    this.description,
    required this.price,
    required this.condition,
    required this.category,
    this.location,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.seller,
    this.images = const [],
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as String? ?? '',
      sellerId: json['seller_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Barang',
      description: json['description'] as String?,
      price: json['price'] as int? ?? 0,
      condition: json['condition'] as String? ?? 'Baik',
      category: json['category'] as String? ?? 'Lainnya',
      location: json['location'] as String?,
      status: json['status'] as String? ?? 'available',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      seller: json['profiles'] != null
          ? ProfileDto.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
      images: json['product_images'] != null
          ? (json['product_images'] as List<dynamic>)
              .map((e) => ProductImageDto.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'seller_id': sellerId,
      'name': name,
      'description': description,
      'price': price,
      'condition': condition,
      'category': category,
      'location': location,
      'status': status,
    };
  }
}

// ============================================================
// ProductImageDto — mapping tabel 'product_images'
// ============================================================
class ProductImageDto {
  final String id;
  final String productId;
  final String imageUrl;
  final int orderIndex;

  ProductImageDto({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.orderIndex,
  });

  factory ProductImageDto.fromJson(Map<String, dynamic> json) {
    return ProductImageDto(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      orderIndex: json['order_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'image_url': imageUrl,
      'order_index': orderIndex,
    };
  }
}

// ============================================================
// WishlistDto — mapping tabel 'wishlists'
// ============================================================
class WishlistDto {
  final String id;
  final String userId;
  final String productId;
  final DateTime createdAt;

  // relasi (dari join query)
  final ProductDto? product;

  WishlistDto({
    required this.id,
    required this.userId,
    required this.productId,
    required this.createdAt,
    this.product,
  });

  factory WishlistDto.fromJson(Map<String, dynamic> json) {
    final productsData = json['products'];
    ProductDto? parsedProduct;
    if (productsData != null) {
      if (productsData is List) {
        if (productsData.isNotEmpty) {
          parsedProduct = ProductDto.fromJson(productsData.first as Map<String, dynamic>);
        }
      } else if (productsData is Map) {
        parsedProduct = ProductDto.fromJson(productsData as Map<String, dynamic>);
      }
    }
    return WishlistDto(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      product: parsedProduct,
    );
  }
}

// ============================================================
// ChatDto — mapping tabel 'chats'
// ============================================================
class ChatDto {
  final String id;
  final String buyerId;
  final String sellerId;
  final String? productId;
  final DateTime lastMessageAt;

  // relasi
  final ProfileDto? buyer;
  final ProfileDto? seller;
  final ProductDto? product;

  ChatDto({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    this.productId,
    required this.lastMessageAt,
    this.buyer,
    this.seller,
    this.product,
  });

  factory ChatDto.fromJson(Map<String, dynamic> json) {
    return ChatDto(
      id: json['id'] as String,
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      productId: json['product_id'] as String?,
      lastMessageAt: DateTime.parse(json['last_message_at'] as String),
      buyer: json['buyer'] != null
          ? ProfileDto.fromJson(json['buyer'] as Map<String, dynamic>)
          : null,
      seller: json['seller'] != null
          ? ProfileDto.fromJson(json['seller'] as Map<String, dynamic>)
          : null,
      product: json['products'] != null
          ? ProductDto.fromJson(json['products'] as Map<String, dynamic>)
          : null,
    );
  }
}

// ============================================================
// MessageDto — mapping tabel 'messages'
// ============================================================
class MessageDto {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  MessageDto({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory MessageDto.fromJson(Map<String, dynamic> json) {
    return MessageDto(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
    };
  }
}

// ============================================================
// TransactionDto — mapping tabel 'transactions'
// ============================================================
class TransactionDto {
  final String id;
  final String buyerId;
  final String sellerId;
  final String? productId;
  final int price;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // relasi
  final ProfileDto? buyer;
  final ProfileDto? seller;
  final ProductDto? product;

  TransactionDto({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    this.productId,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.buyer,
    this.seller,
    this.product,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['id'] as String,
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      productId: json['product_id'] as String?,
      price: json['price'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      buyer: json['buyer'] != null
          ? ProfileDto.fromJson(json['buyer'] as Map<String, dynamic>)
          : null,
      seller: json['seller'] != null
          ? ProfileDto.fromJson(json['seller'] as Map<String, dynamic>)
          : null,
      product: json['products'] != null
          ? ProductDto.fromJson(json['products'] as Map<String, dynamic>)
          : null,
    );
  }
}
