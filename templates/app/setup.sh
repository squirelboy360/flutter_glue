#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
CONFIG_FILE=".glue_config.json"
REPO_URL="https://github.com/squirelboy360/flutter_glue.git"
BRANCH="production"

echo -e "${BLUE}🚀 Flutter Glue Template Setup${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to store current configuration
store_current_config() {
    echo -e "\n${BLUE}📝 Storing current configuration...${NC}"
    
    # Get current app configuration
    APP_NAME=$(grep "name:" pubspec.yaml | head -n1 | cut -d: -f2 | tr -d ' ')
    BUNDLE_ID=$(grep "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -n1 | cut -d= -f2 | tr -d ' ";')
    
    # Create config JSON
    cat > "$CONFIG_FILE" << EOF
{
    "app_name": "$APP_NAME",
    "bundle_id": "$BUNDLE_ID",
    "last_update": "$(date +%Y-%m-%d)",
    "update_preferences": {
        "core_services": true,
        "native_code": true,
        "specific_files": []
    }
}
EOF
    echo -e "${GREEN}✅ Configuration stored${NC}"
}

# Function to load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        APP_NAME=$(jq -r '.app_name' "$CONFIG_FILE")
        BUNDLE_ID=$(jq -r '.bundle_id' "$CONFIG_FILE")
        UPDATE_CORE=$(jq -r '.update_preferences.core_services' "$CONFIG_FILE")
        UPDATE_NATIVE=$(jq -r '.update_preferences.native_code' "$CONFIG_FILE")
        return 0
    fi
    return 1
}

# Function to update specific components
update_component() {
    local temp_dir="$1"
    local component="$2"
    
    case $component in
        "core")
            echo -e "${BLUE}🔄 Updating core services...${NC}"
            rsync -av "$temp_dir/templates/app/lib/core/services/" "lib/core/services/"
            ;;
        "native")
            echo -e "${BLUE}📱 Updating native implementations...${NC}"
            # iOS
            rsync -av --exclude="Info.plist" --exclude="**/Base.lproj/*" \
                "$temp_dir/templates/app/ios/Runner/" "ios/Runner/"
            ;;
        *)
            if [ -f "$component" ]; then
                echo -e "${BLUE}📄 Updating specific file: $component${NC}"
                cp "$temp_dir/templates/app/$component" "$component"
            fi
            ;;
    esac
}

# Function to restore app-specific configurations
restore_app_config() {
    echo -e "\n${BLUE}🔄 Restoring app configuration...${NC}"
    
    # Update bundle ID in native files
    sed -i '' "s/com.example.app/${BUNDLE_ID}/g" ios/Runner.xcodeproj/project.pbxproj
    
    # Update app name in relevant files
    sed -i '' "s/example_app/${APP_NAME}/g" ios/Runner/Info.plist
    
    echo -e "${GREEN}✅ App configuration restored${NC}"
}

# Function to update from template
update_from_template() {
    echo -e "\n${BLUE}📥 Updating from template...${NC}"
    
    # Create temp directory for template
    temp_dir=$(mktemp -d)
    git clone --depth 1 -b $BRANCH $REPO_URL "$temp_dir"
    
    # Update components based on configuration
    if [ "$UPDATE_CORE" = "true" ]; then
        update_component "$temp_dir" "core"
    fi
    
    if [ "$UPDATE_NATIVE" = "true" ]; then
        update_component "$temp_dir" "native"
    fi
    
    # Update specific files if configured
    if [ -f "$CONFIG_FILE" ]; then
        SPECIFIC_FILES=$(jq -r '.update_preferences.specific_files[]' "$CONFIG_FILE")
        for file in $SPECIFIC_FILES; do
            update_component "$temp_dir" "$file"
        done
    fi
    
    # Restore app-specific configurations
    restore_app_config
    
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
    
    # Store configuration
    store_current_config
    
    # Initial setup using rename_app
    flutter pub get
    dart run rename_app:main all="$APP_NAME"
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

if ! command_exists jq; then
    echo -e "${RED}❌ jq not found. Please install jq first.${NC}"
    exit 1
fi

# Check if this is an existing project
if [ -f "pubspec.yaml" ]; then
    if load_config; then
        echo -e "${YELLOW}🔄 Detected existing project: $APP_NAME${NC}"
        echo -e "Current configuration:"
        echo -e "  App Name: $APP_NAME"
        echo -e "  Bundle ID: $BUNDLE_ID"
        
        # Ask what to update
        echo -e "\n${BLUE}What would you like to update?${NC}"
        echo "1. Everything (core + native)"
        echo "2. Core services only"
        echo "3. Native code only"
        echo "4. Specific files"
        read -p "Enter choice (1-4): " choice
        
        case $choice in
            1)
                UPDATE_CORE=true
                UPDATE_NATIVE=true
                ;;
            2)
                UPDATE_CORE=true
                UPDATE_NATIVE=false
                ;;
            3)
                UPDATE_CORE=false
                UPDATE_NATIVE=true
                ;;
            4)
                UPDATE_CORE=false
                UPDATE_NATIVE=false
                echo -e "\n${BLUE}Enter file paths to update (empty line to finish):${NC}"
                while true; do
                    read -p "File path: " file
                    [ -z "$file" ] && break
                    jq --arg file "$file" '.update_preferences.specific_files += [$file]' "$CONFIG_FILE" > temp.json && mv temp.json "$CONFIG_FILE"
                done
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                exit 1
                ;;
        esac
        
        # Update configuration file
        jq ".update_preferences.core_services = $UPDATE_CORE | .update_preferences.native_code = $UPDATE_NATIVE" "$CONFIG_FILE" > temp.json && mv temp.json "$CONFIG_FILE"
        
        update_from_template
    else
        echo -e "${YELLOW}No configuration found. Creating new configuration...${NC}"
        store_current_config
        update_from_template
    fi
else
    setup_new_project
fi

# Clean and setup
echo -e "\n${BLUE}🧹 Cleaning and setting up...${NC}"
flutter clean
rm -rf ios/Pods ios/.symlinks ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..

# Build
echo -e "\n${BLUE}🔨 Building...${NC}"
flutter build ios --debug --no-codesign

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
