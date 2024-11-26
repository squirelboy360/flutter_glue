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
BACKUP_DIR=".glue_backup"

echo -e "${BLUE}🚀 Flutter Glue Template Setup${NC}"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create new project from template
setup_new_project() {
    echo -e "\n${BLUE}🆕 Creating new project from template${NC}"
    
    # Get app details
    if [ -z "$APP_NAME" ]; then
        read -p "Enter your app name (e.g., My Amazing App): " APP_NAME
    fi
    if [ -z "$BUNDLE_ID" ]; then
        read -p "Enter bundle ID (e.g., com.company.app): " BUNDLE_ID
    fi
    
    if [ -z "$APP_NAME" ] || [ -z "$BUNDLE_ID" ]; then
        echo -e "${RED}❌ App name and bundle ID are required${NC}"
        exit 1
    fi
    
    # Convert app name to valid package name
    PACKAGE_NAME=$(echo "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr '-' '_')
    
    echo -e "\n${BLUE}📦 Setting up project structure...${NC}"
    
    # Move setup.sh to parent directory temporarily
    mv setup.sh ../setup.sh.tmp
    
    # Clone template
    if ! git clone --depth 1 -b $BRANCH $REPO_URL .; then
        # Restore setup.sh if clone fails
        mv ../setup.sh.tmp setup.sh
        echo -e "${RED}❌ Failed to download template${NC}"
        exit 1
    fi
    
    # Remove git folder
    rm -rf .git
    
    # Move setup.sh back
    mv ../setup.sh.tmp setup.sh
    
    # Update app name and bundle ID
    echo -e "\n${BLUE}🔄 Configuring project...${NC}"
    
    # Update iOS bundle ID
    sed -i '' "s/com.example.app/${BUNDLE_ID}/g" ios/Runner.xcodeproj/project.pbxproj
    sed -i '' "s/com.example.app/${BUNDLE_ID}/g" ios/Runner/Info.plist
    
    # Update app name in various files
    sed -i '' "s/example_app/${PACKAGE_NAME}/g" pubspec.yaml
    sed -i '' "s/example_app/${PACKAGE_NAME}/g" ios/Runner/Info.plist
    
    # Create initial configuration
    cat > "$CONFIG_FILE" << EOF
{
    "app_name": "$APP_NAME",
    "bundle_id": "$BUNDLE_ID",
    "package_name": "$PACKAGE_NAME",
    "last_update": "$(date +%Y-%m-%d)",
    "update_preferences": {
        "core_services": true,
        "native_code": true,
        "specific_files": [],
        "excluded_files": []
    },
    "deep_linking": {
        "domains": [],
        "schemes": ["$BUNDLE_ID"]
    }
}
EOF
    
    # Setup Flutter project
    echo -e "\n${BLUE}📱 Setting up Flutter...${NC}"
    flutter clean
    flutter pub get
    
    # Setup iOS
    echo -e "\n${BLUE}🍎 Setting up iOS...${NC}"
    cd ios
    rm -rf Pods Podfile.lock
    pod install
    cd ..
    
    echo -e "${GREEN}✅ New project created successfully!${NC}"
    echo -e "\n${BLUE}Next steps:${NC}"
    echo "1. Open your project in Xcode: open ios/Runner.xcworkspace"
    echo "2. Configure your team signing settings in Xcode"
    echo "3. Run flutter run to start development"
    
    # Clean up setup script after successful execution
    rm -f setup.sh
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

# Main logic
if ! command_exists flutter || ! command_exists pod || ! command_exists jq; then
    echo -e "${RED}❌ Missing required tools. Please install:${NC}"
    echo "- Flutter"
    echo "- CocoaPods"
    echo "- jq"
    exit 1
fi

# Check if this is a new project or update
if [ ! -f "$CONFIG_FILE" ] && [ ! -f "pubspec.yaml" ]; then
    # New project - create from template
    setup_new_project
elif [ -f "$CONFIG_FILE" ]; then
    # Existing project - show update menu
    echo -e "\n${BLUE}What would you like to do?${NC}"
    echo "1. Update template components"
    echo "2. Change app configuration"
    echo "3. Exit"
    read -p "Enter choice (1-3): " choice
    
    case $choice in
        1)
            echo -e "\n${BLUE}What would you like to update?${NC}"
            echo "1. Everything (core + native)"
            echo "2. Core services only"
            echo "3. Native code only"
            echo "4. Specific files"
            read -p "Enter choice (1-4): " update_choice
            
            case $update_choice in
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
            
            update_from_template
            ;;
        2)
            store_current_config
            ;;
        3)
            echo -e "${BLUE}👋 Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice${NC}"
            exit 1
            ;;
    esac
else
    echo -e "${RED}❌ Invalid project state. Neither config nor pubspec.yaml found.${NC}"
    echo -e "Would you like to create a new project? [Y/n] "
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY]|)$ ]]; then
        setup_new_project
    else
        exit 1
    fi
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