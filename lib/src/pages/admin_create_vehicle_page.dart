import 'package:flutter/material.dart';

class AdminCreateVehiclePage extends StatefulWidget {
  const AdminCreateVehiclePage({super.key});

  @override
  State<AdminCreateVehiclePage> createState() => _AdminCreateVehiclePageState();
}

class _AdminCreateVehiclePageState extends State<AdminCreateVehiclePage> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  
  String? _selectedTradingOption;
  String? _selectedAssetType;
  String? _uploadedImagePath; // Store path after simulated "upload"

  final List<String> _tradingOptions = ['Rise/Fall', 'Higher/Lower', 'Touch/No Touch'];
  final List<String> _assetTypes = ['Fleet Asset', 'Logistics Asset', 'Economy Asset', 'Luxury Asset'];

  double _riskLevel = 0.5;
  double _guaranteeLevel = 0.1; // Default 10%
  double _lotSizeLevel = 0.01; // Default 1%
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _amountController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _nameController.text.isNotEmpty &&
          _amountController.text.isNotEmpty &&
          _selectedTradingOption != null &&
          _selectedAssetType != null &&
          _uploadedImagePath != null;
    });
  }

  void _simulateUpload() {
    // Simulating an image picker selection
    setState(() {
      _uploadedImagePath = 'assets/images/car_1.jpeg'; // Mock selection
    });
    _validateForm();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image uploaded successfully!')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const josefineStyle = TextStyle(fontFamily: 'Josefine');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Creation Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Vehicle Name'),
            ),
            const SizedBox(height: 16),
            
            // Trading Option Dropdown
            DropdownButtonFormField<String>(
              value: _selectedTradingOption,
              decoration: const InputDecoration(labelText: 'Trading Option'),
              items: _tradingOptions.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: (val) {
                setState(() => _selectedTradingOption = val);
                _validateForm();
              },
            ),
            const SizedBox(height: 16),

            // Asset Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedAssetType,
              decoration: const InputDecoration(labelText: 'Asset Type'),
              items: _assetTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (val) {
                setState(() => _selectedAssetType = val);
                _validateForm();
              },
            ),
            const SizedBox(height: 24),

            // Vehicle Image Upload
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
              decoration: const InputDecoration(labelText: 'Investment Amount (R)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 32),

            // Lot Size Slider
            Text(
              'Lot Size: ${(_lotSizeLevel * 100).toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _lotSizeLevel,
              min: 0.01,
              max: 1.0,
              divisions: 99, // 1% to 100% in 1% increments
              onChanged: (val) => setState(() => _lotSizeLevel = val),
              activeColor: Colors.blue,
            ),
            const SizedBox(height: 16),

            // Return Guarantee Slider
            Text(
              'Return Guarantee: ${(_guaranteeLevel * 100).toInt()}%',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _guaranteeLevel,
              min: 0.1,
              max: 0.8,
              divisions: 7, // 10% to 80% in 10% increments
              onChanged: (val) => setState(() => _guaranteeLevel = val),
              activeColor: Colors.green,
            ),
            
            const SizedBox(height: 24),
            Text(
              'Risk Level: ${(_riskLevel * 10).toStringAsFixed(1)}/10',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
        onPressed: _isFormValid
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vehicle created successfully!')),
                );
                Navigator.pop(context);
              }
            : null,
        backgroundColor: _isFormValid ? Colors.orange : Colors.grey.shade300,
        child: const Icon(Icons.check),
      ),
    );
  }
}
