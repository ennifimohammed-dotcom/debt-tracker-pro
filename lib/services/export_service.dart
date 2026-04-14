import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';

class ExportService {
  static Future<void> exportToExcel(
      List<Debt> debts, String currency) async {
    final excel = Excel.createExcel();
    final sheet = excel['الديون'];

    final headers = [
      'الاسم', 'الهاتف', 'النوع', 'المبلغ الكلي',
      'المدفوع', 'المتبقي', 'التاريخ', 'الاستحقاق', 'الحالة', 'ملاحظة'
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#C9A84C'),
        fontColorHex: ExcelColor.fromHexString('#000000'),
      );
    }

    final fmt = DateFormat('dd/MM/yyyy');
    for (var i = 0; i < debts.length; i++) {
      final d = debts[i];
      final row = [
        d.name, d.phone,
        d.type == 'lend' ? 'أقرضت' : 'اقترضت',
        '${d.amount.toStringAsFixed(2)} $currency',
        '${d.paidAmount.toStringAsFixed(2)} $currency',
        '${d.remainingAmount.toStringAsFixed(2)} $currency',
        fmt.format(d.createdAt),
        d.dueDate != null ? fmt.format(d.dueDate!) : '-',
        d.isSettled ? 'مسوّى ✓' : 'قيد التسوية',
        d.note ?? '',
      ];
      for (var j = 0; j < row.length; j++) {
        sheet.cell(CellIndex.indexByColumnRow(
                columnIndex: j, rowIndex: i + 1))
            .value = TextCellValue(row[j]);
      }
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/debt_tracker_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final bytes = excel.save();
    if (bytes != null) {
      await File(path).writeAsBytes(bytes);
      await Share.shareXFiles([XFile(path)],
          text: 'تقرير Debt Tracker Pro');
    }
  }
}
