import 'package:flutter/material.dart';
import 'package:sigurdos_client/connector/meshcore_connector.dart';
import 'package:sigurdos_client/widgets/battery_indicator.dart';
import 'package:provider/provider.dart';

class AppBarTitle extends StatelessWidget {
  @Deprecated('Title is now always "SigurdOS" — this parameter is ignored')
  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final bool showBatteryIndicator;
  final bool subtitle;

  // ignore: use_key_in_widget_constructors
  const AppBarTitle(
    this.title, {
    this.leading,
    this.trailing,
    this.showBatteryIndicator = true,
    this.subtitle = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final connector = context.watch<MeshCoreConnector>();
    final selfName = connector.selfName;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final showSubtitle =
            connector.isConnected && selfName != null && subtitle;
        final showBattery = showBatteryIndicator && availableWidth >= 160;

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            leading ?? const SizedBox.shrink(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SigurdOS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showSubtitle)
                    Text(
                      selfName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (showBattery) ...[
              const SizedBox(width: 6),
              BatteryIndicator(connector: connector),
            ],
            if (trailing != null) ...[const SizedBox(width: 4), trailing!],
          ],
        );
      },
    );
  }
}
