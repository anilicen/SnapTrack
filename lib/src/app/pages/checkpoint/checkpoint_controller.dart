import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'package:st/src/data/helpers/geolocation_helper.dart';
import 'package:st/src/domain/entities/checkpoint.dart';
import 'package:st/src/domain/repositories/route_repository.dart';
import 'package:st/src/domain/types/geolocation.dart';

class CheckpointController extends Controller {
  CheckpointController(RouteRepository routeRepository, String routeId, int order)
      : _routeRepository = routeRepository,
        routeId = routeId,
        order = order;

  RouteRepository _routeRepository;
  String routeId;

  Checkpoint? checkpoint;
  String? imagePath;
  String? checkpointName;
  Geolocation? location;
  int? order;
  bool addingCheckpoint = false;

  @override
  void initListeners() {}

  void setName(String name) {
    checkpointName = name;
  }

  void setImagePath(String path) {
    imagePath = path;
    refreshUI();
  }

  void addCheckpoint() async {
    try {
      addingCheckpoint = true;
      refreshUI();

      location = await GeolocationHelper.getCurrentGeolocation();

      String? downloadUrl = await _routeRepository.uploadCheckpointPhoto(routeId, imagePath!);
      Checkpoint checkpoint = Checkpoint('', checkpointName!, location!, downloadUrl!, order!);

      await _routeRepository.addCheckpoint(routeId, checkpoint);
    } finally {
      addingCheckpoint = false;
      refreshUI();
      Navigator.pop(getContext());
    }
  }
}
