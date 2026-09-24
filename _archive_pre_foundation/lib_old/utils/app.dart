// Global app constants - worldwide rocket launcher
class App {
  // SpaceX API
  static const String spacexApiBaseUrl = 'https://api.spacexdata.com/v4';
  
  // NASA API  
  static const String nasaApiBaseUrl = 'https://api.nasa.gov';
  
  // Launch manifest data  
  static const String launchManifests = 'https://www.space-launch-report.net/launches/';
  
  // YouTube streaming
  static const String youtubeSearchEndpoint = 'https://www.googleapis.com/youtube/v3/search';
  
  // App settings
  static const int refreshInterval = 60;
  static const int notificationPermissionKey = 'rocker.notification';
  
  // Mock data for demonstration (would normally use real APIs)
  static List<String> mockLaunchProviders = [
    'SpaceX', 'NASA', 'Rocket Lab', 'Blue Origin', 'JAXA', 'ESA', 'CNSA', 'ISRO', 'Roscosmos'
  ];
}
