import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:udetxen/shared/types/models/trip.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class ReportService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ReportService(this._auth, this._firestore, this._storage);

// Fetch existing report URL and last generated date
  Future<Map<String, dynamic>> getReportData() async {
    try {
      String userId = _auth.currentUser!.uid;

      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        String? reportUrl = data['reportUrl'];
        Timestamp? lastGenerated = data['lastGenerated'];

        return {
          'url': reportUrl,
          'lastGenerated': lastGenerated?.toDate(),
        };
      }
    } catch (e) {
      print('Error fetching report data: $e');
    }

    return {
      'url': null,
      'lastGenerated': null,
    };
  }

  // Generate, upload the PDF report, and save the URL and timestamp
  Future<String?> generateAndUploadCompletedTripsReport() async {
    try {
      // Fetch the completed trips
      List<Trip> completedTrips = await _getCompletedTrips();

      // Generate PDF report
      File pdfFile = await _generateCompletedTripsPDF(completedTrips);

      // Upload the PDF to Firebase Storage
      String? downloadUrl = await _uploadPDFToFirebase(pdfFile);

      if (downloadUrl != null) {
        // Save the report URL and timestamp to Firestore
        await _saveReportData(downloadUrl);
      }

      return downloadUrl;
    } catch (e) {
      print('Error generating or uploading report: $e');
      return null;
    }
  }

  // Fetch completed trips from Firestore
  Future<List<Trip>> _getCompletedTrips() async {
    DateTime today = DateTime.now();

    QuerySnapshot querySnapshot = await _firestore
        .collection('trips')
        .where('endDate', isLessThan: today)
        .get();

    return querySnapshot.docs.map((doc) {
      return Trip.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Generate the PDF for completed trips
  Future<File> _generateCompletedTripsPDF(List<Trip> trips) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.ListView.builder(
          itemCount: trips.length,
          itemBuilder: (context, index) {
            final trip = trips[index];
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Trip Name: ${trip.name}'),
                pw.Text(
                    'End Date: ${DateFormat.yMMMd().format(trip.endDate!)}'),
                pw.Text('Budget: \$${trip.budget.toStringAsFixed(2)}'),
                pw.Text('Participants: ${trip.participants?.length ?? 0}'),
                pw.Divider(),
              ],
            );
          },
        ),
      ),
    );

    final outputDir = await getTemporaryDirectory();
    final file = File('${outputDir.path}/completed_trips_report.pdf');

    await file.writeAsBytes(await pdf.save());
    return file;
  }

  // Upload the PDF to Firebase Storage
  Future<String?> _uploadPDFToFirebase(File pdfFile) async {
    try {
      String userId = _auth.currentUser!.uid;
      final storageRef =
          _storage.ref().child('reports/$userId/completed_trips_report.pdf');

      UploadTask uploadTask = storageRef.putFile(pdfFile);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Error uploading PDF to Firebase: $e');
      return null;
    }
  }

  // Save report URL and the timestamp of when it was generated
  Future<void> _saveReportData(String downloadUrl) async {
    try {
      String userId = _auth.currentUser!.uid;

      await _firestore.collection('users').doc(userId).update({
        'reportUrl': downloadUrl,
        'lastGenerated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving report data: $e');
    }
  }
}
