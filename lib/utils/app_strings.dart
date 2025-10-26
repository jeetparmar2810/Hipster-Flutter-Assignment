class AppStrings {
  static const String appName = 'Video Call App';
  static const String appLogoTag = 'Tag';
  static const String appLogo = "assets/app_icon.png";

  static const String welcomeBack = "Welcome Back";
  static const String signInSubtitle = "Sign in to continue your journey";

  static const String emailLabel = "Email";
  static const String passwordLabel = "Password";
  static const String channelNameArg = 'channelName';

  static const String userNotFound = 'Users not found.';
  static const String emailRequired = "Please enter your email";
  static const String emailInvalid = "Enter a valid email";
  static const String passwordRequired = "Please enter your password";
  static const String loginButton = "LOGIN";
  static const String viewUsers = "View Users";
  static const String view = "View";
  static const String testUser = "Test User";
  static const String loginTitle = 'Welcome Back';
  static const String loginSubtitle = 'Sign in to continue';
  static const String emailHint = 'Enter your email';
  static const String passwordHint = 'Enter your password';
  static const String noAccount = "Don't have an account?";
  static const String signUp = 'Sign Up';
  static const String forgotPassword = 'Forgot Password?';

  // User List Screen
  static const String usersTitle = 'Users';
  static const String onlineUsers = 'Online Users';
  static const String availableUsers = 'Available Users';
  static const String noUsersFound = 'No users found';
  static const String searchUsers = 'Search users...';
  static const String logout = 'Logout';
  static const String callUser = 'Call';
  static const String videoCall = 'Video Call';
  static const String audioCall = 'Audio Call';

  // Video Call Screen
  static const String videoCallTitle = 'Video Call';
  static const String joinChannel = 'Join Channel';
  static const String enterChannelName = 'Enter Channel Name to Join';
  static const String channelNameHint = 'e.g., room123';
  static const String channelNameLabel = 'Channel Name';
  static const String waitingForOthers = 'Waiting for others to join...';
  static const String connectedTo = 'Connected to: ';
  static const String readyToStart = 'Ready to start a call';
  static const String sameChannelNote =
      'Both users must use the same channel name';

  // Call Controls
  static const String mute = 'Mute';
  static const String unmute = 'Unmute';
  static const String cameraOn = 'Camera On';
  static const String cameraOff = 'Camera Off';
  static const String switchCamera = 'Switch Camera';
  static const String endCall = 'End Call';
  static const String cameraSwitched = 'Camera switched';

  // Error Messages
  static const String errorOccurred = 'An error occurred';
  static const String initializationFailed = 'Failed to initialize';
  static const String joinChannelFailed = 'Failed to join channel';
  static const String enterChannelNameError = 'Please enter a channel name';
  static const String switchCameraError = 'Switch camera error';
  static const String permissionDenied = 'Permission denied';
  static const String noInternet = 'Internet connection is required for all video calls.';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String channelJoined = 'Channel joined successfully';
  static const String callEnded = 'Call ended';

  // Loading Messages
  static const String loading = 'Loading...';
  static const String joiningChannel = 'Joining channel...';
  static const String initializing = 'Initializing...';
  static const String connecting = 'Connecting...';

  // Common
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String ok = 'OK';
  static const String close = 'Close';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String yes = 'Yes';
  static const String no = 'No';

  static const String invalidCredentials = 'Invalid credentials';
  static const String loginFailed = 'Login failed';
  static const String viewUsersButton = 'View Users';

  static const String enterEmail = 'Enter email';
  static const String enterValidEmail = 'Enter valid email';
  static const String enterPassword = 'Enter password';

  static const String testEmail = 'test@test.com';
  static const String testPassword = '123456';

  static const String userId = 'User ID';
  static const String email = 'Email';
  static const String company = 'Company';
  static const String companyName = 'Reqres';

  static const int loginDelayMs = 700;

  // Route Names
  static const String loginRoute = '/login';
  static const String usersRoute = '/users';
  static const String videoCallRoute = '/video-call';

  static const String videoInitFailed = 'Initialization failed';
  static const String imageIcon = 'assets/app_icon.png';

  static const String noNetwork = "No network and no cached data found";

  static String videoInitFailedWithError(dynamic error) =>
      '$videoInitFailed: $error';

  static const pleaseEnterChannel = 'Please enter a channel';
  static const joinPrompt = 'Join a Channel';
  static const channelHint = 'Enter channel name';
  static const joinButton = 'Join';
  static const bothUsersHint = 'Both users must join the same channel to start a call';
  static const waitingMessage = 'Waiting for other user...';
  static const readyMessage = 'Ready to start call';
  static const errorTitle = 'Oops! Something went wrong';
  static const retryButton = 'Retry';
  static const endCallTitle = 'End Call?';
  static const endCallContent = 'Are you sure you want to end this call?';
  static const cancelButton = 'Cancel';
  static const endCallButton = 'End Call';
  static const screenSharingStarted = 'Screen sharing started';
  static const screenSharingStopped = 'Screen sharing stopped';
  static const callEndedByOther = 'Call ended by other participant';
  static const sharing = 'Sharing';
  static const screenSharingActive = 'Screen sharing active';
  static const channelPrefix = 'Channel: ';
  static const testNotification = 'Test Notification: ';
  static const incomingCallFrom = 'Incoming call from: ';
  static const String inComingCall = 'Incoming Video Call ';

  static const String fileExtension = ".env";
}
