enum TransactionType { penjualan, pembelian }

class TransactionModel {
  final String id;
  final String title;
  final String price;
  final String date;
  final String status;
  final String imagePath;
  final String counterpartyName;
  final TransactionType type;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.price,
    required this.date,
    required this.status,
    required this.imagePath,
    required this.counterpartyName,
    required this.type,
  });

  static List<TransactionModel> dummyTransactions() {
    return const [
      TransactionModel(
        id: 'TRX-001',
        title: 'Buku Pemrograman Web',
        price: 'Rp 65.000',
        date: '28 Mei 2026',
        status: 'Selesai',
        imagePath: 'assets/images/rak_buku.jpg',
        counterpartyName: 'Laura',
        type: TransactionType.penjualan,
      ),
      TransactionModel(
        id: 'TRX-002',
        title: 'Kemeja Endek Bali',
        price: 'Rp 120.000',
        date: '25 Mei 2026',
        status: 'Dikirim',
        imagePath: 'assets/images/sweater.jpg',
        counterpartyName: 'Budi',
        type: TransactionType.penjualan,
      ),
      TransactionModel(
        id: 'TRX-003',
        title: 'Raket Badminton Yonex',
        price: 'Rp 250.000',
        date: '20 Mei 2026',
        status: 'Selesai',
        imagePath: 'assets/images/raket.jpg',
        counterpartyName: 'Wayan (Buleleng)',
        type: TransactionType.pembelian,
      ),
      TransactionModel(
        id: 'TRX-004',
        title: 'Hoodie H&M Navy',
        price: 'Rp 95.000',
        date: '15 Mei 2026',
        status: 'Dibatalkan',
        imagePath: 'assets/images/hoodie.jpeg',
        counterpartyName: 'Dimas',
        type: TransactionType.pembelian,
      ),
    ];
  }
}
