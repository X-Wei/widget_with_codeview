import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'syntax_highlighter.dart';

class SourceCodeView extends StatefulWidget {
  final String filePath;
  final String? codeLinkPrefix;

  const SourceCodeView({Key? key, required this.filePath, this.codeLinkPrefix})
      : super(key: key);

  String? get codeLink => this.codeLinkPrefix == null
      ? null
      : '${this.codeLinkPrefix}/${this.filePath}';

  @override
  _SourceCodeViewState createState() {
    return _SourceCodeViewState();
  }
}

class _SourceCodeViewState extends State<SourceCodeView> {
  double _textScaleFactor = 1.0;

  Widget _getCodeView(String codeContent, BuildContext context) {
    codeContent = codeContent.replaceAll('\r\n', '\n');
    final SyntaxHighlighterStyle style =
        Theme.of(context).brightness == Brightness.dark
            ? SyntaxHighlighterStyle.darkThemeStyle()
            : SyntaxHighlighterStyle.lightThemeStyle();
    return Container(
      constraints: BoxConstraints.expand(),
      child: Scrollbar(
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectableText.rich(
              TextSpan(
                style: GoogleFonts.droidSansMono(fontSize: 12)
                    .apply(fontSizeFactor: this._textScaleFactor),
                children: <TextSpan>[
                  DartSyntaxHighlighter(style).format(codeContent)
                ],
              ),
              style: DefaultTextStyle.of(context)
                  .style
                  .apply(fontSizeFactor: this._textScaleFactor),
            ),
          ),
        ),
      ),
    );
  }

  List<SpeedDialChild> _buildFloatingButtons() {
    return <SpeedDialChild>[
      if (this.widget.codeLink != null)
        SpeedDialChild(
          child: Icon(Icons.content_copy),
          label: 'Copy code link to clipboard',
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          onTap: () {
            Clipboard.setData(ClipboardData(text: this.widget.codeLink));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Code link copied to clipboard!'),
            ));
          },
        ),
      if (this.widget.codeLink != null)
        SpeedDialChild(
          child: Icon(Icons.open_in_new),
          label: 'View code in browser',
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          onTap: () => url_launcher.launch(this.widget.codeLink!),
        ),
      SpeedDialChild(
        child: Icon(Icons.zoom_out),
        label: 'Zoom out',
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onTap: () => setState(() {
          this._textScaleFactor = max(0.8, this._textScaleFactor - 0.1);
        }),
      ),
      SpeedDialChild(
        child: Icon(Icons.zoom_in),
        label: 'Zoom in',
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onTap: () => setState(() {
          this._textScaleFactor += 0.1;
        }),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DefaultAssetBundle.of(context).loadString(widget.filePath),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            body: Padding(
              padding: EdgeInsets.all(4.0),
              child: _getCodeView(snapshot.data!, context),
            ),
            floatingActionButton: SpeedDial(
              renderOverlay: false,
              overlayOpacity: 0,
              children: _buildFloatingButtons(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              activeBackgroundColor: Colors.red,
              activeForegroundColor: Colors.white,
              icon: Icons.menu,
              activeIcon: Icons.close,
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
