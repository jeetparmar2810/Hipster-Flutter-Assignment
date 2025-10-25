import 'package:flutter/material.dart';

abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoReady extends VideoState {
  final Widget localVideoWidget;
  final Widget? remoteVideoWidget;
  final bool hasRemoteUser;
  final String? channelName;

  VideoReady({
    required this.localVideoWidget,
    this.remoteVideoWidget,
    this.hasRemoteUser = false,
    this.channelName,
  });
}

class VideoError extends VideoState {
  final String message;
  VideoError(this.message);
}