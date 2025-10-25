import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/agora_service.dart';
import '../../utils/logger.dart';
import 'video_event.dart';
import 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final AgoraService _agoraService;

  VideoBloc(this._agoraService) : super(VideoInitial()) {
    on<InitVideo>(_onInitVideo);
    on<JoinChannel>(_onJoinChannel);
    on<RemoteUserJoined>(_onRemoteUserJoined);
    on<RemoteUserLeft>(_onRemoteUserLeft);
    on<ToggleAudioEvent>(_onToggleAudio);
    on<ToggleVideoEvent>(_onToggleVideo);
    on<LeaveChannel>(_onLeaveChannel);
    on<UpdateVideoState>(_onUpdateVideoState);
    on<VideoErrorEvent>(_onVideoError);

    on<StartScreenShare>(_onStartScreenShare);
    on<StopScreenShare>(_onStopScreenShare);
    on<ToggleScreenShare>(_onToggleScreenShare);
    on<ScreenShareStateChanged>(_onScreenShareStateChanged);

    // Setup callbacks from AgoraService
    _agoraService.onUserJoined = (uid) {
      Logger.i('Bloc: Remote user joined - $uid');
      add(RemoteUserJoined(uid));
    };

    _agoraService.onUserLeft = (uid) {
      Logger.i('Bloc: Remote user left - $uid');
      add(RemoteUserLeft(uid));
    };

    _agoraService.onLocalUserJoined = () {
      Logger.i('Bloc: Local user joined successfully');
      add(UpdateVideoState());
    };

    _agoraService.onError = (error) {
      Logger.e('Bloc: Error occurred', error);
      add(VideoErrorEvent(error));
    };

    _agoraService.onScreenShareStateChanged = (isSharing) {
      Logger.i('Bloc: Screen share state changed: $isSharing');
      add(ScreenShareStateChanged(isSharing));
    };
  }

  Future<void> _onInitVideo(InitVideo event, Emitter<VideoState> emit) async {
    Logger.i('Bloc: Initializing video...');
    emit(VideoLoading());
    try {
      await _agoraService.initialize();
      emit(
        VideoReady(
          localVideoWidget: _agoraService.getLocalVideoWidget(),
          hasRemoteUser: false,
        ),
      );
      Logger.i('Bloc: Video initialized successfully');
    } catch (e, stack) {
      Logger.e('Bloc: Initialization failed', e, stack);
      emit(VideoError('Failed to initialize: $e'));
    }
  }

  Future<void> _onJoinChannel(
    JoinChannel event,
    Emitter<VideoState> emit,
  ) async {
    Logger.i('Bloc: Joining channel ${event.channelName}...');
    emit(VideoLoading());
    try {
      await _agoraService.joinChannel(event.channelName);
      _emitReadyState(emit);
      Logger.i('Bloc: Successfully joined channel');
    } catch (e, stack) {
      Logger.e('Bloc: Failed to join channel', e, stack);
      emit(VideoError('Failed to join channel: $e'));
    }
  }

  void _onRemoteUserJoined(RemoteUserJoined event, Emitter<VideoState> emit) {
    Logger.i('Bloc: Processing remote user joined event');
    _emitReadyState(emit);
  }

  void _onRemoteUserLeft(RemoteUserLeft event, Emitter<VideoState> emit) {
    Logger.i('Bloc: Processing remote user left event');
    _emitReadyState(emit);
  }

  Future<void> _onToggleAudio(
    ToggleAudioEvent event,
    Emitter<VideoState> emit,
  ) async {
    Logger.i('Bloc: Toggling audio - ${event.enabled}');
    await _agoraService.toggleAudio(event.enabled);
  }

  Future<void> _onToggleVideo(
    ToggleVideoEvent event,
    Emitter<VideoState> emit,
  ) async {
    Logger.i('Bloc: Toggling video - ${event.enabled}');
    await _agoraService.toggleVideo(event.enabled);
  }

  Future<void> _onLeaveChannel(
    LeaveChannel event,
    Emitter<VideoState> emit,
  ) async {
    Logger.i('Bloc: Leaving channel...');
    await _agoraService.leaveChannel();
    emit(VideoInitial());
  }

  void _onUpdateVideoState(UpdateVideoState event, Emitter<VideoState> emit) {
    Logger.i('Bloc: Updating video state');
    _emitReadyState(emit);
  }

  void _onVideoError(VideoErrorEvent event, Emitter<VideoState> emit) {
    Logger.e('Bloc: Handling error event', event.error);
    emit(VideoError(event.error));
  }

  Future<void> _onStartScreenShare(
      StartScreenShare event,
      Emitter<VideoState> emit,
      ) async {
    try {
      Logger.i('Bloc: Starting screen share...');
      await _agoraService.startScreenShare();
      _emitReadyState(emit);
    } catch (e, stack) {
      Logger.e('Bloc: Start screen share error', e, stack);
      emit(VideoError('Failed to start screen share: $e'));
    }
  }

  Future<void> _onStopScreenShare(
      StopScreenShare event,
      Emitter<VideoState> emit,
      ) async {
    try {
      Logger.i('Bloc: Stopping screen share...');
      await _agoraService.stopScreenShare();
      _emitReadyState(emit);
    } catch (e, stack) {
      Logger.e('Bloc: Stop screen share error', e, stack);
    }
  }

  Future<void> _onToggleScreenShare(
      ToggleScreenShare event,
      Emitter<VideoState> emit,
      ) async {
    try {
      Logger.i('Bloc: Toggling screen share...');
      await _agoraService.toggleScreenShare();
      _emitReadyState(emit);
    } catch (e, stack) {
      Logger.e('Bloc: Toggle screen share error', e, stack);
      emit(VideoError('Failed to toggle screen share: $e'));
    }
  }

  void _onScreenShareStateChanged(
      ScreenShareStateChanged event,
      Emitter<VideoState> emit,
      ) {
    Logger.i('Bloc: Processing screen share state change');
    _emitReadyState(emit);
  }

  // SINGLE _emitReadyState method - with emit parameter
  void _emitReadyState(Emitter<VideoState> emit) {
    emit(
      VideoReady(
        localVideoWidget: _agoraService.getLocalVideoWidget(),
        remoteVideoWidget: _agoraService.remoteUid != null
            ? _agoraService.getRemoteVideoWidget()
            : null,
        hasRemoteUser: _agoraService.remoteUid != null,
        channelName: _agoraService.currentChannel,
        isScreenSharing: _agoraService.isScreenSharing,
      ),
    );
  }


  @override
  Future<void> close() {
    Logger.i('Bloc: Closing and disposing service');
    _agoraService.dispose();
    return super.close();
  }
}
