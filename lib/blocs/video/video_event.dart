abstract class VideoEvent {}

class InitVideo extends VideoEvent {}

class ToggleAudioEvent extends VideoEvent {
  final bool enabled;

  ToggleAudioEvent(this.enabled);
}

class ToggleVideoEvent extends VideoEvent {
  final bool enabled;

  ToggleVideoEvent(this.enabled);
}

class JoinChannel extends VideoEvent {
  final String channelName;
  JoinChannel(this.channelName);
}

class RemoteUserJoined extends VideoEvent {
  final int uid;
  RemoteUserJoined(this.uid);
}

class RemoteUserLeft extends VideoEvent {
  final int uid;
  RemoteUserLeft(this.uid);
}

class LeaveChannel extends VideoEvent {}

class UpdateVideoState extends VideoEvent {}

class VideoErrorEvent extends VideoEvent {
  final String error;
  VideoErrorEvent(this.error);
}

class StartScreenShare extends VideoEvent {}

class StopScreenShare extends VideoEvent {}

class ToggleScreenShare extends VideoEvent {}

class ScreenShareStateChanged extends VideoEvent {
  final bool isSharing;
  ScreenShareStateChanged(this.isSharing);
}