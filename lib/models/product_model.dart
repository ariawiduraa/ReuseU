class Product {
  final String id;
  final String image;
  final String name;
  final String condition;
  final String category;
  final String price;
  final int priceValue;
  final String location;
  final String description;
  final String sellerName;
  final String sellerImage;
  final DateTime postedAt;

  const Product({
    required this.id,
    required this.image,
    required this.name,
    required this.condition,
    required this.category,
    required this.price,
    required this.priceValue,
    required this.location,
    this.description = '',
    this.sellerName = '',
    this.sellerImage = '',
    required this.postedAt,
  });

  static List<Product> dummyProducts() {
    return [
      Product(
        id: '1',
        image: 'assets/images/hoodie.jpeg',
        name: 'Hoodie H&M Navy',
        condition: 'Seperti Baru',
        category: 'Pakaian',
        price: 'Rp 95.000',
        priceValue: 95000,
        location: 'Surabaya',
        description:
            'Hoodie H&M Navy original, size L. Baru dipakai 2x, masih sangat bagus. Jual karena sudah tidak muat.',
        sellerName: 'Arya Store',
        sellerImage: '',
        postedAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Product(
        id: '2',
        image: 'assets/images/rak_buku.jpg',
        name: 'Rak Buku Minimalis',
        condition: 'Baik',
        category: 'Perabotan',
        price: 'Rp 180.000',
        priceValue: 180000,
        location: 'Jatinangor',
        description:
            'Rak buku 4 tingkat, kayu solid. Cocok untuk kamar kos. Masih kokoh dan rapi.',
        sellerName: 'Dimas',
        sellerImage: '',
        postedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Product(
        id: '3',
        image: 'assets/images/raket.jpg',
        name: 'Raket Badminton Yonex',
        condition: 'Baik',
        category: 'Olahraga',
        price: 'Rp 250.000',
        priceValue: 250000,
        location: 'Asrama Keputih',
        description:
            'Raket Yonex Astrox 77, grip sudah diganti baru. Senar masih tegang. Bonus shuttlecock 3 pcs.',
        sellerName: 'Kevin',
        sellerImage: '',
        postedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Product(
        id: '4',
        image: 'assets/images/sweater.jpg',
        name: 'Sweater Uniqlo Abu-abu',
        condition: 'Seperti Baru',
        category: 'Pakaian',
        price: 'Rp 85.000',
        priceValue: 85000,
        location: 'Kos Mawar, Malang',
        description:
            'Sweater Uniqlo original size M. Warna abu-abu muda. Bahan lembut dan hangat.',
        sellerName: 'Nadia',
        sellerImage: '',
        postedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Product(
        id: '5',
        image: 'assets/images/hoodie.jpeg',
        name: 'Kalkulator Scientific Casio',
        condition: 'Baru',
        category: 'Elektronik',
        price: 'Rp 120.000',
        priceValue: 120000,
        location: 'Kampus ITS',
        description:
            'Kalkulator Casio FX-991ID Plus, masih segel. Beli double jadi dijual satu.',
        sellerName: 'Fajar',
        sellerImage: '',
        postedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Product(
        id: '6',
        image: 'assets/images/rak_buku.jpg',
        name: 'Buku Fisika Dasar Halliday',
        condition: 'Baik',
        category: 'Buku & Alat Tulis',
        price: 'Rp 65.000',
        priceValue: 65000,
        location: 'Gedung E UNAIR',
        description:
            'Buku Fisika Dasar jilid 1 edisi 10. Ada sedikit coretan pensil, bisa dihapus.',
        sellerName: 'Arya Store',
        sellerImage: '',
        postedAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Product(
        id: '7',
        image: 'assets/images/raket.jpg',
        name: 'Dumbbell 5kg Set',
        condition: 'Seperti Baru',
        category: 'Olahraga',
        price: 'Rp 150.000',
        priceValue: 150000,
        location: 'Asrama UNDIP',
        description:
            'Dumbbell rubber coating 5kg sepasang. Nyaman digenggam, tidak licin.',
        sellerName: 'Kevin',
        sellerImage: '',
        postedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Product(
        id: '8',
        image: 'assets/images/sweater.jpg',
        name: 'Lampu Meja LED',
        condition: 'Layak Pakai',
        category: 'Perabotan',
        price: 'Rp 45.000',
        priceValue: 45000,
        location: 'Kos Dahlia, Depok',
        description:
            'Lampu meja LED adjustable 3 mode. Baterai masih awet. USB charging.',
        sellerName: 'Nadia',
        sellerImage: '',
        postedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
}
