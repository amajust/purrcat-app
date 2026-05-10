import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/models/provider_service_model.dart';
import '../../../../data/models/catalog_item_model.dart';
import '../../../../data/repositories/add_service_repository.dart';

class AddServiceProvider extends ChangeNotifier {
  final AddServiceRepository _repository = AddServiceRepository();

  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isVerified = false;
  bool get isVerified => _isVerified;
  
  String? _verificationStatus;
  String? get verificationStatus => _verificationStatus;
  
  String _entityType = 'individual'; // 'individual' or 'business'
  String get entityType => _entityType;

  // Step 1: Identity
  File? _ktpFile;
  File? get ktpFile => _ktpFile;
  File? _nibFile;
  File? get nibFile => _nibFile;

  // Step 2: Service Info
  String _category = 'Dokter'; // 'Dokter', 'Pet Hotel', 'Grooming'
  String get category => _category;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController basePriceController = TextEditingController();

  // Catalog System List
  final List<CatalogItem> _catalogItems = [];
  List<CatalogItem> get catalogItems => _catalogItems;

  // Step 3: Location
  ServiceType _serviceType = ServiceType.onSite;
  ServiceType get serviceType => _serviceType;
  GeoPoint? _location;
  GeoPoint? get location => _location;
  final TextEditingController locationAddressController = TextEditingController();

  // Step 4: Availability
  final Map<String, Map<String, String>> _operatingHours = {
    'monday': {'open': '09:00', 'close': '17:00'},
    'tuesday': {'open': '09:00', 'close': '17:00'},
    'wednesday': {'open': '09:00', 'close': '17:00'},
    'thursday': {'open': '09:00', 'close': '17:00'},
    'friday': {'open': '09:00', 'close': '17:00'},
    'saturday': {'open': '', 'close': ''},
    'sunday': {'open': '', 'close': ''},
  };
  Map<String, Map<String, String>> get operatingHours => _operatingHours;
  int _slotDuration = 30;
  int get slotDuration => _slotDuration;
  int _maxCapacity = 1;
  int get maxCapacity => _maxCapacity;

  // Step 5: Financials
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();
  bool _agreedToFee = false;
  bool get agreedToFee => _agreedToFee;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AddServiceProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _setLoading(true);
    try {
      final userId = _repository.currentUserId;
      if (userId != null) {
         final profile = await _repository.getUserProfile(userId);
         if (profile != null) {
           _isVerified = profile['isVerified'] ?? false;
           _entityType = profile['entityType'] ?? 'individual';
           
           if (_isVerified) {
             nameController.text = profile['businessName'] ?? profile['name'] ?? '';
             _currentStep = 1; // start at step 2
           }
         }
      }
    } catch (e) {
      _errorMessage = 'Failed to load user status.';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 4) { // Assuming 5 steps (0 to 4)
       if (_validateCurrentStep()) {
          _currentStep++;
          notifyListeners();
       }
    } else {
      submitService();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }
  
  bool _validateCurrentStep() {
    _errorMessage = null;
    switch (_currentStep) {
      case 0:
        if (!_isVerified) {
          if (nameController.text.trim().isEmpty) {
            _errorMessage = 'Business Display Name is required.';
            notifyListeners();
            return false;
          }
          if (_ktpFile == null) {
            _errorMessage = 'KTP is required.';
            notifyListeners();
            return false;
          }
          if (_entityType == 'business' && _nibFile == null) {
            _errorMessage = 'NIB is required for businesses.';
            notifyListeners();
            return false;
          }
        }
        return true;
      case 1:
        if (nameController.text.trim().isEmpty) {
          _errorMessage = 'Business Display Name is required. Please check Step 1.';
          notifyListeners();
          return false;
        }
        if (descriptionController.text.trim().isEmpty) {
          _errorMessage = 'Description is required.';
          notifyListeners();
          return false;
        }
        if (basePriceController.text.trim().isEmpty) {
           _errorMessage = 'Base price is required.';
           notifyListeners();
           return false;
        }
        if (double.tryParse(basePriceController.text) == null) {
            _errorMessage = 'Invalid price format.';
            notifyListeners();
            return false;
        }

        if (_catalogItems.isEmpty) {
          String itemName = 'items';
          if (_category == 'Dokter') itemName = 'practitioners';
          if (_category == 'Pet Hotel') itemName = 'room types';
          if (_category == 'Grooming') itemName = 'packages';
          _errorMessage = 'Please add at least one $itemName to your catalog.';
          notifyListeners();
          return false;
        }
        return true;
      case 2:
        if (_location == null && _serviceType == ServiceType.onSite) {
            _errorMessage = 'Location is required for On-Site services.';
            notifyListeners();
            return false;
        }
        return true;
      case 3:
        return true;
      case 4:
         if (bankNameController.text.trim().isEmpty || 
             accountNumberController.text.trim().isEmpty || 
             accountHolderController.text.trim().isEmpty) {
             _errorMessage = 'Bank details are required.';
             notifyListeners();
             return false;
         }
         // KYC holder name matching validation
         if (accountHolderController.text.trim().toLowerCase() != nameController.text.trim().toLowerCase()) {
             _errorMessage = 'Bank Account Holder Name must match your Business Display Name: "${nameController.text}".';
             notifyListeners();
             return false;
         }
         if (!_agreedToFee) {
             _errorMessage = 'You must agree to the platform fee.';
             notifyListeners();
             return false;
         }
         return true;
      default:
         return true;
    }
  }

  // --- Setters ---
  void setEntityType(String type) {
    _entityType = type;
    notifyListeners();
  }

  void setKtpFile(File file) {
    _ktpFile = file;
    notifyListeners();
  }

  void setNibFile(File file) {
    _nibFile = file;
    notifyListeners();
  }

  void setCategory(String category) {
    _category = category;
    _catalogItems.clear();
    _updateBasePrice();
    notifyListeners();
  }

  void setServiceType(ServiceType type) {
    _serviceType = type;
    notifyListeners();
  }

  void setLocation(GeoPoint point) {
    _location = point;
    notifyListeners();
  }

  void updateOperatingHour(String day, String type, String value) {
    _operatingHours[day]?[type] = value;
    notifyListeners();
  }

  void setSlotDuration(int duration) {
    _slotDuration = duration;
    notifyListeners();
  }

  void setMaxCapacity(int capacity) {
    _maxCapacity = capacity;
    notifyListeners();
  }

  void addCatalogItem(CatalogItem item) {
    _catalogItems.add(item);
    _updateBasePrice();
    notifyListeners();
  }

  void updateCatalogItem(CatalogItem item) {
    final index = _catalogItems.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _catalogItems[index] = item;
      _updateBasePrice();
      notifyListeners();
    }
  }

  void removeCatalogItem(String id) {
    _catalogItems.removeWhere((element) => element.id == id);
    _updateBasePrice();
    notifyListeners();
  }

  void _updateBasePrice() {
    if (_category == 'Pet Hotel' || _category == 'Grooming') {
      if (_catalogItems.isEmpty) {
        basePriceController.text = '';
      } else {
        double minPrice = _catalogItems.first.price;
        for (var item in _catalogItems) {
          if (item.price < minPrice) {
            minPrice = item.price;
          }
        }
        basePriceController.text = minPrice.toStringAsFixed(0);
      }
    }
  }

  void setAgreedToFee(bool agreed) {
    _agreedToFee = agreed;
    notifyListeners();
  }

  // --- Submit ---
  Future<bool> submitService() async {
    if (!_validateCurrentStep()) return false;
    _setLoading(true);
    _errorMessage = null;

    try {
      final userId = _repository.currentUserId;
      if (userId == null) throw Exception('User not logged in');

      // 1. Submit KYC if not verified
      if (!_isVerified) {
        await _repository.submitVerificationFiles(
          userId: userId,
          entityType: _entityType,
          ktpFile: _ktpFile,
          nibFile: _nibFile,
        );
        // Wait for admin approval ideally, but for now we proceed to create service in pending_admin state
      }

      // 3. Submit Service
      final model = ProviderServiceModel(
        providerId: userId,
        category: _category,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        basePrice: double.parse(basePriceController.text.trim()),
        serviceType: _serviceType,
        location: _location,
        locationAddress: locationAddressController.text.trim(),
        operatingHours: _operatingHours,
        slotDuration: _slotDuration,
        maxCapacity: _maxCapacity,
        bankName: bankNameController.text.trim(),
        accountNumber: accountNumberController.text.trim(),
        accountHolder: accountHolderController.text.trim(),
        platformFeePercent: 5.0, // Enforced by backend
        metadata: {}, // toFirestore automatically merges catalog into metadata
        catalog: _catalogItems,
      );

      await _repository.submitServiceListing(model);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
