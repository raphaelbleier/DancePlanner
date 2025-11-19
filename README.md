# DancePlanner

A powerful iOS/iPadOS application for choreographers to plan, visualize, and document dance formations and movements. DancePlanner provides an intuitive interface for creating formations, tracking dancer positions over time, and exporting choreography documentation.

## Features

### Core Functionality
- **Visual Formation Planning**: Create and arrange dancers on a virtual stage using 2D and 3D views
- **Timeline Management**: Track dancer positions and formations throughout your choreography
- **Audio Integration**: Import music tracks and sync formations to specific timestamps
- **Multiple View Modes**: Switch between 2D Stage, 3D Stage, Dancers, Groups, and Costumes views
- **Stage Configuration**: Customize stage dimensions and shapes (rectangle, circle, oval)

### Advanced Features
- **Dancer Management**: 
  - Create and organize dancers with custom colors and heights
  - Group dancers for easier formation management
  - Track costume assignments per formation
- **Formation Timeline**: 
  - Add formations at specific timestamps
  - Visualize dancer movements with path trails
  - Set hold durations for formations
- **Drawing Tools**: PencilKit integration for sketching movement paths and notes
- **Export Options**: 
  - Generate PDF documentation of all formations
  - Screen recording capability for video documentation
  - Share exports directly from the app

### Data Persistence
- Built with SwiftData for reliable local storage
- Projects automatically saved with all formations, dancers, and configurations
- No cloud dependency - all data stored on device

## Requirements

- **Runtime**: iOS 17.0+ / iPadOS 17.0+
- **Development**: 
  - Xcode 15.0+
  - Swift 5.9+
  - macOS 13.0+ (for building with Xcode)

## Architecture

DancePlanner follows a clean MVVM architecture with SwiftUI:

```
DancePlanner/
├── Models/           # SwiftData models for Projects, Dancers, Formations, etc.
├── Views/            # SwiftUI views for UI components
├── ViewModels/       # Business logic and state management
└── Utils/            # Helper utilities (PDF generation, screen recording)
```

### Key Models
- **Project**: Container for a complete choreography with dancers, formations, and settings
- **Dancer**: Represents a dancer with properties like name, color, and height
- **Formation**: A snapshot of dancer positions at a specific timestamp
- **Placement**: Individual dancer position within a formation (x, y, rotation)
- **StageConfig**: Stage dimensions and shape configuration

## Setup Guide for Linux

Since DancePlanner is an iOS/iPadOS application built with SwiftUI, it requires Xcode which is macOS-only. However, you can build and deploy the app to an iPad from Linux using alternative approaches.

### Option 1: Using CI/CD with GitHub Actions (Recommended)

This repository includes a GitHub Actions workflow that builds the app on macOS runners. You can leverage this for free:

1. **Fork this repository** to your GitHub account

2. **Enable GitHub Actions** in your repository settings

3. **Set up Apple Developer credentials** (if signing):
   - Create an App Store Connect API key
   - Add secrets to your repository: `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_KEY`

4. **Push changes** to trigger the workflow, which will build the app

5. **Download the built IPA** from the workflow artifacts

### Option 2: Using Remote macOS (Cloud Services)

Use a cloud macOS instance to build the app:

1. **Choose a cloud provider**:
   - [MacStadium](https://www.macstadium.com/) - Dedicated Mac hosting
   - [MacinCloud](https://www.macincloud.com/) - Mac rental service
   - [AWS EC2 Mac Instances](https://aws.amazon.com/ec2/instance-types/mac/) - Pay-per-use

2. **SSH into the macOS instance** from your Linux machine:
   ```bash
   ssh user@mac-instance-ip
   ```

3. **Clone the repository**:
   ```bash
   git clone https://github.com/raphaelbleier/DancePlanner.git
   cd DancePlanner
   ```

4. **Build with Xcode Command Line Tools** (see Building section below)

### Option 3: Cross-Platform Development (Experimental)

While not officially supported, you can explore:

- **[Swift for Linux](https://www.swift.org/download/)**: Swift compiler runs on Linux, but SwiftUI and iOS frameworks are not available
- **[Darling](https://www.darlinghq.org/)**: Translation layer for running macOS software on Linux (experimental, limited support)

**Note**: For production apps, using macOS (via cloud or CI/CD) is the most reliable approach.

## Building the App

### Prerequisites

1. **Apple Developer Account** (Free or Paid):
   - Free: 7-day signing, limited to 3 apps, requires rebuilding weekly
   - Paid ($99/year): 1-year signing, TestFlight distribution, App Store publishing

2. **Xcode Installation** (on macOS or cloud macOS):
   ```bash
   # Install from Mac App Store, or via command line:
   xcode-select --install
   ```

3. **Clone the repository**:
   ```bash
   git clone https://github.com/raphaelbleier/DancePlanner.git
   cd DancePlanner
   ```

### Building with Xcode GUI

1. **Open the project**:
   ```bash
   cd DancePlanner
   open DancePlanner.xcodeproj  # If project file exists
   # Or open the .xcworkspace if using CocoaPods/SPM
   ```

2. **Configure signing**:
   - Select the project in the navigator
   - Choose the DancePlanner target
   - Go to "Signing & Capabilities"
   - Select your Team (Apple Developer account)
   - Choose a unique Bundle Identifier (e.g., `com.yourname.danceplanner`)

3. **Select your iPad**:
   - Connect your iPad via USB or WiFi
   - Trust the computer on your iPad when prompted
   - Select your iPad from the device dropdown in Xcode

4. **Build and run**:
   - Click the Play button (▶) or press `Cmd+R`
   - Xcode will build, sign, and install the app on your iPad

### Building with Command Line

For automation or CI/CD:

```bash
# Navigate to project directory
cd DancePlanner

# List available schemes
xcodebuild -list

# Build for device (requires connected iPad or valid provisioning)
xcodebuild -scheme DancePlanner \
  -destination 'generic/platform=iOS' \
  -archivePath build/DancePlanner.xcarchive \
  archive

# Export IPA (requires export options plist)
xcodebuild -exportArchive \
  -archivePath build/DancePlanner.xcarchive \
  -exportPath build/ \
  -exportOptionsPlist ExportOptions.plist
```

**Note**: Create an `ExportOptions.plist` file for export configuration:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
</dict>
</plist>
```

## Transferring to iPad Without Mac

### Method 1: Direct Installation from Xcode (Cloud macOS)

If using a cloud macOS instance:

1. **Enable WiFi Debugging** on your iPad:
   - Connect iPad to the same network as your computer/cloud instance
   - Settings → Developer → Enable "Connect via Network"

2. **Pair your iPad** in Xcode:
   - Window → Devices and Simulators
   - Click '+' to add network device
   - Enter iPad IP address

3. **Build and install** as normal over WiFi

### Method 2: Using AltStore (No Mac Required After Initial Setup)

[AltStore](https://altstore.io/) allows sideloading apps using your free Apple Developer account:

1. **Install AltStore** on Windows or Linux (via AltServer):
   - Download from https://altstore.io/
   - For Linux: Use Wine or run AltServer in VM

2. **Connect iPad** to your computer

3. **Install AltStore** on your iPad through the desktop app

4. **Get the IPA file**:
   - Build the IPA using CI/CD (GitHub Actions)
   - Or transfer from cloud macOS build

5. **Sideload with AltStore**:
   - Open AltStore on iPad
   - Tap '+' and select the DancePlanner IPA
   - Enter Apple ID credentials
   - App will be signed and installed

6. **Refresh weekly** (free account limitation):
   - AltStore can auto-refresh when on same WiFi

### Method 3: Using iOS App Signer + Sideloadly

For Linux users with IPA file:

1. **Get the IPA** from CI/CD build or cloud macOS

2. **Install Sideloadly** (Windows/Linux):
   - Download from https://sideloadly.io/
   - Works on Linux via Wine

3. **Connect iPad** via USB

4. **Sign and install**:
   - Open Sideloadly
   - Select the DancePlanner IPA
   - Enter Apple ID
   - Click Start

### Method 4: TestFlight (Requires Paid Developer Account)

For distribution to multiple devices:

1. **Create an App Store Connect entry**:
   - Log in to https://appstoreconnect.apple.com/
   - Create new app with unique Bundle ID

2. **Upload build**:
   ```bash
   xcrun altool --upload-app \
     --type ios \
     --file build/DancePlanner.ipa \
     --apiKey YOUR_API_KEY \
     --apiIssuer YOUR_ISSUER_ID
   ```

3. **Invite testers**:
   - Add internal or external testers in App Store Connect
   - Testers receive TestFlight invitation
   - Install TestFlight app on iPad and accept invitation

4. **Install from TestFlight**:
   - Open TestFlight app
   - Tap "Install" next to DancePlanner
   - Builds valid for 90 days

## Development Workflow

### Running Tests

```bash
# Using Xcode
xcodebuild test -scheme DancePlanner \
  -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch)'

# Or in Xcode GUI: Cmd+U
```

### Code Style

The project follows standard Swift/SwiftUI conventions:
- SwiftUI for all views
- SwiftData for persistence
- Combine for reactive updates
- MVVM architecture pattern

## Usage

### Creating Your First Project

1. **Launch DancePlanner** on your iPad
2. **Tap '+'** to create a new project
3. **Name your project** and confirm
4. **Add dancers**:
   - Switch to "Dancers" tab
   - Tap '+' to add a dancer
   - Set name, color, and height
5. **Configure stage**:
   - Tap gear icon (⚙️)
   - Set stage dimensions and shape
6. **Create formations**:
   - Switch to "2D Stage" or "3D Stage"
   - Add formation at timeline position
   - Drag dancers to desired positions
7. **Import music** (optional):
   - Add audio file to sync formations
8. **Export**:
   - Tap share icon to export PDF
   - Use screen recording for video

### Tips

- **Use Groups**: Organize dancers into groups for easier formation management
- **3D View**: Visualize depth and spacing from audience perspective
- **Path Trails**: Enable to see dancer movement patterns between formations
- **PDF Export**: Generate formation sheets for dancers to reference
- **Regular Saves**: Projects auto-save, but use multiple projects for backup

## Troubleshooting

### Build Issues

**"Developer cannot be verified"** on iPad:
- Settings → General → VPN & Device Management
- Trust your developer account

**"Unable to install"**:
- Check Bundle ID is unique
- Verify signing certificate is valid
- Free accounts limited to 3 active apps

**"This app cannot be installed because its integrity could not be verified"**:
- Re-sign the IPA with your Apple ID
- Ensure not using expired provisioning profile

### Runtime Issues

**App crashes on launch**:
- Check iOS version compatibility (requires iOS 17+)
- Clear app data and reinstall

**Cannot import audio**:
- Ensure audio file is in supported format (M4A, MP3, WAV)
- Check file permissions

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is available for personal and educational use. Please check with the repository owner for commercial use licensing.

## Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Check existing issues for solutions
- Provide detailed information (iOS version, device model, steps to reproduce)

## Acknowledgments

- Built with SwiftUI and SwiftData
- Uses PencilKit for drawing capabilities
- PDF generation with PDFKit
- Audio playback with AVFoundation

---

**Note**: This app is designed for iPad but also works on iPhone with adapted layouts. The timeline and formation views are optimized for the larger iPad screen for the best choreography planning experience.
