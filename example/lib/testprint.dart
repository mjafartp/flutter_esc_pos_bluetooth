import 'dart:typed_data';
import 'package:flutter_esc_pos_bluetooth/flutter_esc_pos_bluetooth.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';


class TestPrint {
  FlutterEscPosBluetooth bluetooth = FlutterEscPosBluetooth.instance;

   sample() async {
    //SIZE
    // 0- normal size text
    // 1- only bold text
    // 2- bold with medium text
    // 3- bold with large text
    //ALIGN
    // 0- ESC_ALIGN_LEFT
    // 1- ESC_ALIGN_CENTER
    // 2- ESC_ALIGN_RIGHT

//     var response = await http.get("IMAGE_URL");
//     Uint8List bytes = response.bodyBytes;
    bluetooth.isConnected.then((isConnected) async{
      if (isConnected??false) {
        List<int> bytes = [];
        // Using default profile
        final profile = await CapabilityProfile.load();
        final generator = Generator(PaperSize.mm80, profile);

        bytes += generator.text(
            'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');

        bytes += generator.text('Bold text', styles: PosStyles(bold: true));
        bytes += generator.text('Reverse text', styles: PosStyles(reverse: true));
        bytes += generator.text('Underlined text',
            styles: PosStyles(underline: true), linesAfter: 1);
        bytes += generator.text('Align left', styles: PosStyles(align: PosAlign.left));
        bytes += generator.text('Align center', styles: PosStyles(align: PosAlign.center));
        bytes += generator.text('Align right',
            styles: PosStyles(align: PosAlign.right), linesAfter: 1);

        bytes += generator.text('Text size 200%',
            styles: PosStyles(
              height: PosTextSize.size2,
              width: PosTextSize.size2,
            ));

        bytes += generator.feed(2);
        bytes += generator.cut();
        bytes += generator.reset();
        bluetooth.writeBytes(Uint8List.fromList(bytes));
      }
    });
  }
}