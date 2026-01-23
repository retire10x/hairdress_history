import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../services/backup_service.dart';

class BackupRestoreDialog extends StatelessWidget {
  final VoidCallback onBackupComplete;
  final Future<void> Function() onRestoreComplete;

  const BackupRestoreDialog({
    super.key,
    required this.onBackupComplete,
    required this.onRestoreComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '데이터 백업 및 복원',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            // 백업 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showBackupDialog(context),
                icon: const Icon(Icons.backup),
                label: const Text('백업 생성'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(0, 50),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // 복원 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showRestoreDialog(context),
                icon: const Icon(Icons.restore),
                label: const Text('데이터 복원 (MSSQL 포함)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(0, 50),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 닫기 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    minimumSize: const Size(0, 50),
                  ),
                  child: const Text('닫기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showBackupDialog(BuildContext context) async {
    Navigator.of(context).pop(); // 백업/복원 다이얼로그 닫기

    // 진행 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('백업 파일 생성 중...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final backupService = BackupService();
      
      // Android/iOS에서는 파일 저장 위치를 사용자가 선택하도록 함
      String? savePath;
      try {
        // ignore: undefined_prefixed_name
        if (Platform.isAndroid || Platform.isIOS) {
          // Mobile: 파일 저장 위치 선택
          final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
          final fileName = 'hairdress_backup_$timestamp.csv';
          
          // 파일 저장 위치 선택
          savePath = await FilePicker.platform.saveFile(
            dialogTitle: '백업 파일 저장 위치 선택',
            fileName: fileName,
            type: FileType.custom,
            allowedExtensions: ['csv'],
          );
          
          if (savePath == null) {
            // 사용자가 취소한 경우
            if (context.mounted) {
              Navigator.of(context).pop(); // 진행 다이얼로그 닫기
            }
            return;
          }
        }
      } catch (e) {
        debugPrint('File picker error: $e');
      }
      
      // 백업 파일 생성
      String filePath;
      if (savePath != null) {
        // 사용자가 선택한 위치에 저장 (Android/iOS)
        final fileBytes = await backupService.createBackupData();
        final file = File(savePath);
        await file.writeAsBytes(fileBytes);
        filePath = savePath;
      } else {
        // Desktop: 기존 방식 (자동 경로)
        filePath = await backupService.createBackup();
      }

      if (context.mounted) {
        Navigator.of(context).pop(); // 진행 다이얼로그 닫기

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('백업 완료'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('백업 파일이 생성되었습니다.'),
                const SizedBox(height: 8),
                Text(
                  '파일 위치:\n$filePath',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ],
          ),
        );
        onBackupComplete();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // 진행 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('백업 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _showRestoreDialog(BuildContext context) async {
    Navigator.of(context).pop(); // 백업/복원 다이얼로그 닫기

    // 덮어쓰기 확인
    final overwrite = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('데이터 복원'),
        content: const Text(
          '기존 데이터를 모두 삭제하고 복원하시겠습니까?\n'
          '(기존 데이터는 백업되지 않습니다)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('복원'),
          ),
        ],
      ),
    );

    if (overwrite != true) return;

    // 파일 선택
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        dialogTitle: '복원할 CSV 파일 선택',
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final filePath = result.files.single.path!;

      // 진행 다이얼로그 표시
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('데이터 복원 중...'),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      final backupService = BackupService();
      final restoreResult = await backupService.restoreFromFile(filePath, overwrite: true);

      if (context.mounted) {
        Navigator.of(context).pop(); // 진행 다이얼로그 닫기

        if (restoreResult.success) {
          // 복원 완료 다이얼로그 표시
          await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('복원 완료'),
              content: Text(
                '데이터 복원이 완료되었습니다.\n\n'
                '고객: ${restoreResult.customerCount}명\n'
                '서비스 기록: ${restoreResult.recordCount}건\n\n'
                '화면이 새로고침됩니다.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('확인'),
                ),
              ],
            ),
          );
          
          // 다이얼로그를 닫은 후 콜백 호출하여 UI 업데이트
          // WidgetsBinding을 사용하여 다음 프레임에서 콜백 실행
          if (context.mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onRestoreComplete();
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('복원 중 오류가 발생했습니다: ${restoreResult.error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // 진행 다이얼로그 닫기
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('파일 선택 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
