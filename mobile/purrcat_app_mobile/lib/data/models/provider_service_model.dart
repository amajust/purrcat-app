import 'package:cloud_firestore/cloud_firestore.dart';
import 'catalog_item_model.dart';

enum ServiceStatus { pendingAdmin, active, rejected }
enum ServiceType { onSite, homeVisit }

class ProviderServiceModel {
  final String? id;
  final String providerId;
  final ServiceStatus status;
  final String category;
  final String name;
  final String description;
  final double basePrice;
  final ServiceType serviceType;
  final GeoPoint? location;
  final String? locationAddress;
  final Map<String, Map<String, String>> operatingHours;
  final int slotDuration; // in minutes
  final int maxCapacity;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final double platformFeePercent;
  final Map<String, dynamic> metadata;
  final List<CatalogItem> catalog;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProviderServiceModel({
    this.id,
    required this.providerId,
    this.status = ServiceStatus.pendingAdmin,
    required this.category,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.serviceType,
    this.location,
    this.locationAddress,
    required this.operatingHours,
    required this.slotDuration,
    required this.maxCapacity,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolder,
    this.platformFeePercent = 5.0, // default is 5%, but Cloud Function enforces
    this.metadata = const {},
    this.catalog = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory ProviderServiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse operating hours
    Map<String, Map<String, String>> parsedHours = {};
    if (data['operatingHours'] != null) {
      final Map<String, dynamic> rawHours = data['operatingHours'];
      rawHours.forEach((key, value) {
        if (value is Map) {
           parsedHours[key] = {
             'open': value['open']?.toString() ?? '',
             'close': value['close']?.toString() ?? '',
           };
        }
      });
    }

    return ProviderServiceModel(
      id: doc.id,
      providerId: data['providerId'] ?? '',
      status: _statusFromString(data['status']),
      category: data['category'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      basePrice: (data['basePrice'] ?? 0).toDouble(),
      serviceType: _serviceTypeFromString(data['serviceType']),
      location: data['location'] as GeoPoint?,
      locationAddress: data['locationAddress'],
      operatingHours: parsedHours,
      slotDuration: data['slotDuration'] ?? 30,
      maxCapacity: data['maxCapacity'] ?? 1,
      bankName: data['bankName'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
      accountHolder: data['accountHolder'] ?? '',
      platformFeePercent: (data['platformFeePercent'] ?? 5.0).toDouble(),
      metadata: data['metadata'] as Map<String, dynamic>? ?? const {},
      catalog: (() {
        final metadataMap = data['metadata'] as Map<String, dynamic>? ?? const {};
        final catalogList = metadataMap['catalog'] as List<dynamic>? ?? const [];
        return catalogList.map((item) => CatalogItem.fromMap(item as Map<String, dynamic>)).toList();
      })(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'providerId': providerId,
      'status': _statusToString(status),
      'category': category,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'serviceType': _serviceTypeToString(serviceType),
      if (location != null) 'location': location,
      if (locationAddress != null) 'locationAddress': locationAddress,
      'operatingHours': operatingHours,
      'slotDuration': slotDuration,
      'maxCapacity': maxCapacity,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'accountHolder': accountHolder,
      'platformFeePercent': platformFeePercent,
      'metadata': (() {
        final finalMetadata = Map<String, dynamic>.from(metadata);
        finalMetadata['catalog'] = catalog.map((item) => item.toMap()).toList();
        return finalMetadata;
      })(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static ServiceStatus _statusFromString(String? status) {
    switch (status) {
      case 'active': return ServiceStatus.active;
      case 'rejected': return ServiceStatus.rejected;
      case 'pending_admin':
      default:
        return ServiceStatus.pendingAdmin;
    }
  }

  static String _statusToString(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.active: return 'active';
      case ServiceStatus.rejected: return 'rejected';
      case ServiceStatus.pendingAdmin: return 'pending_admin';
    }
  }

  static ServiceType _serviceTypeFromString(String? type) {
    if (type == 'home_visit') return ServiceType.homeVisit;
    return ServiceType.onSite;
  }

  static String _serviceTypeToString(ServiceType type) {
    if (type == ServiceType.homeVisit) return 'home_visit';
    return 'on_site';
  }
}
