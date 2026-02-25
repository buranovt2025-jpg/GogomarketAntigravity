import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong2.dart';
import 'package:core/core.dart';
import 'package:ui_kit/ui_kit.dart';

class MapScreen extends StatefulWidget {
  final String orderId;
  final String address;

  const MapScreen({
    super.key,
    required this.orderId,
    required this.address,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Координаты Ташкента по умолчанию
  static const _tashkent = LatLng(41.311081, 69.240562);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        title: Text('Карта доставки', style: AppTextStyles.headlineM),
        leading: const BackButton(color: AppColors.textPrimary),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: _tashkent,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.gogomarket.courier',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _tashkent,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Инфо-панель снизу
          Positioned(
            left: 16,
            right: 16,
            bottom: 30,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Заказ #${widget.orderId}', style: AppTextStyles.headlineS),
                  const SizedBox(height: 4),
                  Text(widget.address, style: AppTextStyles.bodyM),
                  const SizedBox(height: 16),
                  GogoButton(
                    label: 'Маршрут построен',
                    fullWidth: true,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
