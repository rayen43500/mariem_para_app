class Delivery {
  final String id;
  final String clientName;
  final String address;
  final String phone;
  final String status;
  final DateTime dateTime;
  final List<DeliveryItem> items;
  final double total;
  final String paymentMethod;
  final bool isPaid;
  final String notes;
  final double distance;
  final int estimatedTime; // en minutes

  Delivery({
    required this.id,
    required this.clientName,
    required this.address,
    required this.phone,
    required this.status,
    required this.dateTime,
    required this.items,
    required this.total,
    required this.paymentMethod,
    required this.isPaid,
    this.notes = '',
    this.distance = 0.0,
    this.estimatedTime = 0,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    List<DeliveryItem> itemsList = [];
    if (json['items'] != null) {
      itemsList = List<DeliveryItem>.from(
        json['items'].map((item) => DeliveryItem.fromJson(item)),
      );
    }

    return Delivery(
      id: json['_id'] ?? json['id'] ?? '',
      clientName: json['clientName'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 'En attente',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
      items: itemsList,
      total: json['total']?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? 'Espèces',
      isPaid: json['isPaid'] ?? false,
      notes: json['notes'] ?? '',
      distance: json['distance']?.toDouble() ?? 0.0,
      estimatedTime: json['estimatedTime'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientName': clientName,
      'address': address,
      'phone': phone,
      'status': status,
      'dateTime': dateTime.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'notes': notes,
      'distance': distance,
      'estimatedTime': estimatedTime,
    };
  }

  // Méthode pour obtenir une couleur en fonction du statut
  static String getStatusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'en attente':
        return '⏱️';
      case 'en cours':
        return '🚚';
      case 'livrée':
        return '✅';
      case 'annulée':
        return '❌';
      default:
        return '📦';
    }
  }

  static List<Delivery> getDummyData() {
    return [
      Delivery(
        id: 'DEL001',
        clientName: 'Ahmed Benali',
        address: '15 Rue des Oliviers, Tunis',
        phone: '+21698765432',
        status: 'En attente',
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        items: [
          DeliveryItem(
            name: 'Paracétamol 500mg',
            quantity: 2,
            price: 5.99,
          ),
          DeliveryItem(
            name: 'Sirop pour la toux',
            quantity: 1,
            price: 12.50,
          ),
        ],
        total: 24.48,
        paymentMethod: 'Espèces',
        isPaid: false,
        distance: 3.2,
        estimatedTime: 15,
      ),
      Delivery(
        id: 'DEL002',
        clientName: 'Fatima Zahra',
        address: '7 Avenue Habib Bourguiba, Sousse',
        phone: '+21655443322',
        status: 'En cours',
        dateTime: DateTime.now().add(const Duration(minutes: 30)),
        items: [
          DeliveryItem(
            name: 'Vitamine C',
            quantity: 1,
            price: 8.75,
          ),
          DeliveryItem(
            name: 'Masque facial',
            quantity: 5,
            price: 2.99,
          ),
        ],
        total: 23.70,
        paymentMethod: 'Carte Bancaire',
        isPaid: true,
        distance: 1.8,
        estimatedTime: 10,
      ),
      Delivery(
        id: 'DEL003',
        clientName: 'Mohammed Khairi',
        address: '22 Rue Ibn Khaldoun, Sfax',
        phone: '+21699887766',
        status: 'Livrée',
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
        items: [
          DeliveryItem(
            name: 'Thermomètre digital',
            quantity: 1,
            price: 15.99,
          ),
        ],
        total: 15.99,
        paymentMethod: 'Espèces',
        isPaid: true,
        distance: 4.5,
        estimatedTime: 20,
      ),
      Delivery(
        id: 'DEL004',
        clientName: 'Leila Trabelsi',
        address: '9 Rue de Marseille, Tunis',
        phone: '+21693456789',
        status: 'Annulée',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        items: [
          DeliveryItem(
            name: 'Crème hydratante',
            quantity: 1,
            price: 22.50,
          ),
          DeliveryItem(
            name: 'Huile essentielle',
            quantity: 2,
            price: 17.99,
          ),
        ],
        total: 58.48,
        paymentMethod: 'Mobile Money',
        isPaid: false,
        distance: 2.7,
        estimatedTime: 12,
      ),
    ];
  }
}

class DeliveryItem {
  final String name;
  final int quantity;
  final double price;

  DeliveryItem({
    required this.name,
    required this.quantity,
    required this.price,
  });

  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: json['price']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'price': price,
    };
  }

  double get total => quantity * price;
} 