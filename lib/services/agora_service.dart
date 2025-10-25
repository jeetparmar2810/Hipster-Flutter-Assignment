import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hipster_inc_assignment/utils/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static final String appId = dotenv.env['AGORA_APP_ID'] ?? '';

  RtcEngine? _engine;
  int? remoteUid;
  bool isJoined = false;
  String? currentChannel;

  Function(int uid)? onUserJoined;
  Function(int uid)? onUserLeft;
  Function()? onLocalUserJoined;
  Function(String error)? onError;
  Function()? onCallEnded;

  Future<void> initialize() async {
    Logger.i('Initializing Agora...');

    try {
      final statuses = await [
        Permission.microphone,
        Permission.camera,
      ].request();

      if (statuses[Permission.microphone] != PermissionStatus.granted ||
          statuses[Permission.camera] != PermissionStatus.granted) {
        throw Exception('Microphone or camera permission denied');
      }

      _engine = createAgoraRtcEngine();

      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      Logger.i('Agora engine created');

      _registerEventHandlers();

      await _engine!.enableVideo();
      await _engine!.startPreview();

      Logger.i('Video enabled and preview started');
    } catch (e) {
      Logger.i('Failed to initialize Agora: $e');
      onError?.call('Initialization failed: $e');
      rethrow;
    }
  }

  void _registerEventHandlers() {
    _engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          Logger.i('Local user ${connection.localUid} joined channel');
          isJoined = true;
          onLocalUserJoined?.call();
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          Logger.i('Remote user $remoteUid joined');
          this.remoteUid = remoteUid;
          onUserJoined?.call(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          Logger.i('Remote user $remoteUid left (reason: $reason)');

          if (this.remoteUid == remoteUid) {
            this.remoteUid = null;
            onUserLeft?.call(remoteUid);

            if (reason == UserOfflineReasonType.userOfflineQuit ||
                reason == UserOfflineReasonType.userOfflineDropped) {
              Logger.i('Call ended because remote user left');
              onCallEnded?.call();
            }
          }
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          Logger.i('Left channel');
          isJoined = false;
          remoteUid = null;
          currentChannel = null;

          onCallEnded?.call();
        },
        onError: (ErrorCodeType err, String msg) {
          Logger.i('Agora Error: $err - $msg');
          onError?.call('Error $err: $msg');
        },
        onConnectionStateChanged: (RtcConnection connection,
            ConnectionStateType state, ConnectionChangedReasonType reason) {
          Logger.i('Connection changed: $state (reason: $reason)');

          if (state == ConnectionStateType.connectionStateFailed ||
              state == ConnectionStateType.connectionStateDisconnected) {
            Logger.i('Connection lost, ending call');
            onCallEnded?.call();
          }
        },
        onConnectionLost: (RtcConnection connection) {
          Logger.i('Connection lost completely');
          onCallEnded?.call();
        },
      ),
    );
  }

  Future<void> joinChannel(String channelName) async {
    if (_engine == null) {
      throw Exception('Engine not initialized. Call initialize() first');
    }

    try {
      Logger.i('Joining channel: $channelName');
      currentChannel = channelName;

      await _engine!.joinChannel(
        token: '',
        channelId: channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
      Logger.i('Join channel request sent');
    } catch (e) {
      Logger.i('Failed to join channel: $e');
      onError?.call('Join channel failed: $e');
      rethrow;
    }
  }

  Future<void> leaveChannel() async {
    Logger.i('Leaving channel...');

    if (!isJoined) {
      Logger.i('Not in a channel, skipping leave');
      return;
    }
    try {
      await _engine?.stopPreview();
      await _engine?.leaveChannel();
      Logger.i('Successfully left channel');
    } catch (e) {
      Logger.i('Error while leaving channel: $e');
    } finally {
      isJoined = false;
      remoteUid = null;
      currentChannel = null;
    }
  }

  Future<void> toggleAudio(bool enabled) async {
    await _engine?.muteLocalAudioStream(!enabled);
    Logger.i('Audio ${enabled ? "enabled" : "muted"}');
  }

  Future<void> toggleVideo(bool enabled) async {
    await _engine?.muteLocalVideoStream(!enabled);
    Logger.i('Video ${enabled ? "enabled" : "disabled"}');
  }

  Future<void> switchCamera() async {
    await _engine?.switchCamera();
    Logger.i('Camera switched');
  }

  Widget getLocalVideoWidget() {
    if (_engine == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget getRemoteVideoWidget() {
    if (_engine == null || remoteUid == null || currentChannel == null) {
      return const Center(
        child: Text(
          'Waiting for remote user...',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: remoteUid),
        connection: RtcConnection(channelId: currentChannel!),
      ),
    );
  }

  Future<void> dispose() async {
    Logger.i('Disposing Agora service...');
    try {
      await _engine?.stopPreview();
      if (isJoined) {
        await _engine?.leaveChannel();
      }
      await _engine?.release();
      Logger.i('Agora service disposed successfully');
    } catch (e) {
      Logger.i('Error during dispose: $e');
    } finally {
      _engine = null;
      isJoined = false;
      remoteUid = null;
      currentChannel = null;
    }
  }
}