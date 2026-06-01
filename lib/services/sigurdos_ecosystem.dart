/// SigurdOS ecosystem integration service.
///
/// Provides SigurdOS-specific device detection, firmware interaction hooks,
/// and ecosystem features that extend the base MeshCore protocol.
///
/// This is the foundation layer — T-Deck firmware commands, OTA update
/// plumbing, and device-specific settings will be built on top of this.
library;

/// Check whether a BLE device name indicates a SigurdOS device.
bool isSigurdOSDevice(String deviceName) {
  return deviceName.startsWith('SigurdOS-');
}

/// Check whether a device name is any known MeshCore-compatible device.
bool isMeshCoreDevice(String deviceName) {
  const prefixes = [
    'SigurdOS-',
    'MeshCore-',
    'Whisper-',
    'WisCore-',
    'Seeed',
    'Lilygo',
    'HT-',
    'LowMesh_MC_',
    'NRF52',
  ];
  return prefixes.any((p) => deviceName.startsWith(p));
}

/// SigurdOS firmware variant identifiers.
enum SigurdOSVariant {
  /// LilyGo T-Deck running SigurdOS firmware
  tdeck,

  /// LilyGo T-Pager running SigurdOS firmware
  tpager,

  /// Generic MeshCore-compatible device
  generic,
}

/// Parse the device name to determine the SigurdOS variant.
SigurdOSVariant sigurdOSVariantFromName(String deviceName) {
  if (deviceName.contains('T-Deck') || deviceName.contains('tdeck')) {
    return SigurdOSVariant.tdeck;
  }
  if (deviceName.contains('T-Pager') || deviceName.contains('tpager')) {
    return SigurdOSVariant.tpager;
  }
  return SigurdOSVariant.generic;
}

/// SigurdOS-specific firmware capabilities that extend MeshCore protocol.
class SigurdOSCapabilities {
  final bool hasDisplay;
  final bool hasKeyboard;
  final bool hasTouch;
  final bool hasGPS;
  final bool hasSDCard;

  const SigurdOSCapabilities({
    this.hasDisplay = false,
    this.hasKeyboard = false,
    this.hasTouch = false,
    this.hasGPS = false,
    this.hasSDCard = false,
  });

  /// Default capabilities for known variants.
  factory SigurdOSCapabilities.forVariant(SigurdOSVariant variant) {
    switch (variant) {
      case SigurdOSVariant.tdeck:
        return const SigurdOSCapabilities(
          hasDisplay: true,
          hasKeyboard: true,
          hasTouch: true,
          hasGPS: true,
          hasSDCard: true,
        );
      case SigurdOSVariant.tpager:
        return const SigurdOSCapabilities(
          hasDisplay: true,
          hasKeyboard: true,
          hasGPS: true,
          hasSDCard: false,
        );
      case SigurdOSVariant.generic:
        return const SigurdOSCapabilities();
    }
  }
}
