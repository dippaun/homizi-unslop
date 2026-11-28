import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:homizi/core/config/app_config.dart';
import 'package:homizi/core/l10n/translate.dart';
import 'package:homizi/core/location/location_models.dart';
import 'package:homizi/core/motion/animated_route.dart';
import 'package:homizi/core/theme/homizi_colors.dart';
import 'package:homizi/ui/kit/real_life_icons.dart';
import 'package:latlong2/latlong.dart';

/// Home (A) to office (B), with a time for car, bike, transit, and walk.
class CommuteRouteMap extends StatelessWidget {
  const CommuteRouteMap({
    required this.home,
    required this.office,
    this.carMinutes,
    this.mapsApiKey = '',
    super.key,
  });

  final GeoFix home;
  final GeoFix office;
  final String mapsApiKey;

  /// Measured car time when Maps returned one. Other modes stay estimates.
  final int? carMinutes;

  @override
  Widget build(BuildContext context) {
    final roadKm = officeRoadKm(home, office);
    final kmLabel = officeKmNumber(roadKm);
    final modes = <(IconData, String, int)>[
      (RealLifeIcons.car, 'Car', carMinutes ?? travelMinutes(roadKm, 28)),
      (RealLifeIcons.bike, 'Bike', travelMinutes(roadKm, 16)),
      (RealLifeIcons.bus, 'Transit', travelMinutes(roadKm, 18)),
      (RealLifeIcons.walk, 'Walk', travelMinutes(roadKm, 4.8)),
    ];
    final mid = LatLng(
      (home.latitude + office.latitude) / 2,
      (home.longitude + office.longitude) / 2,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          key: const Key('listing-commute-map'),
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 160,
            width: double.infinity,
            child: _map(mid, roadKm),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          homiziText(context, 'About $kmLabel km · A home, B office'),
          style: const TextStyle(
            color: HomiziColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final mode in modes)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: HomiziColors.soft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(mode.$1, size: 14, color: HomiziColors.logoOrange),
                      const SizedBox(width: 4),
                      Text(
                        homiziText(context, '${mode.$2} ${mode.$3} min'),
                        style: const TextStyle(
                          color: HomiziColors.ink,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _map(LatLng mid, double roadKm) {
    final tiles = FlutterMap(
      options: MapOptions(
        initialCenter: mid,
        initialZoom: _zoom(roadKm),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.none,
        ),
        backgroundColor: HomiziColors.mist,
      ),
      children: [
        TileLayer(
          urlTemplate: AppConfig.defaultOsmTileUrl,
          userAgentPackageName: 'in.homizi.app',
        ),
        _RouteLayer(home: home, office: office),
        MarkerLayer(
          markers: [
            _pin(home, 'A', HomiziColors.logoOrange),
            _pin(office, 'B', HomiziColors.ink),
          ],
        ),
      ],
    );
    final key = mapsApiKey.trim();
    if (key.isEmpty) {
      return tiles;
    }
    final zoom = _zoom(roadKm);
    return LayoutBuilder(
      builder: (context, constraints) {
        final box = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 640,
          160,
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              _staticMap(key, mid, zoom),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 160,
              errorBuilder: (context, error, stackTrace) => tiles,
            ),
            HomiziAnimatedRoute(
              from: staticMapPoint(home, mid, zoom, box),
              to: staticMapPoint(office, mid, zoom, box),
            ),
          ],
        );
      },
    );
  }

  String _staticMap(String key, LatLng mid, double zoom) {
    // Centre and zoom are fixed so the drawn route lines up with the pins.
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?size=640x320&scale=2&maptype=roadmap'
        '&center=${mid.latitude},${mid.longitude}&zoom=${zoom.round()}'
        '&markers=color:0xF75620|label:A|${home.latitude},${home.longitude}'
        '&markers=color:0x172033|label:B|${office.latitude},${office.longitude}'
        '&key=$key';
  }

  Marker _pin(GeoFix point, String label, Color color) {
    return Marker(
      point: LatLng(point.latitude, point.longitude),
      width: 28,
      height: 28,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: HomiziColors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  double _zoom(double km) {
    if (km < 2) {
      return 14;
    }
    if (km < 8) {
      return 12;
    }
    if (km < 20) {
      return 11;
    }
    return 10;
  }
}

/// 0..1 place of [point] inside a [box] showing a 640x320 static map that is
/// centred on [mid] at [zoom] and cover-fitted.
Offset staticMapPoint(GeoFix point, LatLng mid, double zoom, Size box) {
  final z = zoom.roundToDouble();
  final centre = mercatorPixel(mid.latitude, mid.longitude, z);
  final pixel = mercatorPixel(point.latitude, point.longitude, z);
  final image = pixel - centre + const Offset(320, 160);
  final scale = box.width / box.height > 2 ? box.width / 640 : box.height / 320;
  final dx = (box.width - 640 * scale) / 2;
  final dy = (box.height - 320 * scale) / 2;
  return Offset(
    (image.dx * scale + dx) / box.width,
    (image.dy * scale + dy) / box.height,
  );
}

/// Draws the A to B route on the live tile map.
class _RouteLayer extends StatelessWidget {
  const _RouteLayer({required this.home, required this.office});

  final GeoFix home;
  final GeoFix office;

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final size = camera.nonRotatedSize;
    if (size.width <= 0 || size.height <= 0) {
      return const SizedBox.shrink();
    }
    Offset unit(GeoFix fix) {
      final at = camera.latLngToScreenOffset(
        LatLng(fix.latitude, fix.longitude),
      );
      return Offset(at.dx / size.width, at.dy / size.height);
    }

    return SizedBox.expand(
      child: HomiziAnimatedRoute(from: unit(home), to: unit(office)),
    );
  }
}
