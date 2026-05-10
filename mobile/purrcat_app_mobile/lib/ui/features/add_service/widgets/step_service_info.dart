import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/add_service_provider.dart';
import '../../../../data/models/catalog_item_model.dart';
import '../../../core/theme.dart';

class StepServiceInfo extends StatelessWidget {
  const StepServiceInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AddServiceProvider>();
    final isPriceAutoCalculated = provider.category == 'Pet Hotel' || provider.category == 'Grooming';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['Dokter', 'Pet Hotel', 'Grooming'].map((cat) {
            final isSelected = provider.category == cat;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : bodyColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: brandPink,
                  backgroundColor: Colors.grey.shade100,
                  checkmarkColor: Colors.white,
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  onSelected: (val) {
                    if (val) provider.setCategory(cat);
                  },
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // --- Catalog System Area ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              provider.category == 'Dokter'
                  ? 'Practitioners'
                  : provider.category == 'Pet Hotel'
                      ? 'Room Types'
                      : 'Service Packages',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (provider.catalogItems.isNotEmpty)
              TextButton.icon(
                onPressed: () => _showCatalogItemForm(context, provider),
                icon: const Icon(Icons.add, size: 16, color: brandPink),
                label: Text(
                  provider.category == 'Dokter'
                      ? 'Add Doctor'
                      : provider.category == 'Pet Hotel'
                          ? 'Add Room'
                          : 'Add Package',
                  style: const TextStyle(color: brandPink, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        if (provider.catalogItems.isEmpty)
          _buildEmptyState(context, provider)
        else
          _buildCatalogList(context, provider),

        const SizedBox(height: 24),

        const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: provider.descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Describe your service...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 20),

        const Text('Base Price (IDR)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextFormField(
          controller: provider.basePriceController,
          keyboardType: TextInputType.number,
          readOnly: isPriceAutoCalculated,
          decoration: InputDecoration(
            hintText: 'e.g. 150000',
            border: const OutlineInputBorder(),
            prefixText: 'Rp ',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: isPriceAutoCalculated
                ? const Tooltip(
                    message: 'Auto-calculated from lowest catalog price',
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.auto_awesome, color: brandPink, size: 20),
                    ),
                  )
                : null,
            helperText: isPriceAutoCalculated
                ? 'Automatically pulled from lowest price in your room types/packages'
                : 'Enter general consultation or base starting fee',
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AddServiceProvider provider) {
    IconData icon;
    String title;
    String subtitle;
    String btnLabel;

    if (provider.category == 'Dokter') {
      icon = Icons.medical_services_outlined;
      title = 'No Practitioners Registered';
      subtitle = 'Add doctor listings to showcase the medical staff at your clinic.';
      btnLabel = 'Add Practitioner';
    } else if (provider.category == 'Pet Hotel') {
      icon = Icons.hotel_outlined;
      title = 'No Room Types Registered';
      subtitle = 'Add specific room types, sizes, or suite categories you offer.';
      btnLabel = 'Add Room Type';
    } else {
      icon = Icons.spa_outlined;
      title = 'No Grooming Packages Registered';
      subtitle = 'Add packages with their descriptions and individual rates.';
      btnLabel = 'Add Grooming Package';
    }

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: brandPink.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: brandPink, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: bodyColor.withOpacity(0.8), fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandPink,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onPressed: () => _showCatalogItemForm(context, provider),
                icon: const Icon(Icons.add, size: 18),
                label: Text(btnLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogList(BuildContext context, AddServiceProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.catalogItems.length,
      itemBuilder: (context, index) {
        final item = provider.catalogItems[index];
        IconData leadingIcon;
        String trailingText = '';

        if (provider.category == 'Dokter') {
          leadingIcon = Icons.person_outline;
          trailingText = item.extra['sipNumber'] ?? '';
        } else if (provider.category == 'Pet Hotel') {
          leadingIcon = Icons.door_front_door_outlined;
          trailingText = 'Rp ${item.price.toStringAsFixed(0)}/night';
        } else {
          leadingIcon = Icons.dry_cleaning_outlined;
          trailingText = 'Rp ${item.price.toStringAsFixed(0)}';
        }

        return Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: brandPink.withOpacity(0.05),
              child: Icon(leadingIcon, color: brandPink, size: 20),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                if (provider.category == 'Pet Hotel' && item.extra['capacity'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Capacity: ${item.extra['capacity']} rooms',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trailingText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: brandPink,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                  onPressed: () => _showCatalogItemForm(context, provider, item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                  onPressed: () => provider.removeCatalogItem(item.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCatalogItemForm(BuildContext context, AddServiceProvider provider, [CatalogItem? editingItem]) {
    final category = provider.category;

    final nameCtrl = TextEditingController(text: editingItem?.name ?? '');
    final priceCtrl = TextEditingController(
        text: editingItem != null && category != 'Dokter' ? editingItem.price.toStringAsFixed(0) : '');
    final descCtrl = TextEditingController(text: editingItem?.description ?? '');

    final extraCtrl = TextEditingController(
        text: editingItem != null
            ? (category == 'Dokter'
                ? editingItem.extra['sipNumber']?.toString() ?? ''
                : (category == 'Pet Hotel'
                    ? editingItem.extra['capacity']?.toString() ?? ''
                    : ''))
            : '');

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        editingItem == null
                            ? (category == 'Dokter'
                                ? 'Add Practitioner'
                                : category == 'Pet Hotel'
                                    ? 'Add Room Type'
                                    : 'Add Grooming Package')
                            : 'Edit Catalog Item',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: headingColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  Text(
                    category == 'Dokter'
                        ? 'Doctor Name'
                        : category == 'Pet Hotel'
                            ? 'Room Type Name'
                            : 'Package Name',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: category == 'Dokter'
                          ? 'e.g. Dr. John Doe'
                          : category == 'Pet Hotel'
                              ? 'e.g. Cat Deluxe Suite'
                              : 'e.g. Mandi Lengkap',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  if (category == 'Dokter') ...[
                    const Text('SIP Number (Surat Izin Praktik)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: extraCtrl,
                      decoration: const InputDecoration(
                        hintText: 'e.g. SIP.12345/2026',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'SIP number is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Specialization', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descCtrl,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Feline Specialist, Surgery',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Specialization is required';
                        }
                        return null;
                      },
                    ),
                  ] else if (category == 'Pet Hotel') ...[
                    const Text('Price per Night (IDR)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 150000',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Price is required';
                        }
                        if (double.tryParse(val) == null) {
                          return 'Invalid number format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Total Room Capacity', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: extraCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 5',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Capacity is required';
                        }
                        if (int.tryParse(val) == null) {
                          return 'Capacity must be a number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Room Facilities / Features', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'e.g. AC, CCTV, Soft Bed, Toys',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Facilities are required';
                        }
                        return null;
                      },
                    ),
                  ] else if (category == 'Grooming') ...[
                    const Text('Package Price (IDR)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 75000',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Price is required';
                        }
                        if (double.tryParse(val) == null) {
                          return 'Invalid number format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Description / What\'s Included', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Mandi air hangat, potong kuku, blow-dry',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Inclusions description is required';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandPink,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final item = CatalogItem(
                                id: editingItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                                name: nameCtrl.text.trim(),
                                price: double.tryParse(priceCtrl.text) ?? 0.0,
                                description: descCtrl.text.trim(),
                                extra: category == 'Dokter'
                                    ? {'sipNumber': extraCtrl.text.trim()}
                                    : (category == 'Pet Hotel'
                                        ? {'capacity': int.tryParse(extraCtrl.text) ?? 0}
                                        : {}),
                              );

                              if (editingItem == null) {
                                provider.addCatalogItem(item);
                              } else {
                                provider.updateCatalogItem(item);
                              }

                              Navigator.pop(context);
                            }
                          },
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
