import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/service_model.dart';
import '../../models/mechanic_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/mechanic_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_routes.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({Key? key}) : super(key: key);

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _useCurrentLocation = false;
  MechanicModel? _selectedMechanic;
  ServiceModel? _selectedService;
  List<MechanicModel> _availableMechanics = [];
  List<ServiceModel> _availableServices = [];
  bool _loadingMechanics = false;
  bool _loadingServices = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      locationProvider.getCurrentLocation();
      
      // Get arguments: can be ServiceModel (from services) or Map with mechanic (from map)
      final arguments = ModalRoute.of(context)?.settings.arguments;
      
      if (arguments is ServiceModel) {
        // Coming from services list - service is pre-selected
        _selectedService = arguments;
      } else if (arguments is Map<String, dynamic>) {
        // Coming from map - mechanic is pre-selected
        if (arguments['mechanic'] != null) {
          _selectedMechanic = arguments['mechanic'];
        }
      }
    });
    _loadAvailableMechanics();
    _loadAvailableServices();
  }

  Future<void> _loadAvailableServices() async {
    setState(() {
      _loadingServices = true;
    });
    try {
      final services = await _apiService.getServices();
      setState(() {
        _availableServices = services;
        _loadingServices = false;
      });
    } catch (e) {
      setState(() {
        _loadingServices = false;
      });
      print('Error loading services: $e');
    }
  }

  Future<void> _loadAvailableMechanics() async {
    setState(() {
      _loadingMechanics = true;
    });
    try {
      final mechanics = await _apiService.getAvailableMechanics();
      setState(() {
        _availableMechanics = mechanics.where((m) => m.available).toList();
        _loadingMechanics = false;
      });
    } catch (e) {
      setState(() {
        _loadingMechanics = false;
      });
      print('Error loading mechanics: $e');
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate both service and mechanic are selected
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner un service'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedMechanic == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner un mécanicien'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner la date et l\'heure'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    final scheduledDate = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    double latitude = locationProvider.currentPosition?.latitude ?? 36.8065;
    double longitude = locationProvider.currentPosition?.longitude ?? 10.1815;
    String address = _useCurrentLocation 
        ? locationProvider.currentAddress 
        : _addressController.text;

    bool success = await bookingProvider.createBooking(
      userId: authProvider.user!.uid,
      serviceId: _selectedService!.id,
      serviceName: _selectedService!.name,
      scheduledDate: scheduledDate,
      address: address,
      latitude: latitude,
      longitude: longitude,
      totalPrice: _selectedService!.price,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      mechanicId: _selectedMechanic!.id,
      mechanicName: _selectedMechanic!.name,
      mechanicPhone: _selectedMechanic!.phone,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.bookingCreated),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingProvider.errorMessage ?? 'Erreur'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Réservation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Selection
              Text(
                'Sélectionner un service',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_loadingServices)
                const Center(child: CircularProgressIndicator())
              else if (_availableServices.isEmpty)
                const Text(
                  'Aucun service disponible',
                  style: TextStyle(color: Colors.grey),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _availableServices.map((service) {
                      final isSelected = _selectedService?.id == service.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedService = _selectedService?.id == service.id ? null : service;
                            });
                          },
                          child: Card(
                            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.build, color: AppColors.primary, size: 40),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      service.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${service.price.toStringAsFixed(0)} DT',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Mechanic Selection
              Text(
                'Sélectionner un mécanicien',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_loadingMechanics)
                const Center(child: CircularProgressIndicator())
              else if (_availableMechanics.isEmpty)
                const Text(
                  'Aucun mécanicien disponible',
                  style: TextStyle(color: Colors.grey),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _availableMechanics.map((mechanic) {
                      final isSelected = _selectedMechanic?.id == mechanic.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMechanic = _selectedMechanic?.id == mechanic.id ? null : mechanic;
                            });
                          },
                          child: Card(
                            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: AppColors.primary.withOpacity(0.1),
                                    child: const Icon(Icons.person, color: AppColors.primary),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 100,
                                    child: Text(
                                      mechanic.name,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star, size: 14, color: Colors.amber),
                                      Text(
                                        '${mechanic.rating}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Date
              Text(
                AppStrings.selectDate,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Sélectionner une date'
                            : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Time
              Text(
                AppStrings.selectTime,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime == null
                            ? 'Sélectionner une heure'
                            : _selectedTime!.format(context),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Use current location
              CheckboxListTile(
                title: const Text('Utiliser ma position actuelle'),
                subtitle: locationProvider.currentAddress.isNotEmpty
                    ? Text(locationProvider.currentAddress)
                    : null,
                value: _useCurrentLocation,
                onChanged: (value) {
                  setState(() {
                    _useCurrentLocation = value!;
                  });
                },
                activeColor: AppColors.primary,
              ),
              
              if (!_useCurrentLocation) ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _addressController,
                  label: AppStrings.address,
                  hint: 'Votre adresse complète',
                  prefixIcon: Icons.location_on,
                  maxLines: 2,
                  validator: (value) {
                    if (!_useCurrentLocation && (value == null || value.isEmpty)) {
                      return 'Adresse requise';
                    }
                    return null;
                  },
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Notes
              CustomTextField(
                controller: _notesController,
                label: AppStrings.notes,
                hint: 'Instructions supplémentaires (optionnel)',
                prefixIcon: Icons.note,
                maxLines: 3,
              ),
              
              const SizedBox(height: 32),
              
              // Submit Button
              Consumer<BookingProvider>(
                builder: (context, bookingProvider, child) {
                  return CustomButton(
                    text: AppStrings.confirmBooking,
                    onPressed: _submitBooking,
                    isLoading: bookingProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}