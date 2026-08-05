import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/party/models/party_model.dart';
import '../../features/party/models/ledger_entry_model.dart';

class PdfExportService {
  static Future<void> generateAndShareLedgerReport(
      PartyModel party, List<LedgerEntryModel> entries) async {
    final pdf = pw.Document();

    // Sort entries chronologically for the report
    final sortedEntries = List<LedgerEntryModel>.from(entries)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final isCustomer = party.isCustomer;
    final title = '${party.name} Ledger Report';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(title, party),
            pw.SizedBox(height: 20),
            _buildSummary(party, sortedEntries),
            pw.SizedBox(height: 20),
            _buildEntriesTable(sortedEntries, isCustomer),
            pw.SizedBox(height: 20),
            _buildFooter(),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'ledger_report_${party.name.replaceAll(' ', '_')}.pdf',
    );
  }

  static pw.Widget _buildHeader(String title, PartyModel party) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
        ),
        if (party.phone != null)
          pw.Text(
            'Phone: ${party.phone}',
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
          ),
      ],
    );
  }

  static pw.Widget _buildSummary(PartyModel party, List<LedgerEntryModel> entries) {
    double totalGiven = 0;
    double totalGot = 0;

    for (var entry in entries) {
      if (entry.isDebit) {
        totalGiven += entry.amount;
      } else {
        totalGot += entry.amount;
      }
    }

    final balanceLabel = party.balance >= 0 ? "You'll Get" : "You'll Give";
    final balanceColor = party.balance >= 0 ? PdfColors.green : PdfColors.red;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Total Given: Rs ${totalGiven.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
              pw.SizedBox(height: 4),
              pw.Text('Total Got: Rs ${totalGot.toStringAsFixed(0)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Net Balance', style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
              pw.Text(
                'Rs ${party.balance.abs().toStringAsFixed(0)}',
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: balanceColor),
              ),
              pw.Text(balanceLabel, style: pw.TextStyle(fontSize: 10, color: balanceColor)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildEntriesTable(List<LedgerEntryModel> entries, bool isCustomer) {
    return pw.TableHelper.fromTextArray(
      headers: ['Date', 'Details', 'Given (Rs)', 'Got (Rs)', 'Balance (Rs)'],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
      data: entries.map((entry) {
        return [
          DateFormat('dd MMM yy').format(entry.createdAt),
          entry.note ?? (entry.items.isNotEmpty ? '${entry.items.length} Items' : '-'),
          entry.isDebit ? entry.amount.toStringAsFixed(0) : '',
          entry.isCredit ? entry.amount.toStringAsFixed(0) : '',
          entry.balanceAfter.abs().toStringAsFixed(0) + (entry.balanceAfter >= 0 ? ' (Get)' : ' (Give)'),
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 8),
        pw.Text(
          'Powered by Zenvyro Labs',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600),
        ),
      ],
    );
  }
}
