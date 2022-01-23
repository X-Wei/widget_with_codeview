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
  final bool showLabelText;
  final Color? iconBackgroundColor;
  final Color? iconForegroundColor;
  final Color? labelBackgroundColor;
  final TextStyle? labelTextStyle;
  final SyntaxHighlighterStyle? syntaxHighlighterStyle;

  const SourceCodeView({
    Key? key,
    required this.filePath,
    this.codeLinkPrefix,
    this.showLabelText = false,
    this.iconBackgroundColor,
    this.iconForegroundColor,
    this.labelBackgroundColor,
    this.labelTextStyle,
    this.syntaxHighlighterStyle,
  }) : super(key: key);

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
    final SyntaxHighlighterStyle style = widget.syntaxHighlighterStyle ??
        (Theme.of(context).brightness == Brightness.dark
            ? SyntaxHighlighterStyle.darkThemeStyle()
            : SyntaxHighlighterStyle.lightThemeStyle());
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

  List<SpeedDialChild> _buildFloatingButtons({
    TextStyle? labelTextStyle,
    Color? iconBackgroundColor,
    Color? iconForegroundColor,
    Color? labelBackgroundColor,
    required bool showLabelText,
  }) =>
      [
        if (this.widget.codeLink != null)
          SpeedDialChild(
            child: Icon(Icons.content_copy),
            labelWidget: showLabelText ? Text('Copy code to clipboard') : null,
            backgroundColor: iconBackgroundColor,
            foregroundColor: iconForegroundColor,
            labelBackgroundColor: labelBackgroundColor,
            labelStyle: labelTextStyle,
            onTap: () async {
              Clipboard.setData(ClipboardData(
                  text: await DefaultAssetBundle.of(context)
                      .loadString(widget.filePath)));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Code copied to clipboard!'),
              ));
            },
          ),
        if (this.widget.codeLink != null)
          SpeedDialChild(
            child: Icon(Icons.open_in_new),
            labelWidget: showLabelText ? Text('View code in browser') : null,
            backgroundColor: iconBackgroundColor,
            foregroundColor: iconForegroundColor,
            labelBackgroundColor: labelBackgroundColor,
            labelStyle: labelTextStyle,
            onTap: () => url_launcher.launch(this.widget.codeLink!),
          ),
        SpeedDialChild(
          child: Icon(Icons.zoom_out),
          label: showLabelText ? 'Zoom out' : null,
          // labelWidget: showLabelText ? Text('Zoom out') : null,
          backgroundColor: iconBackgroundColor,
          foregroundColor: iconForegroundColor,
          labelBackgroundColor: labelBackgroundColor,
          labelStyle: labelTextStyle,
          onTap: () => setState(() {
            this._textScaleFactor = max(0.8, this._textScaleFactor - 0.1);
          }),
        ),
        SpeedDialChild(
          child: Icon(Icons.zoom_in),
          labelWidget: showLabelText ? Text('Zoom in') : null,
          backgroundColor: iconBackgroundColor,
          foregroundColor: iconForegroundColor,
          labelBackgroundColor: labelBackgroundColor,
          labelStyle: labelTextStyle,
          onTap: () => setState(() {
            this._textScaleFactor += 0.1;
          }),
        ),
      ];

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
              children: _buildFloatingButtons(
                labelTextStyle: widget.labelTextStyle,
                iconBackgroundColor: widget.iconBackgroundColor,
                iconForegroundColor: widget.iconForegroundColor,
                labelBackgroundColor: widget.labelBackgroundColor,
                showLabelText: widget.showLabelText,
              ),
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
