#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# export GUM_TABLE_BORDER_FOREGROUND=""
# export GUM_TABLE_BORDER_BACKGROUND=""
# export GUM_TABLE_CELL_FOREGROUND=""
# export GUM_TABLE_CELL_BACKGROUND=""
# export GUM_TABLE_HEADER_FOREGROUND=""
# export GUM_TABLE_HEADER_BACKGROUND=""
export GUM_TABLE_SELECTED_FOREGROUND="#000000"
export GUM_TABLE_SELECTED_BACKGROUND="#00A000"

export GUM_CHOOSE_CURSOR_FOREGROUND="#00A000"
# export GUM_CHOOSE_CURSOR_BACKGROUND=""
export GUM_CHOOSE_HEADER_FOREGROUND="#00A000"
# export GUM_CHOOSE_HEADER_BACKGROUND=""
# export GUM_CHOOSE_ITEM_FOREGROUND=""
# export GUM_CHOOSE_ITEM_BACKGROUND=""
export GUM_CHOOSE_SELECTED_FOREGROUND="#000000"
export GUM_CHOOSE_SELECTED_BACKGROUND="#00A000"

export GUM_SPIN_SPINNER_FOREGROUND="#00A000"

export GUM_CONFIRM_PROMPT_BACKGROUND=""
export GUM_CONFIRM_PROMPT_FOREGROUND="#00A000"
export GUM_CONFIRM_SELECTED_FOREGROUND="#00A000"
export GUM_CONFIRM_SELECTED_BACKGROUND="#000000"
export GUM_CONFIRM_UNSELECTED_FOREGROUND="#003300"
export GUM_CONFIRM_UNSELECTED_BACKGROUND="#000000"

# Define the directory where binaries will be stored
HOBIN_DIR="$HOME/bin"
CACHE_DIR="$HOME/.cache/hobin"
CACHE_FILE="$HOME/.cache/hobin.cache"

mkdir -p "$HOBIN_DIR"
mkdir -p "$CACHE_DIR"

check_script_location() {
    local script_path=$(readlink -f "$0")
    local script_name=$(basename "$script_path")
    local target_path="$HOBIN_DIR/$script_name"

    if [[ "$script_path" != "$target_path" ]]; then
        echo -e "\n${YELLOW}First run detected!${NC}"
        echo -e "${GREEN}Installing hobin script to $HOBIN_DIR...${NC}"

        mkdir -p "$HOBIN_DIR"

        cp "$script_path" "$target_path"
        chmod u+x "$target_path"

        echo -e "${GREEN}Script installed to $HOBIN_DIR${NC}"

        echo -e "${GREEN}Restarting script from new location...${NC}"
        exec "$target_path"
        exit 0
    fi
}

banner() {
    local ASCII_ART="
██╗  ██╗██████╗       ██╗  ██╗ ██████╗ ██████╗ ██╗███╗   ██╗
██║  ██║╚════██╗      ██║  ██║██╔═══██╗██╔══██╗██║████╗  ██║
███████║ █████╔╝█████╗███████║██║   ██║██████╔╝██║██╔██╗ ██║
╚════██║██╔═══╝ ╚════╝██╔══██║██║   ██║██╔══██╗██║██║╚██╗██║
     ██║███████╗      ██║  ██║╚██████╔╝██████╔╝██║██║ ╚████║
     ╚═╝╚══════╝      ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝
     Personal \$HOME/bin Manager                        v0.2"

    if is_tool_available "gum"; then
        gum style \
            --foreground 10 --border-foreground 34 --border rounded \
            --align center --width 78 --margin "0 0" --padding "0 0" \
            "$ASCII_ART"
        echo
    else
        echo -e "$ASCII_ART"
        echo "________________________________________________"
        echo
    fi
}

# Check if we need to install the script itself
check_script_location

# Check if HOBIN_DIR is in PATH and add it if missing
check_bin_dir_in_path() {
    if [[ ":$PATH:" != *":$HOBIN_DIR:"* ]]; then
        echo -e "\n${YELLOW}WARNING:${NC} $HOBIN_DIR is not in your PATH!"
        echo -e "This means the installed binaries won't be directly accessible from your terminal."

        # Detect current shell using $SHELL variable
        CURRENT_SHELL=$(basename "$SHELL")

        # Add to PATH configuration based on shell type
        case "$CURRENT_SHELL" in
            "zsh")
                echo -e "\n${GREEN}Adding $HOBIN_DIR to your PATH in $HOME/.zshrc...${NC}"
                echo 'export PATH="'$HOBIN_DIR':$PATH"' >> $HOME/.zshrc
                SHELL_CONFIG="$HOME/.zshrc"
                ;;
            "bash")
                echo -e "\n${GREEN}Adding $HOBIN_DIR to your PATH in $HOME/.bashrc...${NC}"
                echo 'export PATH="'$HOBIN_DIR':$PATH"' >> $HOME/.bashrc
                SHELL_CONFIG="$HOME/.bashrc"
                ;;
            *)
                echo -e "\n${YELLOW}Not able to automatically configure your $CURRENT_SHELL.${NC}"
                echo -e "\nPlease add this line to your shell's configuration file:"
                echo -e "export PATH=\"$HOBIN_DIR:\$PATH\""
                echo -e "\n${GREEN}Temporarily adding to PATH for this session...${NC}"
                ;;
        esac

        # Ensure PATH is updated for the current session regardless
        export PATH="$HOBIN_DIR:$PATH"
        echo -e "\n${GREEN}PATH updated for current session.${NC}"
        echo -e "Binaries in $HOBIN_DIR will now be accessible."

        # Ask user if they want to restart the script in a new shell session
        echo -e "\n${YELLOW}To fully apply PATH changes, the script needs to restart in a new shell session.${NC}"
        if is_tool_available "gum"; then
            if gum confirm "Restart script in a new shell session?"; then
                # Save the current script path
                SCRIPT_PATH="$(readlink -f "$0")"
                gum style --foreground 6 "Restarting script in a new shell session..."
                gum style --foreground 5 "Execute: hobin.sh"
                # Execute the script in a new shell session
                # exec "$SHELL" -c "source \"$SHELL_CONFIG\" 2>/dev/null; \"$SCRIPT_PATH\""
                $SHELL
                exit 0
            fi
        else
            read -rp "Restart script in a new shell session? (Y/n): " restart_choice
            if [[ "$restart_choice" =~ ^[Yy]$ || -z "$restart_choice" ]]; then
                # Save the current script path
                SCRIPT_PATH="$(readlink -f "$0")"
                echo -e "\nRestarting script in a new shell session..."
                echo -e "\nExecute: ${GREEN}hobin.sh${NC}"
                # Execute the script in a new shell session
                # exec "$SHELL" -c "source \"$SHELL_CONFIG\" 2>/dev/null; \"$SCRIPT_PATH\""
                $SHELL
                exit 0
            fi
        fi
        echo -e "\nPress Enter to continue..."
        read -r
    fi
}

# URLs for the tools
declare -A TOOLS
TOOLS=(
    ["fzf"]="https://github.com/junegunn/fzf"
    ["bat"]="https://github.com/sharkdp/bat"
    ["btop"]="https://github.com/aristocratos/btop"
    ["yazi"]="https://github.com/sxyazi/yazi"
    ["lazygit"]="https://github.com/jesseduffield/lazygit"
    ["lazydocker"]="https://github.com/jesseduffield/lazydocker"
    ["gum"]="https://github.com/charmbracelet/gum"
    ["gh"]="https://github.com/cli/cli"
    ["neovide"]="https://github.com/neovide/neovide"
)

# Function to get version of an installed binary
get_tool_version() {
    local tool=$1
    if [ -f "$HOBIN_DIR/$tool" ]; then
        local version=""
        case "$tool" in
            "fzf")
                version=$("$HOBIN_DIR/$tool" --version | head -1 | awk '{print $1}')
                ;;
            "bat"|"yazi"|"lazydocker"|"neovide")
                version=$("$HOBIN_DIR/$tool" --version | head -1 | awk '{print $2}')
                ;;
            "btop"|"gum"|"gh")
                version=$("$HOBIN_DIR/$tool" --version | head -1 | awk '{print $3}')
                ;;
            "lazygit")
                version=$("$HOBIN_DIR/$tool" --version | head -1 | tr ',' '\n' | grep "^[[:space:]]*version=" | sed -e 's/^[[:space:]]*version=//' -e 's/[[:space:]]*$//')
                ;;
            *)
                version=$("$HOBIN_DIR/$tool" --version)
                ;;
        esac

        version=$(echo "$version" | sed 's/^v//')
        echo "$version"
    else
        echo ""
    fi
}

# Function to check if a tool is available in PATH or in HOBIN_DIR
is_tool_available() {
    local tool=$1
    if command -v "$tool" &> /dev/null || [ -f "$HOBIN_DIR/$tool" ]; then
        return 0
    fi
    return 1
}

# Function to check if a binary is installed and show its version (with color formatting)
check_installed() {
    local tool=$1
    local version=$(get_tool_version "$tool")

    if [ -n "$version" ]; then
        echo -e "${GREEN}$version${NC}"
    else
        echo -e "${RED}Not installed${NC}"
    fi
}

# Function to get the latest release version
get_latest_version() {
    local tool=$1
    local repo_url=${TOOLS[$tool]}

    # Check if version is cached and not older than 24 hours
    if [ -f "$CACHE_FILE" ]; then
        cached_version=$(grep "^$tool " "$CACHE_FILE" | awk '{print $2}')
        cached_time=$(grep "^$tool " "$CACHE_FILE" | awk '{print $3}')
        current_time=$(date +%s)

        # If we have a cached version and it's less than 24 hours old
        if [ -n "$cached_version" ] && [ -n "$cached_time" ] && [ $((current_time - cached_time)) -lt 86400 ]; then
            echo "$cached_version"
            return 0
        fi
    fi

    # Extract owner and repo from URL
    local owner=$(echo "$repo_url" | sed -E 's|https://github.com/([^/]+)/([^/]+)|\1|')
    local repo=$(echo "$repo_url" | sed -E 's|https://github.com/([^/]+)/([^/]+)|\2|')

    # Fetch only the latest release
    response=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest")

    # Check if we hit API rate limit or no releases found
    if [ "$(echo "$response" | grep -c 'API rate limit exceeded')" -eq 1 ]; then
        # Try to return cached version if available, even if older than 24 hours
        if [ -n "$cached_version" ]; then
            echo "$cached_version"
            return 0
        fi
        echo -e "${RED}API limit${NC}"
        return 1
    fi

    if [ "$(echo "$response" | grep -c 'Not Found')" -eq 1 ]; then
        echo "Not found"
        return 1
    fi

    # Extract the tag name (version) from the latest release
    latest_version=$(echo "$response" | grep -oP '"tag_name": "\K[^"]*' | sed 's/^v//')

    # Cache the version with current timestamp
    if [ -n "$latest_version" ]; then
        # Create new cache file if it doesn't exist
        if [ ! -f "$CACHE_FILE" ]; then
            touch "$CACHE_FILE"
        fi

        # Remove old entry for this tool
        sed -i "/^$tool /d" "$CACHE_FILE"

        # Add new cache entry with timestamp
        echo "$tool $latest_version $(date +%s)" >> "$CACHE_FILE"
    fi
    echo "$latest_version"
    return 0
}

# Define excluded keywords
EXCLUDE_KEYWORDS=("windows" "win32" "exe" "win64" "darwin" "bsd" "macos" "osx" "apple" "sparc" "powerpc" "riscv" "aarch64")

# Function to fetch only the latest release and show options
fetch_releases() {
    local tool=$1
    local repo_url=${TOOLS[$tool]}

    # Extract owner and repo from URL
    local owner=$(echo "$repo_url" | sed -E 's|https://github.com/([^/]+)/([^/]+)|\1|')
    local repo=$(echo "$repo_url" | sed -E 's|https://github.com/([^/]+)/([^/]+)|\2|')

    # Different display based on gum availability
    if is_tool_available "gum"; then
        gum spin --spinner dot --title "Fetching latest release for $tool from $owner/$repo..." -- sleep 1
    else
        echo "Fetching latest release for $tool from $owner/$repo..."
    fi

    # Fetch only the latest release
    response=$(curl -s "https://api.github.com/repos/$owner/$repo/releases/latest")

    # Check if we hit API rate limit or no releases found
    if [ "$(echo "$response" | grep -c 'API rate limit exceeded')" -eq 1 ]; then
        if is_tool_available "gum"; then
            gum style --foreground 9 "GitHub API rate limit exceeded. Try again later."
        else
            echo -e "${RED}GitHub API rate limit exceeded. Try again later.${NC}"
        fi
        return 1
    fi

    if [ "$(echo "$response" | grep -c 'Not Found')" -eq 1 ]; then
        if is_tool_available "gum"; then
            gum style --foreground 9 "No latest release found."
        else
            echo -e "${RED}No latest release found.${NC}"
        fi
        return 1
    fi

    # Extract download URLs from the latest release and filter by file types
    all_releases=$(echo "$response" | grep -oP '"browser_download_url": "\K[^"]*' | grep "$tool" | grep -E '\.(tar\.gz|tar|tgz|tbz|zip)$' | sort -u)

    # Filter out releases with excluded keywords
    releases=""
    while read -r url; do
        exclude=false
        for keyword in "${EXCLUDE_KEYWORDS[@]}"; do
            if echo "$(basename "$url")" | grep -i -q "$keyword"; then
                exclude=true
                break
            fi
        done

        if [ "$exclude" = false ]; then
            releases+="$url"$'\n'
        fi
    done <<< "$all_releases"

    # Remove trailing newline
    releases=$(echo "$releases" | sed '/^$/d')

    # Check if we found any matching releases
    if [ -z "$releases" ]; then
        if is_tool_available "gum"; then
            gum style --foreground 9 "No matching release assets found for $tool."
        else
            echo -e "${RED}No matching release assets found for $tool.${NC}"
        fi
        return 1
    fi

    # Show results - only plain version if gum is not available
    if ! is_tool_available "gum"; then
        echo "Available releases for $tool (latest version):"
        # Only show filename without the path
        echo "$releases" | while read -r url; do
            echo "$(basename "$url")"
        done | nl
    fi

    return 0
}

# Function to download and install a selected release
download_and_install() {
    local tool=$1
    local release_url=$2
    mkdir -p "$CACHE_DIR"
    cd "$CACHE_DIR" || exit

    # Show downloading status with gum if available
    if is_tool_available "gum"; then
        gum style --foreground 6 "Downloading $release_url..."
        # Download with progress spinner
        gum spin --spinner dot --title "Downloading..." -- curl -LO "$release_url"
    else
        echo "Downloading $release_url..."
        curl -LO "$release_url"
    fi

    tarball=$(basename "$release_url")

    # Extract based on file extension
    if is_tool_available "gum"; then
        gum style --foreground 6 "Extracting $tarball..."
    else
        echo "Extracting $tarball..."
    fi

    if [[ "$tarball" == *.tar.gz ]] || [[ "$tarball" == *.tgz ]]; then
        tar xzf "$tarball"
    elif [[ "$tarball" == *.tar ]]; then
        tar xf "$tarball"
    elif [[ "$tarball" == *.tbz ]]; then
        tar xfj "$tarball"
    elif [[ "$tarball" == *.zip ]]; then
        unzip "$tarball"
    else
        if is_tool_available "gum"; then
            gum style --foreground 9 "Unknown archive format: $tarball"
        else
            echo "Unknown archive format: $tarball"
        fi
    fi

    # Search for the binary
    if is_tool_available "gum"; then
        gum style --foreground 6 "Locating binary..."
    else
        echo "Locating binary..."
    fi

    binary=$(find . -type f -executable -name "$tool")
    if [ -n "$binary" ]; then
        mv "$binary" "$HOBIN_DIR/$tool"
        if is_tool_available "gum"; then
            gum style --foreground 2 "$tool installed successfully."
        else
            echo "$tool installed successfully."
        fi
    else
        if is_tool_available "gum"; then
            gum style --foreground 9 "Failed to find the binary for $tool."
            gum style --foreground 3 "Available files:"
        else
            echo "Failed to find the binary for $tool."
            echo "Available files:"
        fi
        find . -type f -executable
    fi

    cd - >/dev/null || exit
    rm -rf "$CACHE_DIR"
}

# Function to remove an installed tool
remove_tool() {
    local tool=$1
    local was_gum_removed=false

    if [ -f "$HOBIN_DIR/$tool" ]; then
        # Check if we're removing gum itself
        if [ "$tool" = "gum" ]; then
            was_gum_removed=true
        fi

        # Show confirmation prompt
        if is_tool_available "gum"; then
            if gum confirm --default="0" "Are you sure you want to remove $tool?"; then
                gum style --foreground 2 "$tool was successfully removed."
                rm "$HOBIN_DIR/$tool"
            else
                gum style --foreground 3 "Removal cancelled."
            fi
        else
            read -rp "Are you sure you want to remove $tool? (y/N): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                rm "$HOBIN_DIR/$tool"
                echo "$tool was successfully removed."
            else
                echo "Removal cancelled."
            fi
        fi

        # If gum was removed, we need to update our internal state
        # to ensure we don't try to use gum functions after it's removed
        if [ "$was_gum_removed" = true ]; then
            # Force the is_tool_available function to recognize gum is now gone
            hash -r
        fi
    else
        if is_tool_available "gum"; then
            gum style --foreground 1 "$tool is not installed."
        else
            echo "$tool is not installed."
        fi
    fi
}

# =============== Main menu ================
check_bin_dir_in_path

while true; do
    clear
    banner

    # Sort tools once
    tools_sorted=($(for tool in "${!TOOLS[@]}"; do echo "$tool"; done | sort))

    # Show the menu table only if gum is not available
    if ! is_tool_available "gum"; then
        # Print header row
        printf "%-3s %-15s %-31s %-11s %-12s\n" "#" "Tool" "Repository" "Installed" "Available"
        printf "%s\n" "-------------------------------------------------------------------------"

        # Display tools in a numbered list with proper formatting
        for i in "${!tools_sorted[@]}"; do
            tool="${tools_sorted[$i]}"

            # Get installed version (reusing our function)
            installed_version=$(get_tool_version "$tool")

            if [ -n "$installed_version" ]; then
                installed="${GREEN}$installed_version${NC}"
            else
                installed="${RED}Not found${NC}"
            fi

            # Get latest version
            latest_version=$(get_latest_version "$tool")

            # Check if installed version is the latest
            if [ -n "$installed_version" ] && [ "$installed_version" = "$latest_version" ]; then
                available="${GREEN}[Updated]${NC}"
            else
                if [ -n "$installed_version" ]; then
                    available="${YELLOW}$latest_version${NC}"
                else
                    available="${GREEN}$latest_version${NC}"
                fi
            fi

            # Format URL with GitHub icon
            repo_url=${TOOLS[$tool]}
            repo_url=${repo_url/https:\/\/github.com\//}

            printf "%-3s %-15s %-34s %-22b %-12b\n" "$((i+1))" "$tool" "/$repo_url" "$installed" "$available"
        done
        echo ""
    fi

    # Get user selection using gum if available
    if is_tool_available "gum"; then
        # gum style --foreground 6 "Choose a tool to manage (use arrow keys and enter):"
        # Prepare table data with tab separators for gum table
        table_data="Tool,Repository,Installed,Available\n"

        # Add data rows
        for i in "${!tools_sorted[@]}"; do
            tool="${tools_sorted[$i]}"
            installed_version=$(get_tool_version "$tool")

            # Determine installation status
            if [ -n "$installed_version" ]; then
                installed="$installed_version"
            else
                installed="Not found"
            fi

            # Get latest version
            latest_version=$(get_latest_version "$tool")

            # Check if installed version is the latest
            if [ -n "$installed_version" ] && [ "$installed_version" = "$latest_version" ]; then
                available="[Updated]"
            else
                available="$latest_version"
            fi

            # Format URL with GitHub icon
            repo_url=${TOOLS[$tool]}
            repo_url=${repo_url/https:\/\/github.com\// }

            table_data+="$tool,$repo_url,$installed,$available\n"
        done

        # Add exit option
        table_data+="EXIT,,,"

        # Display table with gum and get selection
        selected=$(echo -e "$table_data" | gum table --return-column=1 --height 10 --border='rounded' --widths 12,40,10,10 --)

        # Extract choice from the selected row - get only the first field
        choice=$(echo "$selected")

        # Check if choice is valid and the D key was pressed for delete
        if [ -n "$choice" ] && [ "$choice" != "EXIT" ]; then
            read -rsn1 -t 0.1 key
            if [ "$key" = "d" ] || [ "$key" = "D" ]; then
                tool="$choice"
                installed_version=$(get_tool_version "$tool")
                if [ -n "$installed_version" ]; then
                    remove_tool "$tool"
                    continue
                fi
            fi
        fi
    else
        # Fall back to standard input if gum is not available
        read -rp "Enter your choice [1-$((${#tools_sorted[@]}))] or press Enter to exit: " choice
    fi

    # Process user selection
    if [[ -z "$choice" || "$choice" = "0" || "$choice" = "EXIT" ]]; then
        exit 0
    elif [[ "$choice" ]]; then
        if [[ "$choice" -ge 1 && "$choice" -le ${#tools_sorted[@]} ]]; then
            tool="${tools_sorted[$((choice-1))]}"
        else
            tool="$choice"
        fi

        # Display tool info with or without gum
        if is_tool_available "gum"; then
            gum style --foreground 6 "Selected tool: $tool"
            installed_version=$(get_tool_version "$tool")
            if [ -n "$installed_version" ]; then
                gum style --foreground 2 "Current version: $installed_version"

                # Ask if user wants to install or remove
                action=$(gum choose "Install/Update" "Remove" "Cancel")

                if [ "$action" = "Remove" ]; then
                    remove_tool "$tool"
                    continue
                elif [ "$action" = "Cancel" ]; then
                    continue
                fi
            else
                gum style --foreground 1 "Current version: Not installed"
            fi
            echo ""
        else
            echo "Selected tool: $tool"
            echo -e "Current version: $(check_installed "$tool")"

            # If tool is installed, ask if user wants to remove it
            installed_version=$(get_tool_version "$tool")
            if [ -n "$installed_version" ]; then
                echo "Options: [I]nstall/Update, [R]emove, [C]ancel"
                read -rp "Choose an option [I/R/C]: " action

                case "$action" in
                    [Rr])
                        remove_tool "$tool"
                        continue
                        ;;
                    [Cc])
                        continue
                        ;;
                    *)
                        # Default is install/update
                        ;;
                esac
            fi
            echo ""
        fi

        fetch_releases "$tool"

        # Use gum for release selection if available
        if is_tool_available "gum" && [ -n "$releases" ]; then
            # gum style --foreground 6 "Choose a release to download:"
            releases_array=()

            while read -r url; do
                releases_array+=("$(basename "$url")")
            done <<< "$releases"
            releases_array+=("Cancel")

            selected=$(printf "%s\n" "${releases_array[@]}" | gum choose)

            # Handle cancel option
            if [ "$selected" = "Cancel" ]; then
                release_choice=0
            else
                # Find the line number of the selected item
                count=1
                while read -r url; do
                    if [ "$(basename "$url")" = "$selected" ]; then
                        release_choice=$count
                        break
                    fi
                    ((count++))
                done <<< "$releases"
            fi
        else
            read -rp "Enter the number of the release to download (or press Enter/0 to cancel): " release_choice
        fi

        if [[ -z "$release_choice" || "$release_choice" -eq 0 ]]; then
            if is_tool_available "gum"; then
                gum style --foreground 3 "Installation cancelled."
            else
                echo "Installation cancelled."
            fi
        else
            # Get the full URL by line number
            release_url=$(echo "$releases" | sed -n "${release_choice}p")
            download_and_install "$tool" "$release_url"
        fi
    fi
done
