import 'package:flutter/material.dart';
import '../api/rest_api.dart';
import '../models/vehicle_model.dart';
import '../helpers/strings.dart';

class AdminCreateVehiclePage extends StatefulWidget {
  const AdminCreateVehiclePage({super.key});

  @override
  State<AdminCreateVehiclePage> createState() => _AdminCreateVehiclePageState();
}

class _AdminCreateVehiclePageState extends State<AdminCreateVehiclePage> {
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _regController = TextEditingController();
  final _locationController = TextEditingController();
  final _partnerController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedTradingOption;
  String? _selectedAssetType;
  String? _selectedFuelType;
  String? _selectedTransmission;
  String? _uploadedImagePath; 

  final List<String> _tradingOptions = ['Rise/Fall', 'Higher/Lower', 'Touch/No Touch'];
  final List<String> _assetTypes = ['Fleet Asset', 'Logistics Asset', 'Economy Asset', 'Luxury Asset'];
  final List<String> _fuelTypes = ['Petrol', 'Diesel', 'Electric', 'Hybrid'];
  final List<String> _transmissions = ['Automatic', 'Manual'];

  double _riskLevel = 0.5;
  double _guaranteeLevel = 0.1;
  double _lotSizeLevel = 0.35; 
  bool _isFormValid = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _brandController.addListener(_validateForm);
    _modelController.addListener(_validateForm);
    _yearController.addListener(_validateForm);
    _regController.addListener(_validateForm);
    _locationController.addListener(_validateForm);
    _partnerController.addListener(_validateForm);
    _amountController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.isNotEmpty &&
          _brandController.text.isNotEmpty &&
          _modelController.text.isNotEmpty &&
          _yearController.text.isNotEmpty &&
          _regController.text.isNotEmpty &&
          _locationController.text.isNotEmpty &&
          _partnerController.text.isNotEmpty &&
          _amountController.text.isNotEmpty &&
          _selectedTradingOption != null &&
          _selectedAssetType != null &&
          _selectedFuelType != null &&
          _selectedTransmission != null &&
          _uploadedImagePath != null;
    });
  }

  void _simulateUpload() {
    setState(() {
      _uploadedImagePath = 'assets/images/car_1.jpeg';
    });
    _validateForm();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image uploaded successfully!')),
    );
  }

  Future<void> _createVehicle() async {
    setState(() => _isSubmitting = true);

    try {
      final double targetAmount = double.parse(_amountController.text);
      final int lotSizePercent = (_lotSizeLevel * 100).toInt();

      final newVehicle = InvestmentVehicle(
        id: 'v_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        brand: _brandController.text,
        model: _modelController.text,
        year: int.tryParse(_yearController.text) ?? 0,
        registrationNumber: _regController.text,
        type: _selectedAssetType!,
        tradingOption: _selectedTradingOption!,
        fuelType: _selectedFuelType!,
        transmission: _selectedTransmission!,
        location: _locationController.text,
        partnerName: _partnerController.text,
        targetAmount: targetAmount,
        lotSize: lotSizePercent,
        lotPrice: targetAmount / lotSizePercent,
        status: 'Open',
        expectedRoi: _guaranteeLevel * 100,
        maturityMonths: 12,
        description: _descriptionController.text.isNotEmpty 
            ? _descriptionController.text 
            : 'Professionally managed ${_brandController.text} ${_modelController.text} with ${lotSizePercent}% lot allocation.',
        imageUrl: _uploadedImagePath,
      );

      await RestApi().addVehicle(newVehicle);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating vehicle: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _regController.dispose();
    _locationController.dispose();
    _partnerController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.vehicleCreationDetails),
        centerTitle: true,
      ),
      body: _isSubmitting
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.vehicleManagement,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Display Name')),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _brandController, decoration: const InputDecoration(labelText: 'Vehicle Brand'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: _modelController, decoration: const InputDecoration(labelText: 'Model'))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextField(controller: _yearController, decoration: const InputDecoration(labelText: 'Year'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: _regController, decoration: const InputDecoration(labelText: 'Registration #'))),
                  ],
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _selectedTradingOption,
                  decoration: const InputDecoration(labelText: 'Trading Option'),
                  items: _tradingOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                  onChanged: (val) { setState(() => _selectedTradingOption = val); _validateForm(); },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedAssetType,
                  decoration: const InputDecoration(labelText: 'Asset Type'),
                  items: _assetTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (val) { setState(() => _selectedAssetType = val); _validateForm(); },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: DropdownButtonFormField<String>(
                      value: _selectedFuelType,
                      decoration: const InputDecoration(labelText: 'Fuel Type'),
                      items: _fuelTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (val) { setState(() => _selectedFuelType = val); _validateForm(); },
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: DropdownButtonFormField<String>(
                      value: _selectedTransmission,
                      decoration: const InputDecoration(labelText: 'Transmission'),
                      items: _transmissions.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                      onChanged: (val) { setState(() => _selectedTransmission = val); _validateForm(); },
                    )),
                  ],
                ),
                const SizedBox(height: 16),

                TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Operation Location')),
                const SizedBox(height: 16),
                TextField(controller: _partnerController, decoration: const InputDecoration(labelText: 'Fleet Partner Name')),
                const SizedBox(height: 16),
                TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                const SizedBox(height: 24),

                const Text('Vehicle Image', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _simulateUpload,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                    ),
                    child: _uploadedImagePath == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Upload Image', style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(_uploadedImagePath!, fit: BoxFit.cover),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Target Investment Amount (R)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),

                Text('Lot Size: ${(_lotSizeLevel * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: _lotSizeLevel,
                  min: 0.01, max: 1.0, divisions: 99,
                  onChanged: (val) => setState(() => _lotSizeLevel = val),
                  activeColor: Colors.blue,
                ),
                const SizedBox(height: 16),

                Text('Return Guarantee: ${(_guaranteeLevel * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: _guaranteeLevel,
                  min: 0.1, max: 0.8, divisions: 7,
                  onChanged: (val) => setState(() => _guaranteeLevel = val),
                  activeColor: Colors.green,
                ),

                const SizedBox(height: 24),
                Text('Risk Level: ${(_riskLevel * 10).toStringAsFixed(1)}/10', style: const TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: _riskLevel,
                  onChanged: (val) => setState(() => _riskLevel = val),
                  activeColor: Colors.orange,
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isFormValid && !_isSubmitting ? _createVehicle : null,
        backgroundColor: _isFormValid ? Colors.orange : Colors.grey.shade300,
        child: const Icon(Icons.check),
      ),
    );
  }
}
