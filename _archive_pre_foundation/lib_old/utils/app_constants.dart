// Global app constants
class app {
  // SpaceX API
  static const String spacexApiBaseUrl = 'https://api.spacexdata.com/v4';
  static const String spacexLaunchesEndpoint = 'launches';
  static const String rocketsEndpoint = 'rockets';
  static const String launches = '${spacexApiBaseUrl}/$spacexLaunchesEndpoint';
  static const String rockets = '${spacexApiBaseUrl}/$rocketsEndpoint';
  
  // NASA API  
  static const String nasaApiBaseUrl = 'https://api.nasa.gov';
  static const String nasaApoloJson = 'https://services.nasa.gov/openapihub/apollo-json-api/v1/apollo-json-api';
  static const String nasaApoloJsonProd = 'https://services.nasa.gov/openapihub/apollo-json-api/v1/apollo-json-api';
  
  // Launch manifest data
  static const String launchManifests = 'https://www.space-launch-report.net/launches/';
  
  // YouTube streaming
  static const String youtubeApiUrl = 'https://www.googleapis.com/youtube/v3';
  static const String searchApiKey = 'AIzaSyDHjJzZQ5Q7YQ6Q7YQ6Q7YQ6Q7YQ6Q7YQ6Q7'; // Placeholder
  
  // App settings
  static const int refreshInterval = 60;
  static const int notificationPermissionKey = 'rocker.notification';
}
