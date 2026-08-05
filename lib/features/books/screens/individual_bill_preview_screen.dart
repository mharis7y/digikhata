import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/bill.dart';
import 'package:flutter/services.dart' show rootBundle;

class IndividualBillPreviewScreen extends StatelessWidget {
  final Bill bill;
  const IndividualBillPreviewScreen({super.key, required this.bill});

  Future<File> _generatePdf() async {
    final pdf = pw.Document();

    final dateStr = DateFormat('dd-MM-yyyy').format(bill.billDate);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('My Business', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Text('Business Phone'),
              pw.Text('Business Address here'),
              pw.SizedBox(height: 32),
              
              pw.Center(child: pw.Text('Bill', style: pw.TextStyle(fontSize: 32))),
              pw.SizedBox(height: 32),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Bill To:', style: const pw.TextStyle(color: PdfColors.grey)),
                      pw.Text(bill.partyName ?? 'Walk-in Customer', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Bill No. ${bill.billNo ?? bill.id.substring(0, 8)}'),
                      pw.Text(dateStr),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 32),

              // Table Header
              pw.Table(
                columnWidths: const {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(4),
                  2: pw.FlexColumnWidth(1),
                  3: pw.FlexColumnWidth(2),
                  4: pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    children: [
                      pw.Text('#', style: const pw.TextStyle(color: PdfColors.grey)),
                      pw.Text('Name', style: const pw.TextStyle(color: PdfColors.grey)),
                      pw.Text('Qty', style: const pw.TextStyle(color: PdfColors.grey)),
                      pw.Text('Price', style: const pw.TextStyle(color: PdfColors.grey)),
                      pw.Text('Amount', style: const pw.TextStyle(color: PdfColors.grey)),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Divider(color: PdfColors.grey),
                      pw.Divider(color: PdfColors.grey),
                      pw.Divider(color: PdfColors.grey),
                      pw.Divider(color: PdfColors.grey),
                      pw.Divider(color: PdfColors.grey),
                    ]
                  ),
                  for (var i = 0; i < bill.items.length; i++)
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text('${i + 1}')),
                        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text(bill.items[i].name)),
                        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text('${bill.items[i].quantity}')),
                        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text('${bill.items[i].price}')),
                        pw.Padding(padding: const pw.EdgeInsets.symmetric(vertical: 4), child: pw.Text('${bill.items[i].quantity * bill.items[i].price}')),
                      ],
                    ),
                ],
              ),
              
              pw.Divider(),
              pw.SizedBox(height: 16),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Total', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Rs ${bill.totalAmount}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Received: '),
                  pw.Text('Rs ${bill.receivedAmount}'),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/bill_${bill.billNo ?? bill.id.substring(0, 8)}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  void _sharePdf(BuildContext context) async {
    try {
      final file = await _generatePdf();
      await Share.shareXFiles([XFile(file.path)], text: 'Invoice from My Business');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing: $e')));
    }
  }

  void _downloadPdf(BuildContext context) async {
    try {
      final file = await _generatePdf();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error downloading: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF285CCC),
        title: Text('Bill # ${bill.billNo ?? bill.id.substring(0, 8)}', style: const TextStyle(color: Colors.white, fontFamily: 'Poppins')),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My Business', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('Business Phone'),
                    const Text('Business Address here'),
                    const SizedBox(height: 24),
                    const Center(child: Text('Bill', style: TextStyle(fontSize: 24))),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Bill To:', style: TextStyle(color: Colors.grey)),
                            Text(bill.partyName ?? 'Walk-in Customer', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Bill No. ${bill.billNo ?? bill.id.substring(0, 8)}'),
                            Text(DateFormat('dd-MM-yyyy').format(bill.billDate)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Expanded(flex: 1, child: Text('#', style: TextStyle(color: Colors.grey))),
                        Expanded(flex: 3, child: Text('Name', style: TextStyle(color: Colors.grey))),
                        Expanded(flex: 1, child: Text('Qty', style: TextStyle(color: Colors.grey))),
                        Expanded(flex: 2, child: Text('Price', style: TextStyle(color: Colors.grey))),
                        Expanded(flex: 2, child: Text('Amount', style: TextStyle(color: Colors.grey))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    ...bill.items.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(flex: 1, child: Text('${i + 1}')),
                            Expanded(flex: 3, child: Text(item.name)),
                            Expanded(flex: 1, child: Text('${item.quantity}')),
                            Expanded(flex: 2, child: Text('${item.price}')),
                            Expanded(flex: 2, child: Text('${item.quantity * item.price}')),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                    const Divider(thickness: 2),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Rs ${bill.totalAmount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Received: '),
                        Text('${bill.receivedAmount}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionBtn(Icons.download, 'Download', () => _downloadPdf(context)),
                _buildActionBtn(Icons.share, 'Share', () => _sharePdf(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFEF4444)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
