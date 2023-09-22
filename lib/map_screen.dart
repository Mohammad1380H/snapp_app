import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:snapp_app/gen/assets.gen.dart';
import 'package:snapp_app/res/dimens.dart';
import 'package:snapp_app/res/text_style.dart';
import 'package:snapp_app/widget/my_back_btn.dart';

class CurrentWidgetState {
  CurrentWidgetState._();
  static const selectOriginState = 0;
  static const selectDesinationState = 1;
  static const requestDriverState = 2;
}

class MappScreen extends StatefulWidget {
  const MappScreen({super.key});

  @override
  State<MappScreen> createState() => _MappScreenState();
}

class _MappScreenState extends State<MappScreen> {
  List currentWidgetStack = [CurrentWidgetState.selectOriginState];
  String distance = '...در حال محاسبه';
  String originAddress = 'در حال محاسبه مبدأ';
  String destinationAddress = 'در حال محاسبه مقصد';
  List<GeoPoint> geoPoint = [];
  bool initTime = true;
  Widget markIcon = SvgPicture.asset(
    Assets.icons.origin,
    height: Dimens.larg * 4,
    width: Dimens.small * 5,
  );

  Widget originMarker = SvgPicture.asset(
    Assets.icons.origin,
    height: Dimens.larg * 4,
    width: Dimens.small * 5,
  );
  Widget destinationMarker = SvgPicture.asset(
    Assets.icons.destination,
    height: Dimens.larg * 4,
    width: Dimens.small * 5,
  );

  MapController mapController = MapController(
      initMapWithUserPosition: false,
      initPosition:
          GeoPoint(latitude: 35.7367516373, longitude: 51.2911096718));
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Stack(
        children: [
          SizedBox.expand(
            child: OSMFlutter(
              controller: mapController,
              initZoom: 15,
              trackMyPosition: false,
              mapIsLoading: const SpinKitPouringHourGlass(color: Colors.green),
              isPicker: true,
              minZoomLevel: 8,
              maxZoomLevel: 18,
              showDefaultInfoWindow: true,
              userLocationMarker: UserLocationMaker(
                personMarker: MarkerIcon(
                  iconWidget: SvgPicture.asset(
                    Assets.icons.origin,
                    color: Colors.blue,
                    height: 100,
                    width: 48,
                  ),
                ),
                directionArrowMarker: const MarkerIcon(
                  icon: Icon(
                    Icons.circle_sharp,
                    size: 48,
                    color: Colors.blue,
                  ),
                ),
              ),
              markerOption: MarkerOption(
                  advancedPickerMarker: MarkerIcon(
                iconWidget: markIcon,
              )),
            ),
          ),
          currentWidget(),
          MyBackBtn(
            onPressed: () {
              switch (currentWidgetStack.last) {
                case CurrentWidgetState.selectOriginState:
                  exit(0);
                case CurrentWidgetState.selectDesinationState:
                  mapController.removeMarker(geoPoint.first);
                  geoPoint.removeLast();
                  markIcon = originMarker;
                  break;
                case CurrentWidgetState.requestDriverState:
                  mapController.advancedPositionPicker();
                  mapController.removeMarker(geoPoint.last);
                  geoPoint.removeLast();
                  markIcon = destinationMarker;
                  break;
                default:
              }
              setState(() {
                currentWidgetStack.removeLast();
              });
            },
          ),
        ],
      )),
    );
  }

  Widget currentWidget() {
    Widget widget = originState();

    switch (currentWidgetStack.last) {
      case CurrentWidgetState.selectOriginState:
        widget = originState();

        break;
      case CurrentWidgetState.selectDesinationState:
        widget = destinationState();
        break;
      case CurrentWidgetState.requestDriverState:
        widget = requestState();
        break;
      default:
      //
    }
    return widget;
  }

  Widget originState() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Padding(
          padding: const EdgeInsets.all(Dimens.larg),
          child: ElevatedButton(
            onPressed: () async {
              geoPoint.add(await mapController
                  .getCurrentPositionAdvancedPositionPicker());
              //change icon marker
              markIcon = SvgPicture.asset(
                Assets.icons.destination,
                height: 100,
                width: 48,
              );

              setState(() {
                currentWidgetStack
                    .add(CurrentWidgetState.selectDesinationState);
              });
              mapController.init();
            },
            child: Text(
              'انتخاب مبدأ',
              style: MyTextStyles.button,
            ),
          ),
        ));
  }

  Widget destinationState() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Padding(
          padding: const EdgeInsets.all(Dimens.larg),
          child: ElevatedButton(
            onPressed: () async {
              setGeoPoints();

              mapController.cancelAdvancedPositionPicker();

              await mapController.addMarker(geoPoint.first,
                  markerIcon: MarkerIcon(
                    iconWidget: originMarker,
                  ));
              await mapController.addMarker(geoPoint.last,
                  markerIcon: MarkerIcon(
                    iconWidget: destinationMarker,
                  ));

              setState(() {
                currentWidgetStack.add(CurrentWidgetState.requestDriverState);
              });

              await distance2point(geoPoint.first, geoPoint.last).then((value) {
                setState(() {
                  if (value < 1000) {
                    distance = 'فاصله مبدأ تا مقصد ${value.toInt()} متر است';
                  } else {
                    distance =
                        'فاصله مبدأ تا مقصد ${value ~/ 1000} کیلومتر است';
                  }
                });
              });
              getAddress();
            },
            child: Text(
              'انتخاب مقصد',
              style: MyTextStyles.button,
            ),
          ),
        ));
  }

  Widget requestState() {
    mapController.zoomOut();
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Padding(
          padding: const EdgeInsets.all(Dimens.larg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: Dimens.larg * 2,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimens.medium)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      distance,
                      style: MyTextStyles.textWidget,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      width: Dimens.small,
                    ),
                    const Icon(
                      Icons.route,
                      color: Colors.green,
                    ),
                    const SizedBox(
                      width: Dimens.small,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: Dimens.small,
              ),
              Container(
                height: Dimens.larg * 2,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimens.medium)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'آدرس مبدأ: $originAddress',
                      style: MyTextStyles.textWidget,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      width: Dimens.small,
                    ),
                    const Icon(
                      Icons.location_searching_outlined,
                      color: Colors.green,
                    ),
                    const SizedBox(
                      width: Dimens.small,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: Dimens.small,
              ),
              Container(
                height: Dimens.larg * 2,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Dimens.medium)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'آدرس مقصد : $destinationAddress',
                      textAlign: TextAlign.center,
                      style: MyTextStyles.textWidget,
                    ),
                    const SizedBox(
                      width: Dimens.small,
                    ),
                    const Icon(
                      Icons.location_on,
                      color: Colors.green,
                    ),
                    const SizedBox(
                      width: Dimens.small,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: Dimens.small,
              ),
              //elevatedBtn
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    'درخواست راننده',
                    style: MyTextStyles.button,
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> setGeoPoints() async {
    GeoPoint originGeoPoint =
        await mapController.getCurrentPositionAdvancedPositionPicker();
    geoPoint.add(originGeoPoint);
    log('done su');
  }

  getAddress() async {
    try {
      await placemarkFromCoordinates(
              geoPoint.first.latitude, geoPoint.first.longitude,
              localeIdentifier: "fa")
          .then((List<Placemark> value) {
        setState(() {
          originAddress =
              "${value.first.locality} ${value.first.subLocality} ${value.first.thoroughfare} ${value[2].name}";
          log('$originAddress---------------');
        });
      });
      await placemarkFromCoordinates(
              geoPoint.last.latitude, geoPoint.last.longitude,
              localeIdentifier: "fa")
          .then((List<Placemark> value) {
        setState(() {
          destinationAddress =
              "${value.first.locality} ${value.first.subLocality} ${value.first.thoroughfare} ${value[2].name}";
        });
      });
    } catch (error) {
      originAddress = 'آدرس یافت نشد';
      destinationAddress = 'آدرس یافت نشد';
    }
  }
}
