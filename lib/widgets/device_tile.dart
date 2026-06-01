import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../l10n/l10n.dart';
import '../services/sigurdos_ecosystem.dart';
import '../theme/sigurdos_theme.dart';
import 'signal_ui.dart';

/// A reusable tile widget for displaying a MeshCore device in a list.
/// SigurdOS devices get a cyan #SigurdOS badge.
class DeviceTile extends StatelessWidget {
  final ScanResult scanResult;
  final VoidCallback onTap;

  const DeviceTile({super.key, required this.scanResult, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final device = scanResult.device;
    final rssi = scanResult.rssi;
    final name = device.platformName.isNotEmpty
        ? device.platformName
        : scanResult.advertisementData.advName;
    final isSigurdOS = isSigurdOSDevice(name);

    return ListTile(
      leading: _buildSignalIcon(rssi),
      title: Row(
        children: [
          Flexible(
            child: Text(
              name.isNotEmpty ? name : context.l10n.common_unknownDevice,
              style: SigurdOSTheme.pixelBody(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isSigurdOS) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFFF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(0),
                border: Border.all(
                  color: const Color(0xFF00BFFF).withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: const Text(
                '#SigurdOS',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF00BFFF),
                  letterSpacing: 1.5,
                  fontFamily: 'PressStart2P',
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        device.remoteId.toString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 96),
        child: ElevatedButton(
          onPressed: onTap,
          child: Text(
            context.l10n.common_connect,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildSignalIcon(int rssi) {
    final tier = rssi >= -60
        ? 0
        : rssi >= -70
        ? 1
        : rssi >= -80
        ? 2
        : rssi >= -90
        ? 3
        : 4;
    final signalUi = signalUiForStrengthTier(tier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(signalUi.icon, color: signalUi.color),
        Text(
          '$rssi dBm',
          style: TextStyle(fontSize: 10, color: signalUi.color),
        ),
      ],
    );
  }
}
