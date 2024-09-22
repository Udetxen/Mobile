import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:udetxen/features/report/services/report_service.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_pdfview/flutter_pdfview.dart';

class ReportScreen extends StatefulWidget {
  static route() {
    return MaterialPageRoute<void>(
      builder: (_) => const ReportScreen(),
    );
  }

  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isLoading = false;
  String? _reportUrl;
  DateTime? _lastGeneratedDate;
  final reportService = getIt<ReportService>();
  File? _pdfFile;

  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reportData = await reportService.getReportData();
      setState(() {
        _reportUrl = reportData['url'];
        _lastGeneratedDate = reportData['lastGenerated'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading report data: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateReport() async {
    if (_lastGeneratedDate != null && !_canGenerateReport()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You can only generate a report every 30 days.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _reportUrl = null;
    });

    try {
      String? reportUrl =
          await reportService.generateAndUploadCompletedTripsReport();

      if (reportUrl != null) {
        setState(() {
          _reportUrl = reportUrl;
          _lastGeneratedDate = DateTime.now();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report generated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate report.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating report: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _canGenerateReport() {
    if (_lastGeneratedDate == null) return true;
    final difference = DateTime.now().difference(_lastGeneratedDate!).inDays;
    return difference >= 30;
  }

  Future<void> _viewReport(String url) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/completed_trips_report.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _pdfFile = file;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening report: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Trips Report'),
        backgroundColor: Theme.of(context).hintColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pdfFile != null
              ? PDFView(
                  filePath: _pdfFile!.path,
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to load PDF: $error')),
                    );
                  },
                  onRender: (pages) {
                    setState(() {
                      _isLoading = false;
                    });
                  },
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_reportUrl != null) ...[
                        const Text('A report is available.'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _viewReport(_reportUrl!),
                          child: const Text('View Report'),
                        ),
                        const SizedBox(height: 30),
                      ],
                      if (_canGenerateReport()) ...[
                        ElevatedButton(
                          onPressed: _generateReport,
                          child: const Text('Generate New Report'),
                        ),
                        if (_lastGeneratedDate != null)
                          const SizedBox(height: 10),
                        if (_lastGeneratedDate != null)
                          Text(
                            'Last generated on: ${DateFormat.yMMMd().format(_lastGeneratedDate!)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ] else ...[
                        const Text(
                          'You can generate a new report every 30 days.',
                        ),
                        if (_lastGeneratedDate != null)
                          const SizedBox(height: 10),
                        if (_lastGeneratedDate != null)
                          Text(
                            'Last generated on: ${DateFormat.yMMMd().format(_lastGeneratedDate!)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ],
                  ),
                ),
    );
  }
}
