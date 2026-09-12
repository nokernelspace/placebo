import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:placebo/mood.dart';

String formatDateTime(DateTime time) {
  var AM = true;
  var hour = () {
    if (time.hour > 12) {
      AM = false;
      return time.hour - 12;
    } else {
      return time.hour;
    }
  }();
  return "${time.year}-${time.month}-${time.day} ${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${AM ? 'AM' : 'PM'}";
}

String formatDate(DateTime time) {
  return "${time.year}-${time.month}-${time.day}";
}

String formatTime(DateTime time) {
  var AM = true;
  var hour = () {
    if (time.hour > 12) {
      AM = false;
      return time.hour - 12;
    } else {
      return time.hour;
    }
  }();
  return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${AM ? 'AM' : 'PM'}";
}


Future<void> showCancelableMessageBox(
  BuildContext ctx,
  String title,
  String message,
  {void Function()? onConfirm,
  void Function()? onCancel}
) {
  return showDialog<void>(
    context: ctx,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(child: const Text("Cancel"), onPressed: () {
            Navigator.of(ctx).pop();
          }),
          TextButton(child: const Text("Ok"), onPressed: (){
            if (onConfirm != null) {
              onConfirm();
              Navigator.of(ctx).pop();
            }
          }),
        ],
      );
    },
  );
}

Future<void> showConfirmMessageBox(
  BuildContext ctx,
  String title,
  String message,
  void Function()? onPressed,
) {
  return showDialog<void>(
    context: ctx,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(child: const Text("Ok"), onPressed: (){
            if (onPressed != null) {
              onPressed();
              Navigator.of(ctx).pop();
            }
          }),
        ],
      );
    },
  );
}

Future<void> showEditDialogBox(
  BuildContext ctx,
  String title,
  TextEditingController controller,
  void Function()? onConfirm,
) {
  return showDialog<void>(
    context: ctx,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: Text(title),
        content: TextField(maxLines: 1, controller: controller),

        ///NOTE :very interesting dart type specification
        actions: <Widget>[
          TextButton(child: const Text("Cancel"), onPressed: () {
            Navigator.of(ctx).pop();
          }),
          TextButton(child: const Text("Ok"), onPressed: (){
            if (onConfirm != null) {
              onConfirm();
              Navigator.of(ctx).pop();
            }
          }),
        ],
      );
    },
  );
}

class Collection<T> {
  Directory dir;
  Collection(this.dir);

  Future<void> add(Map<String, dynamic> mapToJson, String filename) async {
    final file = File('${dir.path}/${filename}');
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    print("Wrote to ${file.path}");
    await file.writeAsString(jsonEncode(mapToJson));
  }
  Future<List<T>> sortedList() async {
    List<T> out = List.empty(growable: true);
    await for (final file in Directory('${dir.path}').list()) {
      if (file is File && getFilePathExtension(file.path) == "mood") {
        var txt = file.readAsStringSync();
        //  out.add(T.name fromJson(jsonDecode(txt)));

        //  out.add(Mood.fromJson(jsonDecode(txt)));
      }
    }

    return out;
  }

  List<Mood> sortedListSync() {
    List<Mood> out = List.empty(growable: true);
    for (final file in Directory('${dir.path}').listSync()) {
      if (file is File && getFilePathExtension(file.path) == "mood") {
        var txt = file.readAsStringSync();
         out.add(Mood.fromJson(jsonDecode(txt)));
      }
    }

    return out;
  }
}

class Filesystem {
  static late var TMP_DIR;
  // Files the users should be able to access
  static late var DOCS_DIR;
  // More difficult to access files
  static late var APP_SUPPORT;

  static void initialize() async {
    TMP_DIR = await getTemporaryDirectory();
    if (Platform.isAndroid) {
      DOCS_DIR = await getExternalStorageDirectory();
    }
    else {
      DOCS_DIR = await getApplicationDocumentsDirectory();
    }
    APP_SUPPORT = await getApplicationSupportDirectory();
  }

  // https://xkcd.com/908/
  // They changed it
  // static final THE_CLOUD = FirebaseFirestore.instance;
  // static final DATABASE = THE_CLOUD;

  /// Wrapper For keeping it simple, stupid
  static Collection dir(String name) {
    return collection(name);
  }
  /// Copying the syntax of firebase firestore
  static Collection collection(String name) {
    final directory = Directory('${DOCS_DIR.path}/${name}');

    if (!directory.existsSync()) {
      //recursive: true
      directory.createSync();
    }

    return Collection(directory);
  }
}

String sanitizeFilename(String name) {
  // Remove/replace characters invalid on any major platform
  final sanitized = name
      .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
      .replaceAll(RegExp(r'\.{2,}'), '_') // replace consecutive dots
      .trim();

  // Remove leading/trailing dots and spaces (problematic on Windows)
  final trimmed = sanitized.replaceAll(RegExp(r'^[.\s]+|[.\s]+$'), '');

  if (trimmed.isEmpty) return 'unnamed';

  // Windows reserved device names
  final reserved = {
    'CON',
    'PRN',
    'AUX',
    'NUL',
    'COM1',
    'COM2',
    'COM3',
    'COM4',
    'COM5',
    'COM6',
    'COM7',
    'COM8',
    'COM9',
    'LPT1',
    'LPT2',
    'LPT3',
    'LPT4',
    'LPT5',
    'LPT6',
    'LPT7',
    'LPT8',
    'LPT9',
  };

  final base = trimmed.split('.').first.toUpperCase();
  if (reserved.contains(base)) {
    return '_$trimmed';
  }

  /// This is really anoyying to think at on iOS (ㆆ _ ㆆ)
  /// The `Files` app treats the first dot as the extension, not the last dot....
  trimmed.replaceAll(".", "-");
  return trimmed;
}

String getFilePathExtension(String path) {
  String ext = path.split('.').last;
  return ext;
}