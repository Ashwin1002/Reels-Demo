extension StringExtension on String {
  // isSvg
  bool get isSvg => endsWith(".svg");

  // isPng
  bool get isPng => endsWith(".png");

  // isValid video url
  bool get isValidVideoUrl {
    final videoExtensions = [
      '.mp4',
      '.mov',
      '.wmv',
      '.flv',
      '.avi',
      '.webm',
      '.mkv',
      '.mpeg',
    ];

    Uri? uri = Uri.tryParse(this);
    if (uri == null || !uri.hasScheme) return false;

    // Check if direct video file
    if (videoExtensions.any((ext) => toLowerCase().endsWith(ext))) {
      return true;
    }

    // Check if it's a valid YouTube or Vimeo link
    return contains('youtube.com/watch?v=') ||
        contains('youtu.be/') ||
        contains('vimeo.com/');
  }

  bool get isValidImageUrl {
    final imageExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.bmp',
      '.webp',
      '.svg',
    ];

    Uri? uri = Uri.tryParse(this);
    if (uri == null || !uri.hasScheme) return false;

    return contains("picsum.photos") ||
        imageExtensions.any((ext) => toLowerCase().endsWith(ext));
  }
}
