import 'dart:html' as html;

void redirectToDesktopApp() {
  var os = detectWebOS();

  print("user is on $os");

  // html.window.alert("Please use the $os desktop app.");
  // if (os == 'Windows')
  // {
  // html.window.location.href = 'https://drive.usercontent.google.com/download?id=13VeRRJY5gZ6dJSoExPfl0TBwhYQDYqIw&export=download&authuser=0';
  //
  // } if (os=='macOS') {
  //   html.window.location.href =
  //   'https://drive.google.com/file/d/1nx5_hwZKgCh1lruZigOdyqJEW9_FmB6m/view?usp=sharing';
  // }

  // const timeout = Duration(seconds: 2);
  // const fallbackUrl = 'https://drive.google.com/file/d/1nx5_hwZKgCh1lruZigOdyqJEW9_FmB6m/view?usp=sharing';
  //
  // final iframe = html.IFrameElement()
  //   ..style.display = 'none'
  //   ..src = 'cinteraction://open?route=/home/meeting/1223';
  //
  // html.document.body!.append(iframe);
  //
  // Future.delayed(timeout, () {
  //   iframe.remove();
  //   html.window.location.href = fallbackUrl;
  // });

}

void startMeetOnDesktop(int roomId) {
  var os = detectWebOS();
   html.window.alert("Please use the $os desktop app.");
  // if (os == 'Windows')
  // {
  // html.window.location.href = 'https://drive.usercontent.google.com/download?id=13VeRRJY5gZ6dJSoExPfl0TBwhYQDYqIw&export=download&authuser=0';
  //
  // } if (os=='macOS') {
  //   html.window.location.href =
  //   'https://drive.google.com/file/d/1nx5_hwZKgCh1lruZigOdyqJEW9_FmB6m/view?usp=sharing';
  // }

  const timeout = Duration(seconds: 2);
  const fallbackUrl = 'https://drive.google.com/file/d/1nx5_hwZKgCh1lruZigOdyqJEW9_FmB6m/view?usp=sharing';

  final iframe = html.IFrameElement()
    ..style.display = 'none'
    ..src = 'cinteraction://open?route=/home/meeting/1223';

  html.document.body!.append(iframe);

  Future.delayed(timeout, () {
    iframe.remove();
    html.window.location.href = fallbackUrl;
  });
}


String detectWebOS() {
  final ua = html.window.navigator.userAgent.toLowerCase();

  if (ua.contains('windows')) return 'Windows';
  if (ua.contains('mac os')) return 'macOS';
  if (ua.contains('linux')) return 'Linux';
  if (ua.contains('android')) return 'Android';
  if (ua.contains('iphone') || ua.contains('ipad')) return 'iOS';
  return 'Unknown';
}
