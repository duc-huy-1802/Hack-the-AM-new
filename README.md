# XR Adaptive Fitness

An immersive fitness application for Apple Vision Pro that combines treadmill workouts with adaptive ambient environments and spatial audio. Users can exercise in multiple themed worlds while tracking their progress through an intensity-based system.

## Features

- **Multiple Immersive Environments**: Choose from three distinct environments—Forest, Beach, and City—each with unique visuals and soundscapes
- **Adaptive Audio System**: Spatial audio layers respond dynamically to your workout intensity (Slow, Medium, Fast)
- **Intensity Tracking**: Automatic speed-based intensity classification from treadmill data
- **Environment Unlocking**: Progressive unlock system—start with Forest, then unlock Beach (50m) and City (200m) as you accumulate distance
- **Session Management**: 
  - Start and stop fitness sessions with visual feedback
  - Track session metrics (elapsed time, distance)
  - Cumulative distance tracking across sessions
- **Collapsible Control Panel**: Minimizable HUD that expands on demand for unobstructed immersive experience
- **Real-time Feedback**: Heart rate, speed, and intensity indicators during active sessions

## Project Architecture

```
XRAdaptiveFitness/
├── App/
│   └── XRAdaptiveFitnessApp.swift       # Main app entry point with Scene setup
├── Views/
│   ├── ContentView.swift                # 2D control panel window
│   ├── ImmersiveView.swift              # Full XR immersive forest scene
│   ├── SessionView.swift                # Active session controls and metrics
│   └── EnvironmentPickerView.swift      # Environment selection UI
├── ViewModels/
│   └── FitnessSessionViewModel.swift    # Session state and business logic
├── Models/
│   ├── FitnessEnvironment.swift         # Environment definitions (Forest, Beach, City)
│   └── IntensityLevel.swift             # Intensity classification system
├── Audio/
│   ├── SpatialAudioManager.swift        # Spatial audio playback and management
│   └── forest_sound.aiff                # Audio asset
└── Assets.xcassets/                     # App icons and color assets
```

## Key Components

### Models

- **FitnessEnvironment**: Enum defining three workout environments
  - Forest (unlocked by default)
  - Beach (unlocked at 50m)
  - City (unlocked at 200m)
  - Each includes icons, descriptions, and environment-specific audio files

- **IntensityLevel**: Enum mapping treadmill speed to intensity tiers
  - Slow (0–4 km/h)
  - Medium (5–9 km/h)
  - Fast (10–15 km/h)
  - Controls audio volume and visual effects

### ViewModels

- **FitnessSessionViewModel**: ObservableObject managing:
  - Selected environment and current speed
  - Session state (active/inactive, immersive space status)
  - Time and distance tracking (session and cumulative)
  - Intensity-based audio updates
  - Environment unlock logic

### Views

- **ContentView**: 2D control panel with navigation, environment picker, and session controls
- **ImmersiveView**: Full-screen immersive forest experience
- **SessionView**: Active workout metrics and stop controls
- **EnvironmentPickerView**: Environment selection with lock status

### Audio

- **SpatialAudioManager**: Manages layered spatial audio playback
  - Base ambient layers per environment
  - Intensity-responsive audio
  - Volume scaling based on workout intensity

## Requirements

- Xcode 15.0+
- iOS 18.0+
- Apple Vision Pro (or visionOS simulator)
- Swift 5.9+

## Getting Started

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd XRAdaptiveFitness
   ```

2. Open the project in Xcode:
   ```bash
   open XRAdaptiveFitness.xcodeproj
   ```

3. Select the appropriate target (Apple Vision Pro or simulator)

4. Build and run:
   ```bash
   Cmd + R
   ```

### Running the App

1. **Start a Session**: Tap "Start Walking" to enter the immersive environment
2. **Run on Treadmill**: Your speed is automatically detected and classified as Slow/Medium/Fast
3. **Monitor Progress**: View elapsed time, distance, and current intensity
4. **Pause/Stop**: Use the minimized HUD to access session controls
5. **Switch Environments**: Return to the control panel and select a new environment (if unlocked)

## Audio System

Each environment features layered spatial audio:

- **Forest**: Birds, wind, rustling leaves, intensity audio
- **Beach**: Waves, wind, seagulls, intensity audio
- **City**: Traffic, crowd, ambient sounds, intensity audio

Audio volume dynamically adjusts based on current intensity:
- Slow: 30% volume
- Medium: 60% volume
- Fast: 100% volume

## Data Tracking

The app tracks:
- **Session Metrics**: Time elapsed, distance covered per session
- **Cumulative Statistics**: Total distance across all sessions
- **Environment Progress**: Which environments are unlocked based on distance milestones

## Development

### State Management

The app uses SwiftUI's `@StateObject`, `@Environment`, and `@EnvironmentObject` for state management. The `FitnessSessionViewModel` is shared across all views through the environment.

### Immersive Spaces

The app implements visionOS immersive spaces:
- **2D Control Panel**: Standard WindowGroup for UI controls
- **Full XR Scene**: Dedicated `ImmersiveSpace` with `.full` immersion style

### Audio Implementation

The `SpatialAudioManager` leverages AVFoundation for spatial audio playback, with environment-specific audio files and intensity-based volume scaling.

## Future Enhancements

- Customizable pet/avatar for the immersive environment
- Leaderboards and social sharing
- Integration with HealthKit for real heart rate data
- Additional environments
- Workout achievements and badges
- Multiplayer immersive sessions
- Saved workout history and statistics

## License

MIT License © 2026 Duc Huy Nguyen

See [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues, feature requests, or questions, please open an issue in the repository.
