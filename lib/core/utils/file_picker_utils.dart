import 'package:file_picker/file_picker.dart';

class FilePickerUtils {
  Future<PlatformFile?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );

    if (result == null) return null;
    return result.files.single;
  }
}
