#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
DEFAULT_BUNDLE_ID="com.example.app"
DEFAULT_APP_NAME="example_app"
REPO_URL="https://github.com/squirelboy360/flutter_glue.git"
BRANCH="production"

echo -e "${BLUE}🚀 Flutter Glue Template Setup${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if running in an existing project
is_existing_project() {
    if [ -f "pubspec.yaml" ]; then
        current_name=$(grep "name:" pubspec.yaml | head -n1 | cut -d: -f2 | tr -d ' ')
        if [ "$current_name" != "$DEFAULT_APP_NAME" ]; then
            return 0
        fi
    fi
    return 1
}

# Function to update from template
update_from_template() {
    echo -e "\n${BLUE}📥 Updating from template...${NC}"
    
    # Create temp directory for template
    temp_dir=$(mktemp -d)
    git clone --depth 1 -b $BRANCH $REPO_URL "$temp_dir"
    
    # Copy native implementations while preserving app-specific changes
    echo -e "${BLUE}📱 Updating native implementations...${NC}"
    
    # iOS
    rsync -av --exclude="Info.plist" --exclude="**/Base.lproj/*" \
        "$temp_dir/templates/app/ios/Runner/" "ios/Runner/"
    
    # Update services and core functionality
    echo -e "${BLUE}🔄 Updating core services...${NC}"
    rsync -av "$temp_dir/templates/app/lib/core/services/" "lib/core/services/"
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Function to setup new project
setup_new_project() {
    echo -e "\n${YELLOW}📝 Setting up new project${NC}"
    
    # Get app name
    read -p "Enter your app name (e.g., My Amazing App): " APP_NAME
    read -p "Enter bundle ID (e.g., com.company.app): " BUNDLE_ID
    
    if [ -z "$APP_NAME" ] || [ -z "$BUNDLE_ID" ]; then
        echo -e "${RED}❌ App name and bundle ID are required${NC}"
        exit 1
    fi
    
    # Use rename_app package for initial rename
    echo -e "\n${BLUE}🏷️ Renaming app...${NC}"
    flutter pub get
    dart run rename_app:main all="$APP_NAME"
    
    # Additional iOS configurations
    echo -e "\n${BLUE}🍎 Configuring iOS...${NC}"
    
    # Update bundle ID in pbxproj
    sed -i '' "s/org.cocoapods.${DEFAULT_APP_NAME}/${BUNDLE_ID}/g" ios/Runner.xcodeproj/project.pbxproj
    sed -i '' "s/com.example.${DEFAULT_APP_NAME}/${BUNDLE_ID}/g" ios/Runner.xcodeproj/project.pbxproj
    
    # Update deep linking configurations
    echo -e "\n${BLUE}🔗 Configuring deep linking...${NC}"
    
    # Update Info.plist
    PLIST_PATH="ios/Runner/Info.plist"
    plutil -replace CFBundleURLSchemes -json "[\"${BUNDLE_ID}\"]" "$PLIST_PATH"
    
    # Update associated domains if provided
    read -p "Enter associated domain for universal links (press enter to skip): " ASSOCIATED_DOMAIN
    if [ ! -z "$ASSOCIATED_DOMAIN" ]; then
        plutil -replace com.apple.developer.associated-domains -json "[\"applinks:${ASSOCIATED_DOMAIN}\"]" "$PLIST_PATH"
    fi
}

# Check prerequisites
echo -e "\n${BLUE}📋 Checking prerequisites...${NC}"

if ! command_exists flutter; then
    echo -e "${RED}❌ Flutter not found. Please install Flutter first.${NC}"
    exit 1
fi

if ! command_exists pod; then
    echo -e "${RED}❌ CocoaPods not found. Please install CocoaPods first.${NC}"
    exit 1
fi

# Determine if this is an existing project
if is_existing_project; then
    echo -e "${YELLOW}🔄 Detected existing project${NC}"
    read -p "Do you want to update from template? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        update_from_template
    fi
else
    setup_new_project
fi

# Clean existing build artifacts
echo -e "\n${BLUE}🧹 Cleaning project...${NC}"
flutter clean
rm -rf ios/Pods
rm -rf ios/.symlinks
rm -f ios/Podfile.lock

# Get dependencies
echo -e "\n${BLUE}📦 Getting Flutter dependencies...${NC}"
flutter pub get

# Setup iOS
echo -e "\n${BLUE}🍎 Setting up iOS project...${NC}"
cd ios
pod install
cd ..

# Run Flutter doctor
echo -e "\n${BLUE}🏥 Running Flutter doctor...${NC}"
flutter doctor

# Build initial debug version
echo -e "\n${BLUE}🔨 Building initial debug version...${NC}"
flutter build ios --debug --no-codesign

# Final checks
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Setup completed successfully!${NC}"
    echo -e "\n${BLUE}Next steps:${NC}"
    echo "1. Open your project in Xcode: open ios/Runner.xcworkspace"
    echo "2. Configure your team signing settings in Xcode"
    echo "3. Run flutter run to start development"
else
    echo -e "${RED}❌ Build failed. Please check the error messages above.${NC}"
    exit 1
fi
