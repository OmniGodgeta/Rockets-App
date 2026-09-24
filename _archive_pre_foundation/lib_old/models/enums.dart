enum LaunchStatus {
  scheduled,  // Planned launch
  prelaunch,  // T-minus (ready for launch)
  launch,     // Currently launching
  landed,     // Landing complete
  success,    // Mission success
  failure,    // Mission failure
  partial,    // Partial success
  terminated, // Mission terminated
  noattempt,  // Launch not attempted
}

enum LaunchOutcome {
  mission,     // Mission success (primary objective)
  payload,     // Payload success
  flight,      // Hardware flight success
  landing,     // Landing success
}

enum LandingType {
  drone,      // Drone ship landing
  ship,       // Land on drone ship
  water,      // Splash down (splashdown)
  land,       // Land launch pad
  unknown,    // Landing method unknown
}