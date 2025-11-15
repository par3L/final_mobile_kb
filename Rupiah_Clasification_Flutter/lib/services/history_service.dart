import 'dart:typed_data';

/// penyimpanan riwayat sederhana di memori. untuk produksi pertimbangkan penyimpanan persisten.
class HistoryService {
  HistoryService._();

  static final List<ScanResult> _scans = [];
  static ScanResult? _latestScan;

  static List<ScanResult> get scans => List.unmodifiable(_scans);
  static ScanResult? get latestScan => _latestScan;

  static void addScan(String imagePath, Map<String, dynamic> predictionData, {Uint8List? imageBytes}) {
    final scan = ScanResult(
      imagePath: imagePath,
      imageBytes: imageBytes,
      coinName: predictionData['token_name'] ?? 'Unknown Coin',
      year: predictionData['year'] ?? '',
      confidence: predictionData['confidence'] ?? 0.0,
      description: predictionData['description'] ?? '',
      scanDate: DateTime.now(),
    );
    _scans.add(scan);
    _latestScan = scan;
  }

  static void removeAt(int index) {
    if (index >= 0 && index < _scans.length) {
      _scans.removeAt(index);
      if (_scans.isEmpty) {
        _latestScan = null;
      }
    }
  }
  
  static void clearLatestScan() {
    _latestScan = null;
  }

  static void clear() {
    _scans.clear();
    _latestScan = null;
  }
}

class ScanResult {
  final String imagePath;
  final Uint8List? imageBytes;
  final String coinName;
  final String year;
  final double confidence;
  final String description;
  final DateTime scanDate;

  ScanResult({
    required this.imagePath,
    this.imageBytes,
    required this.coinName,
    required this.year,
    required this.confidence,
    required this.description,
    required this.scanDate,
  });
}
