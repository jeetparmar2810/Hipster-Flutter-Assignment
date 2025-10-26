import 'package:flutter/material.dart';

abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoReady extends VideoState {
  final Widget localVideoWidget;
  final Widget? remoteVideoWidget;
  final bool hasRemoteUser;
  final String? channelName;
  final bool isScreenSharing;

  VideoReady({
    required this.localVideoWidget,
    this.remoteVideoWidget,
    this.hasRemoteUser = false,
    this.channelName,
    this.isScreenSharing = false,
  });

  VideoReady copyWith({
    Widget? localVideoWidget,
    Widget? remoteVideoWidget,
    bool? hasRemoteUser,
    bool? isScreenSharing,
    String? channelName,
  }) {
    return VideoReady(
      localVideoWidget: localVideoWidget ?? this.localVideoWidget,
      remoteVideoWidget: remoteVideoWidget ?? this.remoteVideoWidget,
      hasRemoteUser: hasRemoteUser ?? this.hasRemoteUser,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
      channelName: channelName ?? this.channelName,
    );
  }
}

class VideoError extends VideoState {
  final String message;

  VideoError(this.message);
}
