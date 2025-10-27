# GitHub Actions Workflows

This directory contains GitHub Actions workflows for building and releasing the SQL Edit app across multiple platforms with intelligent version-based building.

## 🧠 Smart Building Strategy

All workflows now use **version-based building** - builds only trigger when the version in `pubspec.yaml` changes, saving CI resources and preventing unnecessary builds.

## 📋 Available Workflows

### 1. Smart Build (`smart-build.yml`) - ⭐ **RECOMMENDED**
Intelligent workflow that builds only when version changes, with advanced features.

**Triggers:**
- Push to `main` or `develop` (only if `pubspec.yaml` version changed)
- Pull requests to `main` (validates changes)
- Manual trigger with customizable options

**Features:**
- ✅ Version change detection
- 🎯 Selective platform building
- 📊 Build decision summaries
- 🔧 Force build option
- 📦 Version-tagged artifacts

**Outputs:**
- `sql-edit-v{VERSION}-android.apk/aab`
- `sql-edit-v{VERSION}-ios.xcarchive`
- `sql-edit-v{VERSION}-windows.zip`
- `sql-edit-v{VERSION}-macos.zip`
- `sql-edit-v{VERSION}-linux.tar.gz`

### 2. Mobile Build (`mobile.yml`)
Legacy mobile-only workflow with version checking.

**Triggers:**
- Push to `main` or `develop` (only if `pubspec.yaml` changed)
- Pull requests to `main` (only if `pubspec.yaml` changed)
- Manual trigger

**Outputs:**
- Android APK and App Bundle
- iOS Archive

### 3. Desktop Build (`desktop.yml`)
Legacy desktop-only workflow with version checking.

**Triggers:**
- Push to `main` or `develop` (only if `pubspec.yaml` changed)
- Pull requests to `main` (only if `pubspec.yaml` changed)
- Manual trigger

**Outputs:**
- Windows, macOS, and Linux packages

### 4. Release Build (`release.yml`)
Comprehensive build for all platforms when creating releases.

**Triggers:**
- Push to tags starting with `v*` (e.g., `v1.0.0`)
- Manual trigger with version input

**Outputs:**
- All mobile and desktop builds
- Automatic GitHub release with all artifacts

### 5. Version Check (`version-check.yml`)
Reusable workflow for version checking logic.

**Purpose:**
- Detects version changes in `pubspec.yaml`
- Provides version information to other workflows
- Can be called by other workflows

## 🚀 Usage

### Smart Building (Recommended)

The **Smart Build** workflow is the most efficient way to build your app:

1. **Update version in `pubspec.yaml`:**
   ```yaml
   version: 1.0.1+2  # Change this line
   ```

2. **Commit and push:**
   ```bash
   git add pubspec.yaml
   git commit -m "Bump version to 1.0.1+2"
   git push origin main
   ```

3. **Build automatically triggers** - Only runs when version changes!

### Manual Building Options

1. **Force build all platforms:**
   - Go to Actions → Smart Build
   - Click "Run workflow"
   - Check "Force build even if version unchanged"
   - Select platforms: `android,ios,windows,macos,linux`

2. **Build specific platforms:**
   - Use the platforms input: `android,ios` (mobile only)
   - Or: `windows,macos,linux` (desktop only)

### For Releases

1. **Create and push a tag:**
   ```bash
   git tag v1.0.1
   git push origin v1.0.1
   ```

2. **Manual release:**
   - Go to Actions tab
   - Select "Release Build (All Platforms)"
   - Click "Run workflow"
   - Enter version (e.g., v1.0.1)

### Version Change Detection

Workflows detect version changes by:
- 📝 **Push events**: Comparing current vs previous commit
- 🔍 **Pull requests**: Comparing branch vs base branch
- 🏷️ **Tags**: Always build (release scenario)
- 🔧 **Manual**: Always build (unless specified otherwise)

## 📦 Artifacts

### Smart Build Artifacts (Version-Tagged)
- **android-v{VERSION}**: `sql-edit-v1.0.1-android.apk` and `.aab`
- **ios-v{VERSION}**: `sql-edit-v1.0.1-ios.xcarchive`
- **windows-v{VERSION}**: `sql-edit-v1.0.1-windows.zip`
- **macos-v{VERSION}**: `sql-edit-v1.0.1-macos.zip`
- **linux-v{VERSION}**: `sql-edit-v1.0.1-linux.tar.gz`

### Legacy Workflow Artifacts
- **android-apk**: Ready-to-install APK file
- **android-aab**: App Bundle for Google Play Store
- **ios-archive**: iOS archive for App Store distribution
- **windows-app**: Windows executable package
- **macos-app**: macOS application bundle
- **linux-app**: Linux application package

### Artifact Retention
- Artifacts are kept for **90 days** by default
- Release artifacts are permanent (attached to GitHub releases)
- Download important builds for archival purposes

## 🔧 Configuration

### Flutter Version
All workflows use Flutter `3.24.3` stable. To update:
1. Change the `flutter-version` in all workflow files
2. Test builds locally first

### Build Configurations
- All builds use `--release` configuration for optimized performance
- Code signing is disabled for iOS builds (can be configured for distribution)
- Windows builds create ZIP packages (can be extended to create MSI installers)

### Requirements
- **Android**: Requires Java 17
- **iOS**: Requires macOS runner and CocoaPods
- **Desktop**: Platform-specific dependencies are automatically installed

## 🔐 Secrets and Permissions

### Required Permissions
- `contents: read` - To checkout repository
- `contents: write` - To create releases (automatic via GITHUB_TOKEN)

### Optional Secrets (for signed builds)
For production releases, you may want to add these secrets:

**Android:**
- `ANDROID_KEYSTORE_FILE` - Base64 encoded keystore
- `ANDROID_KEYSTORE_PASSWORD` - Keystore password
- `ANDROID_KEY_ALIAS` - Key alias
- `ANDROID_KEY_PASSWORD` - Key password

**iOS:**
- `IOS_CERTIFICATE_FILE` - Base64 encoded certificate
- `IOS_CERTIFICATE_PASSWORD` - Certificate password
- `IOS_PROVISIONING_PROFILE` - Base64 encoded provisioning profile

## 🐛 Troubleshooting

### Version-Related Issues

1. **Builds not triggering:**
   - Ensure you actually changed the `version:` line in `pubspec.yaml`
   - Check that you're pushing to `main` or `develop` branch
   - Verify the version format: `MAJOR.MINOR.PATCH+BUILD` (e.g., `1.0.0+1`)

2. **"No version change detected":**
   - The workflow correctly detected no version change
   - Use manual trigger with "Force build" if needed
   - Double-check your version format in `pubspec.yaml`

3. **Version validation warnings:**
   - Ensure version follows semantic versioning: `1.0.0+1`
   - Build number (+1) is optional but recommended for mobile apps

### Common Build Issues

1. **Build fails on iOS:**
   - Ensure CocoaPods dependencies are up to date
   - Check iOS deployment target compatibility

2. **Android build fails:**
   - Verify Java 17 compatibility
   - Check Android SDK requirements in `android/app/build.gradle`

3. **Desktop builds fail:**
   - Ensure all platform-specific dependencies are installed
   - Check Flutter desktop support is enabled

### Debugging Steps

1. **Check version detection:**
   - Look at the "Version Check Summary" in workflow logs
   - Verify the detected current and previous versions

2. **Check workflow logs:**
   - Go to Actions tab
   - Click on failed workflow
   - Expand failed step to see detailed logs

3. **Test locally:**
   ```bash
   # Check current version
   grep "^version:" pubspec.yaml
   
   # Test specific platform builds
   flutter build apk --release
   flutter build ios --release --no-codesign
   flutter build windows --release
   flutter build macos --release
   flutter build linux --release
   ```

4. **Verify dependencies:**
   ```bash
   flutter doctor -v
   flutter pub get
   flutter analyze
   ```

### Force Building

If you need to build without changing version:
1. Go to Actions → Smart Build → Run workflow
2. Check "Force build even if version unchanged"
3. Select desired platforms
4. Click "Run workflow"

## 📝 Customization

### Adding New Platforms
To add support for additional platforms:

1. Add new job in relevant workflow file
2. Configure platform-specific dependencies
3. Add build commands
4. Upload artifacts

### Modifying Build Process
Common customizations:

- **Change output names**: Modify artifact names in upload steps
- **Add code signing**: Include signing steps for production builds
- **Custom build flags**: Modify `flutter build` commands
- **Additional testing**: Add test steps before builds

### Environment Variables
You can add environment variables to customize builds:

```yaml
env:
  BUILD_NUMBER: ${{ github.run_number }}
  BUILD_NAME: ${{ github.ref_name }}
```

## 🎯 Best Practices

### Version Management
1. **Use semantic versioning** in `pubspec.yaml`: `MAJOR.MINOR.PATCH+BUILD`
2. **Increment appropriately:**
   - **PATCH** (1.0.1): Bug fixes
   - **MINOR** (1.1.0): New features (backward compatible)
   - **MAJOR** (2.0.0): Breaking changes
   - **BUILD** (+2): Build/CI iterations

3. **Update version before significant commits:**
   ```bash
   # Good workflow
   git add . 
   # Edit pubspec.yaml version first
   git add pubspec.yaml
   git commit -m "Add new feature and bump version to 1.1.0"
   git push origin main  # Triggers build automatically
   ```

### Development Workflow
1. **Test locally** before pushing changes
2. **Use feature branches** for development
3. **Only merge to main/develop** when ready to build
4. **Monitor build times** and optimize as needed
5. **Update Flutter version** regularly for security and features

### CI/CD Optimization
1. **Use Smart Build** workflow for most scenarios
2. **Selective platform building** when testing specific platforms
3. **Force build sparingly** to conserve CI resources
4. **Monitor artifact storage** and clean up old builds
5. **Use caching** for dependencies (can be added for faster builds)

### Release Management
1. **Create tags** for official releases: `git tag v1.0.0`
2. **Use release workflow** for distribution-ready builds
3. **Keep release notes** updated in GitHub releases
4. **Archive important builds** before artifact expiration

## 📊 Monitoring

### Build Status
- Check the Actions tab for build status badges
- Set up notifications for failed builds
- Monitor build times and success rates

### Artifact Management
- Artifacts are kept for 90 days by default
- Download important builds for archival
- Clean up old artifacts to save storage

---

For more information about GitHub Actions, visit the [official documentation](https://docs.github.com/en/actions).