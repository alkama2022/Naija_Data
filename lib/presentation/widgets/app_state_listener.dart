import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/widgets.dart';

/// Rebuilds a screen when the store, the wallet or the Auto-Buy rules change.
///
/// Screens used to rely on the whole `MaterialApp` being rebuilt by a global
/// listener. That was both slow and wrong: a route that is already mounted
/// keeps its own widget tree, so most of those rebuilds never reached the
/// screen. Listening in the screen itself is cheap and actually updates it.
mixin AppStateListener<T extends StatefulWidget> on State<T> {
  void _onAppStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    appStateListenable.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    appStateListenable.removeListener(_onAppStateChanged);
    super.dispose();
  }
}
