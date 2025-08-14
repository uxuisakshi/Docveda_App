import 'package:docveda_app/utils/helpers/date_formater.dart';
import 'package:docveda_app/utils/helpers/format_amount.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

Future<void> generateAndShowPdf(
    List<Map<String, dynamic>> selectedPatients) async {
  final pdf = pw.Document();
  //  final ByteData bytes = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
  // final pw.Font font = pw.Font.ttf(bytes);

  // Define one set of headers and rows per screen type
  final Map<String, List<List<String>>> screenWiseData = {};
  final Map<String, List<String>> screenWiseHeaders = {
    'admission': [
      'Name',
      'Age',
      'Gender',
      'UHID No',
      'Admission Date',
      'Total Bill',
      'Ward Name',
      'Bed Name'
    ],
    'discharge': [
      'Name',
      'Age',
      'Gender',
      'UHID No',
      'Admission Date',
      'Discharge Date',
      'Bill Amount',
    ],
    'ipd settlement': [
      'Name',
      'UHID No',
      'Admission Date',
      'Total Ipd Bill',
      'Deposit',
      'Final Settlement',
    ],
    'deposit': [
      'Name',
      'Age',
      'Gender',
      'UHID No',
      'Admission Date',
      'Deposit',
      'Total Ipd Bill',
      'Pending Amount',
    ],
    'bed transfer': [
      'Name',
      'Age',
      'Gender',
      'UHID No',
      'Transfer Date',
      'From Ward',
      'To Ward',
    ],
    'opd visit': [
      'Name',
      'Age',
      'Gender',
      'UHID No',
      'Visit Date',
      'Doctor Name',
    ],
    'opd payment': [
      'Name',
      'Age',
      'Gender',
      'UHID No',
      'Bill Amount',
      'Payment Date',
      'Paid Amount',
      'Doctor Name',
    ],
    'opd bills': [
      'Name',
      'Age',
      'Gender',
      'UHID No',
      'Admission Date',
      'Bill Amount',
      'Bill No',
    ],
    'refund': [
      'Name',
      'Age',
      'Gender',
      'UHID No',
      'Refund Date',
      'Refund Amount',
    ],
    'discount': [
      'Name',
      'Age',
      'Gender',
      'UHID No',
      'Discount Date',
      'Discount Amount',
    ],
  };

  for (final patient in selectedPatients) {
    final screenName = (patient['Screen Name'] ?? '').toString().toLowerCase();
    final data = <String>[];
//     final ttf = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
// final font = pw.Font.ttf(ttf);

    switch (screenName) {
      case 'admission':
        data.addAll([
          patient['Patient Name'] ?? '--',
          patient['Age'] ?? '--',
          patient['Gender'] ?? '--',
          patient['UHID No'] ?? '--',
          DateFormatter.formatDate(patient['Admission Date']),
          FormatAmount.formatAmount(
              patient['Total IPD Bill']?.toString() ?? '0',
              showSymbol: false),
          patient['Ward Name'] ?? '--',
          patient['Bed Name'] ?? '--',
        ]);
        break;
      case 'discharge':
        data.addAll([
          patient['Patient Name'] ?? '--',
          patient['Age'] ?? '--',
          patient['Gender'] ?? '--',
          patient['UHID No'] ?? '--',
          DateFormatter.formatDate(patient['Admission Date']),
          DateFormatter.formatDate(patient['Discharge Date']),
          FormatAmount.formatAmount(
              patient['Total IPD Bill']?.toString() ?? '0',
              showSymbol: false),
        ]);
        break;
      case 'ipd settlement':
        data.addAll([
          patient['Patient Name'] ?? '--',
          patient['UHID No'] ?? '--',
          DateFormatter.formatDate(patient['Admission Date']),
          FormatAmount.formatAmount(
              patient['Total IPD Bill']?.toString() ?? '0',
              showSymbol: false),
          FormatAmount.formatAmount(patient['Deposit']?.toString() ?? '0',
              showSymbol: false),
          FormatAmount.formatAmount(
              patient['Final Settlement']?.toString() ?? '0',
              showSymbol: false),
        ]);
        break;
      case 'deposit':
        data.addAll([
          patient['Patient Name'] ?? '--',
          patient['Age'] ?? '--',
          patient['Gender'] ?? '--',
          patient['UHID No'] ?? '--',
          DateFormatter.formatDate(patient['Admission Date']),
          FormatAmount.formatAmount(
              patient['Total IPD Bill']?.toString() ?? '0',
              showSymbol: false),
          FormatAmount.formatAmount(patient['Deposit']?.toString() ?? '0',
              showSymbol: false),
          FormatAmount.formatAmount(
              patient['Pending Amount']?.toString() ?? '0',
              showSymbol: false),
        ]);
        break;
      case 'bed transfer':
        data.addAll([
          patient['Patient Name'] ?? '--',
          patient['Age'] ?? '--',
          patient['Gender'] ?? '--',
          patient['UHID No'] ?? '--',
          DateFormatter.formatDate(patient['Bed_End_Date']),
          patient['FROM WARD'] ?? '--',
          patient['TO WARD'] ?? '--',
        ]);
        break;
      case 'opd visit':
        data.addAll([
          patient['Patient Name'] ?? '--',
          patient['Age'] ?? '--',
          patient['Gender'] ?? '--',
          patient['UHID No'] ?? '--',
          DateFormatter.formatDate(patient['Visit Date']),
          patient['Doctor Name'] ?? '--',
        ]);
        break;
      case 'opd payment':
        data.addAll([
          patient['Patient Name'] ?? '--',
          patient['Age'] ?? '--',
          patient['Gender'] ?? '--',
          patient['UHID No'] ?? '--',
          DateFormatter.formatDate(patient['Date Of Payment']),
          FormatAmount.formatAmount(patient['Paid Amount']?.toString() ?? '0',
              showSymbol: false),
          patient['Doctor Name'] ?? '--',
          FormatAmount.formatAmount(patient['Bill Amount']?.toString() ?? '0',
              showSymbol: false),
        ]);
        break;
      case 'opd bills':
        data.addAll([
          patient['Patient Name'] ?? '--',
          patient['Age'] ?? '--',
          patient['Gender'] ?? '--',
          patient['UHID No'] ?? '--',
          DateFormatter.formatDate(patient['Admission Date']),
          FormatAmount.formatAmount(patient['Bill Amount']?.toString() ?? '0',
              showSymbol: false),
          patient['Bill No'] ?? '--',
        ]);
        break;
      case 'refund':
        data.addAll([
          patient['Patient Name'] ?? '--',
          patient['Age'] ?? '--',
          patient['Gender'] ?? '--',
          patient['UHID No'] ?? '--',
          DateFormatter.formatDate(patient['Date Of Refund']),
          FormatAmount.formatAmount(patient['Refund Amount']?.toString() ?? '0',
              showSymbol: false),
        ]);
        break;
      case 'discount':
        data.addAll([
          patient['Patient Name'] ?? '--',
          patient['Age'] ?? '--',
          patient['Gender'] ?? '--',
          patient['UHID No'] ?? '--',
          DateFormatter.formatDate(patient['Date Of Discount']),
          FormatAmount.formatAmount(
              patient['Discount Amount']?.toString() ?? '0',
              showSymbol: false),
        ]);
        break;
      default:
        continue;
    }

    if (!screenWiseData.containsKey(screenName)) {
      screenWiseData[screenName] = [];
    }
    screenWiseData[screenName]!.add(data);
  }

// Add a page per screen type
  for (final entry in screenWiseData.entries) {
    final screen = entry.key;
    final data = entry.value;
    final headers = screenWiseHeaders[screen] ?? [];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            '${screen[0].toUpperCase()}${screen.substring(1)} Report',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: headers,
            data: data,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
            ),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
            border: pw.TableBorder.all(color: PdfColors.grey),
            cellHeight: 25,
          ),
        ],
        footer: (context) => pw.Text(
          'Generated on ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
          style: pw.TextStyle(
            fontSize: 9,
          ),
        ),
      ),
    );
  }

  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save());
}
