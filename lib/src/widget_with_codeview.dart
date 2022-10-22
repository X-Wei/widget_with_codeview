library widget_with_codeview;

import 'package:flutter/material.dart';

import 'source_code_view.dart';

class WidgetWithCodeView extends StatefulWidget {
  // Path of source file (relative to project root). The file's content will be
  // shown in the "Code" tab.
  final String sourceFilePath;
  final Widget child;
  final String? codeLinkPrefix;
  final bool? showLabelText;
  final Color? iconBackgroundColor;
  final Color? iconForegroundColor;
  final Color? labelBackgroundColor;
  final TextStyle? labelTextStyle;
  // Can be used to add a hook when switching tabs.
  final void Function(TabController)? tabChangeListener;
  final Widget? headerWidget;
  final Widget? footerWidget;

  const WidgetWithCodeView({
    Key? key,
    required this.child,
    required this.sourceFilePath,
    this.codeLinkPrefix,
    this.showLabelText,
    this.iconBackgroundColor,
    this.iconForegroundColor,
    this.labelBackgroundColor,
    this.labelTextStyle,
    this.tabChangeListener,
    this.headerWidget,
    this.footerWidget,
  }) : super(key: key);

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
  _WidgetWithCodeViewState createState() => _WidgetWithCodeViewState();
}

class _WidgetWithCodeViewState extends State<WidgetWithCodeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.tabChangeListener != null) {
      _tabController.addListener(
        () => widget.tabChangeListener!(_tabController),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get routeName => '/${this.runtimeType.toString()}';

  Widget get sourceCodeView => SourceCodeView(
        filePath: this.widget.sourceFilePath,
        codeLinkPrefix: this.widget.codeLinkPrefix,
        labelTextStyle: widget.labelTextStyle,
        showLabelText: widget.showLabelText ?? true,
        iconBackgroundColor: widget.iconBackgroundColor,
        iconForegroundColor: widget.iconForegroundColor,
        labelBackgroundColor: widget.labelBackgroundColor,
        headerWidget: widget.headerWidget,
        footerWidget: widget.footerWidget,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _ColoredTabBar(
        color: Theme.of(context).primaryColor,
        tabBar: TabBar(
          controller: _tabController,
          tabs: WidgetWithCodeView._TABS,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _AlwaysAliveWidget(child: this.widget.child),
          _AlwaysAliveWidget(child: this.sourceCodeView),
        ],
      ),
    );
  }
}

// This widget is always kept alive, so that when tab is switched back, its
// child's state is still preserved.
class _AlwaysAliveWidget extends StatefulWidget {
  final Widget child;

  const _AlwaysAliveWidget({Key? key, required this.child}) : super(key: key);

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

  _ColoredTabBar({Key? key, required this.color, required this.tabBar})
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
