import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:wvems_protocols/controllers/commands/set_page_command.dart';
import 'package:wvems_protocols/controllers/controllers.dart';
import 'package:wvems_protocols/ui/strings.dart';

AppBar homeAppBar(BuildContext context) {
  final PdfStateController controller = Get.find();

  return AppBar(
    centerTitle: true,
    title: Text(S.HOME_VIEW),
    actions: <Widget>[
      FutureBuilder<PDFViewController>(
        future: controller.asyncController.future,
        builder:
            (BuildContext context, AsyncSnapshot<PDFViewController> snapshot) {
          if (snapshot.hasData) {
            return Obx(
              () => (controller.rxPdfController.value != null)
                  ? IconButton(
                      icon: const Icon(Icons.home),
                      onPressed: () async => await SetPageCommand().execute(),
                    )
                  : Container(),
            );
          }
          return Container();
        },
      )
    ],
  );
}
