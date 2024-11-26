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

# Function to backup important files
backup_files() {
    echo -e "\n${BLUE}📦 Creating backup...${NC}"
    mkdir -p "$BACKUP_DIR"
    cp -r ios/Runner/Info.plist "$BACKUP_DIR/"
    cp -r ios/Runner.xcodeproj/project.pbxproj "$BACKUP_DIR/"
    cp -r pubspec.yaml "$BACKUP_DIR/"
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$BACKUP_DIR/"
    fi
}

# Function to restore from backup if something goes wrong
restore_from_backup() {
    echo -e "\n${YELLOW}⚠️ Restoring from backup...${NC}"
    if [ -d "$BACKUP_DIR" ]; then
        cp -r "$BACKUP_DIR/Info.plist" ios/Runner/
        cp -r "$BACKUP_DIR/project.pbxproj" ios/Runner.xcodeproj/
        cp -r "$BACKUP_DIR/pubspec.yaml" ./
        if [ -f "$BACKUP_DIR/$CONFIG_FILE" ]; then
            cp "$BACKUP_DIR/$CONFIG_FILE" ./
        fi
        rm -rf "$BACKUP_DIR"
        echo -e "${GREEN}✅ Restore completed${NC}"
    fi
}

# Function to detect current app configuration
detect_app_config() {
    local detected_name=""
    local detected_bundle=""
    
    if [ -f "pubspec.yaml" ]; then
        detected_name=$(grep "name:" pubspec.yaml | head -n1 | cut -d: -f2 | tr -d ' ')
    fi
    
    if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
        detected_bundle=$(grep "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -n1 | cut -d= -f2 | tr -d ' ";')
    fi
    
    echo "$detected_name|$detected_bundle"
}

# Function to store current configuration
store_current_config() {
    local current_config
    if [ -f "$CONFIG_FILE" ]; then
        current_config=$(cat "$CONFIG_FILE")
    fi
    
    echo -e "\n${BLUE}📝 Managing configuration...${NC}"
    
    # Detect current configuration
    local detected=$(detect_app_config)
    local detected_name=$(echo "$detected" | cut -d'|' -f1)
    local detected_bundle=$(echo "$detected" | cut -d'|' -f2)
    
    # Use existing values from config if available
    if [ ! -z "$current_config" ]; then
        APP_NAME=${APP_NAME:-$(echo "$current_config" | jq -r '.app_name')}
        BUNDLE_ID=${BUNDLE_ID:-$(echo "$current_config" | jq -r '.bundle_id')}
    fi
    
    # Use detected values if nothing is set
    APP_NAME=${APP_NAME:-$detected_name}
    BUNDLE_ID=${BUNDLE_ID:-$detected_bundle}
    
    # Show current configuration
    echo -e "Current configuration:"
    echo -e "  App Name: $APP_NAME"
    echo -e "  Bundle ID: $BUNDLE_ID"
    
    # Allow user to change configuration
    read -p "Would you like to change the app name? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter new app name: " new_name
        if [ ! -z "$new_name" ]; then
            APP_NAME="$new_name"
        fi
    fi
    
    read -p "Would you like to change the bundle ID? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter new bundle ID: " new_bundle
        if [ ! -z "$new_bundle" ]; then
            BUNDLE_ID="$new_bundle"
        fi
    fi
    
    # Create or update config JSON
    cat > "$CONFIG_FILE" << EOF
{
    "app_name": "$APP_NAME",
    "bundle_id": "$BUNDLE_ID",
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
    echo -e "${GREEN}✅ Configuration updated${NC}"
}

# Function to update from template
update_from_template() {
    echo -e "\n${BLUE}📥 Updating from template...${NC}"
    
    # Backup current state
    backup_files
    
    # Create temp directory for template
    temp_dir=$(mktemp -d)
    if git clone --depth 1 -b $BRANCH $REPO_URL "$temp_dir"; then
        # Update components based on configuration
        if [ "$UPDATE_CORE" = "true" ]; then
            echo -e "${BLUE}🔄 Updating core services...${NC}"
            rsync -av --exclude="*.g.dart" \
                "$temp_dir/templates/app/lib/core/services/" "lib/core/services/"
        fi
        
        if [ "$UPDATE_NATIVE" = "true" ]; then
            echo -e "${BLUE}📱 Updating native implementations...${NC}"
            # iOS - preserve Info.plist and project configuration
            rsync -av --exclude="Info.plist" \
                --exclude="project.pbxproj" \
                --exclude="**/Base.lproj/*" \
                "$temp_dir/templates/app/ios/Runner/" "ios/Runner/"
        fi
        
        # Update specific files if configured
        if [ -f "$CONFIG_FILE" ]; then
            SPECIFIC_FILES=$(jq -r '.update_preferences.specific_files[]' "$CONFIG_FILE")
            for file in $SPECIFIC_FILES; do
                if [ -f "$temp_dir/templates/app/$file" ]; then
                    echo -e "${BLUE}📄 Updating: $file${NC}"
                    cp "$temp_dir/templates/app/$file" "$file"
                fi
            done
        fi
        
        # Cleanup
        rm -rf "$temp_dir"
        
        # Restore app configuration
        echo -e "\n${BLUE}🔄 Restoring app configuration...${NC}"
        if [ -f "$CONFIG_FILE" ]; then
            # Update bundle ID
            sed -i '' "s/com.example.app/${BUNDLE_ID}/g" ios/Runner.xcodeproj/project.pbxproj
            # Update app name
            sed -i '' "s/example_app/${APP_NAME}/g" ios/Runner/Info.plist
        fi
        
        echo -e "${GREEN}✅ Update completed successfully${NC}"
    else
        echo -e "${RED}❌ Failed to download template${NC}"
        restore_from_backup
        exit 1
    fi
}

# Main logic
if ! command_exists flutter || ! command_exists pod || ! command_exists jq; then
    echo -e "${RED}❌ Missing required tools. Please install:${NC}"
    echo "- Flutter"
    echo "- CocoaPods"
    echo "- jq"
    exit 1
fi

# Store/update configuration first
store_current_config

if [ -f "$CONFIG_FILE" ]; then
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
    echo -e "${YELLOW}No configuration found. Setting up new project...${NC}"
    store_current_config
fi

# Final setup steps
if [ "$UPDATE_CORE" = "true" ] || [ "$UPDATE_NATIVE" = "true" ]; then
    echo -e "\n${BLUE}🧹 Running final setup...${NC}"
    flutter clean
    rm -rf ios/Pods ios/.symlinks ios/Podfile.lock
    flutter pub get
    cd ios && pod install && cd ..
    
    echo -e "\n${GREEN}✅ Setup completed successfully!${NC}"
    echo -e "\n${BLUE}Next steps:${NC}"
    echo "1. Open your project in Xcode: open ios/Runner.xcworkspace"
    echo "2. Configure your team signing settings in Xcode"
    echo "3. Run flutter run to start development"
fi
