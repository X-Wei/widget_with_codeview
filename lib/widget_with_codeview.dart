library widget_with_codeview;

import 'package:flutter/material.dart';

import 'source_code_view.dart';

class WidgetWithCodeView extends StatelessWidget {
  // Path of source file (relative to project root). The file's content will be
  // shown in the "Code" tab.
  final String sourceFilePath;
  final Widget child;
  final String codeLinkPrefix;

  const WidgetWithCodeView({
    Key key,
    @required this.child,
    @required this.sourceFilePath,
    this.codeLinkPrefix,
  }) : super(key: key);

  String get routeName => '/${this.runtimeType.toString()}';

  Widget get sourceCodeView => SourceCodeView(
      filePath: this.sourceFilePath, codeLinkPrefix: this.codeLinkPrefix);

  static const _TABS = <Widget>[
    Tab(
      child: ListTile(
        leading: Icon(Icons.phone_android, color: Colors.white),
        title: Text('Preview', style: TextStyle(color: Colors.white)),
      ),
    ),
    Tab(
      child: ListTile(
        leading: Icon(Icons.code, color: Colors.white),
        title: Text('Code', style: TextStyle(color: Colors.white)),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: _ColoredTabBar(
          color: Theme.of(context).primaryColor,
          tabBar: TabBar(tabs: _TABS),
        ),
        body: TabBarView(
          children: <Widget>[
            _AlwaysAliveWidget(child: this.child),
            _AlwaysAliveWidget(child: this.sourceCodeView),
          ],
        ),
      ),
    );
  }
}

// This widget is always kept alive, so that when tab is switched back, its
// child's state is still preserved.
class _AlwaysAliveWidget extends StatefulWidget {
  final Widget child;

  const _AlwaysAliveWidget({Key key, @required this.child}) : super(key: key);

  @override
  _AlwaysAliveWidgetState createState() => _AlwaysAliveWidgetState();
}

class _AlwaysAliveWidgetState extends State<_AlwaysAliveWidget>
    with AutomaticKeepAliveClientMixin<_AlwaysAliveWidget> {
  @override
  Widget build(BuildContext context) {
    super.build(context); // This build method is annotated "@mustCallSuper".
    return this.widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}

class _ColoredTabBar extends Container implements PreferredSizeWidget {
  final Color color;
  final TabBar tabBar;

  _ColoredTabBar({Key key, @required this.color, @required this.tabBar})
      : super(key: key);

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Material(
        elevation: 4.0,
        color: color,
        child: tabBar,
      );
}
