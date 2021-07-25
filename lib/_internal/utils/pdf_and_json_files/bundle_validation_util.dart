import 'dart:convert';
import 'dart:io';

import 'package:wvems_protocols/_internal/utils/utils.dart';
import 'package:wvems_protocols/models/models.dart';

class BundleValidationUtil {
  final DocumentsUtil _documentsUtil = DocumentsUtil();

  /// Verify that the three files that are necessary for a
  /// given bundle are named appropriately:
  ///
  /// Naming convention is defined by the `bundleId` value
  /// 1) bundleID/bundleID.pdf
  /// 2) bundleID/bundleID.json
  /// 3) bundleID/bundleID-toc.pdf
  ///
  bool doesMapContainAllFiles(String bundleId, Map<String, File> filesMap) =>
      filesMap.containsKey(_documentsUtil.toPdf(bundleId)) &&
      filesMap.containsKey(_documentsUtil.toJson(bundleId)) &&
      filesMap.containsKey(_documentsUtil.toJsonWithToc(bundleId));

  Future<PdfTableOfContentsState> loadTocJsonFromJsonString(
      String jsonString) async {
    var tocJsonState = const PdfTableOfContentsState.loading();

    /// Attempt to load the Table of Contents JSON
    try {
      final Map<String, dynamic> textList = jsonDecode(jsonString);

      tocJsonState = PdfTableOfContentsState.data(textList);
      print('Temporary JSON TOC loaded from Asset');
    } catch (e, st) {
      print('Error checking JSON Asset for bundle version: $e');
      tocJsonState = PdfTableOfContentsState.error(e, st);
    }
    return tocJsonState;
  }

  /// Bundle versions retruned as -1 occur if integer is invalid, is NAN, or if null.
  /// It also returns as -1 if any errors occurred loading the Table of Contents JSON.
  int getBundleVersionFromTocJson(PdfTableOfContentsState tocJsonState) {
    final ValidatorsUtil validatorsUtil = ValidatorsUtil();

    late final int bundleVersion;
    late final String bundleVersionString;

    tocJsonState.when(
      /// Only attempt to decode bundleVersionString if the JSON was successfully loaded
      data: (data) {
        /// Obtain the string value assigned to the key 'version'.
        /// This should be an integer referencing the bundle's current version.
        bundleVersionString = data['version'] ?? '';

        /// Set bundleVersion integer, if valid. Else, set it as -1
        bundleVersion = validatorsUtil.isValidInteger(bundleVersionString)
            ? validatorsUtil.stringToInt(bundleVersionString)
            : -1;
      },
      loading: () {
        print('Cannot set bundle version: still LOADING');
        bundleVersionString = '';
        bundleVersion = -1;
      },
      error: (error, st) {
        print('Error checking bundle version: $error');
        bundleVersionString = '';
        bundleVersion = -1;
      },
    );

    print('Bundle #: $bundleVersion');

    return bundleVersion;
  }
}
