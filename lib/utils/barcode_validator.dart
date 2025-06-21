class BarcodeValidator {
  static bool isValid(String barcode) {
    print('📱 BarcodeValidator: Validating barcode: "$barcode"');
    print('📱 BarcodeValidator: Barcode length: ${barcode.length}');
    
    if (barcode.isEmpty) {
      print('📱 BarcodeValidator: INVALID - Barcode is empty');
      return false;
    }
    
    barcode = barcode.trim();
    print('📱 BarcodeValidator: After trim: "$barcode" (length: ${barcode.length})');
    
    // Check if it's numeric
    final isNumeric = RegExp(r'^\d+$').hasMatch(barcode);
    print('📱 BarcodeValidator: Is numeric: $isNumeric');
    if (!isNumeric) {
      print('📱 BarcodeValidator: INVALID - Not numeric');
      return false;
    }
    
    // Check length - most barcodes are between 8-14 digits
    final hasValidLength = barcode.length >= 8 && barcode.length <= 14;
    print('📱 BarcodeValidator: Has valid length (8-14): $hasValidLength');
    if (!hasValidLength) {
      print('📱 BarcodeValidator: INVALID - Length not between 8-14 digits');
      return false;
    }
    
    print('📱 BarcodeValidator: VALID - Barcode passes all checks');
    return true;
  }
}