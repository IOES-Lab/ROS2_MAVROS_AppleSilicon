#!/bin/bash
################################################################################
########### MAVROS Installation Script for MacOS (Apple Silicon) ###########
################################################################################
# Author: Choi Woen-Sug (GithubID: woensug-choi)
# First Created: 2024.6.18
################################################################################
# Assumes that you have installed ROS2 Jazzy on MacOS (Apple Silicon) using the
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/install.sh)"
#
# Also, need to make this script executable
# chmod +x install.sh
################################################################################
ROS_INSTALL_ROOT_DEFAULT="ros2_jazzy" # you may change with option -r
VIRTUAL_ENV_ROOT_DEFAULT=".ros2_venv" # you may change with option -v
MAVROS_INSTALL_ROOT_DEFAULT='mavros_ws' # you may change with option -d
# ------------------------------------------------------------------------------
# Installation Configuration and Options
# ------------------------------------------------------------------------------

# Usage function
usage() {
    echo "Usage: [-r ROS_INSTALL_ROOT_DEFAULT] [-d MAVROS_INSTALL_ROOT_DEFAULT] [-v VIRTUAL_ENV_ROOT_DEFAULT] [-h]"
    echo "  -r    Set the ROS installation root directory (default: $ROS_INSTALL_ROOT_DEFAULT)"
    echo "  -d    Where to generate workspace for mavros installation (default: $MAVROS_INSTALL_ROOT_DEFAULT)"
    echo "  -v    Set the Python Virtual Environment directory (default: $VIRTUAL_ENV_ROOT_DEFAULT)"
    exit 1
}

# Parse command-line arguments
while getopts "d:r:h:v:a" opt; do
    case ${opt} in
        d)
            MAVROS_INSTALL_ROOT=$OPTARG
            ;;
        r)
            ROS_INSTALL_ROOT=$OPTARG
            ;;
        v)
            VIRTUAL_ENV_ROOT=$OPTARG
            ;;
        h)
            usage
            ;;
        a)
            GITHUB_ACTIONS=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" 1>&2
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Set default values if variables are not set
ROS_INSTALL_ROOT=${ROS_INSTALL_ROOT:-$ROS_INSTALL_ROOT_DEFAULT}
MAVROS_INSTALL_ROOT=${MAVROS_INSTALL_ROOT:-$MAVROS_INSTALL_ROOT_DEFAULT}
VIRTUAL_ENV_ROOT=${VIRTUAL_ENV_ROOT:-$VIRTUAL_ENV_ROOT_DEFAULT}

# Get Current Version hash
LATEST_COMMIT_HASH=$(curl -s "https://github.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/commits/main" | \
        grep -o 'commit/[0-9a-f]*' | \
        head -n 1 | \
        cut -d'/' -f2 | \
        cut -c1-7)

# ------------------------------------------------------------------------------
# Initiation
# ------------------------------------------------------------------------------
# Print welcome message
echo -e "\nRunning Installation script for ROS-Gazebo framework. ROS2 Jazzy first.\033[32m"
echo "▣-------------------------------------------------------------------------▣"
echo "| 👋 Welcome to the Instllation of    MAVROS  on MacOS(Apple Silicon)  🚧 |"
echo "| 🍎 (Apple Silicon)+🤖 = 🚀❤️🤩🎉🥳                                       |"
echo "|                                                                         |"
echo "|  First created at 2024.6.18       by Choi Woen-Sug(Github:woensug-choi) |"
echo "▣-------------------------------------------------------------------------▣"
echo -e "| Current Installer Version Hash : \033[94m$LATEST_COMMIT_HASH\033[0m   \033[32m"
echo -e "\033[32m| Target Installation Directory  :\033[0m" "\033[94m$HOME/$MAVROS_INSTALL_ROOT\033[0m"
echo -e "\033[32m|\033[0m ROS2 Installation Directory    :" "\033[94m$HOME/$ROS_INSTALL_ROOT\033[0m"
echo -e "\033[32m|\033[0m Virtual Environment Directory  :" "\033[94m$HOME/$VIRTUAL_ENV_ROOT\033[0m"
echo -e "\033[32m▣-------------------------------------------------------------------------▣\033[0m"
echo -e "Source code at: "
echo -e "https://github.com/IOES-Lab/ROS2_MAVROS_AppleSilicon/install.sh\n"
echo -e "\033[33m⚠️  WARNING: The FAN WILL BURST out and make macbook to take off. Be warned!\033[0m"
echo -e "\033[33m         To terminate at any process, press Ctrl+C.\033[0m"

# If running in a GitHub Actions workflow, run pre-script first
if [[ -n "$GITHUB_ACTIONS" ]]; then
    echo -e "\033[36m> Running pre-installation script for GitHub Actions workflow...\033[0m"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/IOES-Lab/ROS2_Jazzy_MacOS_Native_AppleSilicon/main/install.sh)" -- -a
fi

# Trap SIGINT (Ctrl+C) and exit cleanly
trap 'echo -e "\033[31m\nInstallation aborted.\033[0m"; exit' SIGINT

# Check if the script is running in a GitHub Actions workflow
if [[ -z "$GITHUB_ACTIONS" ]]; then
    # Prompt the user and wait for a response with a timeout of 10 seconds
    echo -e '\033[96m\n💡 The installation will continue automatically in 10 seconds unless you respond. \033[0m'
    read -p $'\033[96m   Do you want to proceed now? [y/n]: \033[0m' -n 1 -r -t 10 response
    echo # Move to a new line after the user input

    # Default to 'y' if no response is given within the timeout
    response=${response:-y}
else
    # Automatically set the response to 'y' in a GitHub Actions workflow
    response='y'
fi

# Check the response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "\033[31m\nInstallation aborted.\033[0m"
    exit 1
fi

# ------------------------------------------------------------------------------
# Check System
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [1/6] Checking System Requirements\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
echo -e "Checking System Requirements..."
# Check XCode installation"
if [ ! -e "/Applications/Xcode.app/Contents/Developer" ]; then
    echo -e "\033[31m❌ Error: Xcode is not installed. Please install Xcode through the App Store."
    echo -e "\033[31m       You can download it from: https://apps.apple.com/app/xcode/id497799835\033[0m"
    exit 1
else
    echo -e "\033[36m> Xcode installation confirmed\033[0m"
fi

# Check if the Xcode path is correct
if [ "$(xcode-select -p)" != "/Applications/Xcode.app/Contents/Developer" ]; then
    echo -e "\033[34m>Changing the Xcode path...\033[0m"
    sudo xcode-select -s "/Applications/Xcode.app/Contents/Developer"
    XCODE_VERSION=$(xcodebuild -version | grep '^Xcode\s' | sed -E 's/^Xcode[[:space:]]+([0-9\.]+)/\1/')
    ACCEPTED_LICENSE_VERSION=$(defaults read /Library/Preferences/com.apple.dt.Xcode 2> /dev/null | grep IDEXcodeVersionForAgreedToGMLicense | cut -d '"' -f 2)
    # Check if the Xcode license has been accepted
    if [ "$XCODE_VERSION" != "$ACCEPTED_LICENSE_VERSION" ]; then
        echo -e "\033[33m⚠️ WARNING: Xcode license needs to be accepted. Please follow the prompts to accept the license.\033[0m"
        sudo xcodebuild -license
        # shellcheck disable=SC2181
        if [ $? -ne 0 ]; then
            echo -e "\033[31m❌ Error: Failed to accept Xcode license. Please try again.\033[0m"
            exit 1
        fi
    fi
fi

# Check Brew installation
which brew > /dev/null
# shellcheck disable=SC2181
if [ $? -ne 0 ]; then
    echo -e "\033[36mBrew installation not found! Installing brew... (it could take some time.. wait!\033[0m"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    # shellcheck disable=SC2143
    if [[ $(brew config | grep "Rosetta 2: false") && $(brew --prefix) == "/opt/homebrew" ]]; then
        echo -e "\033[36m> Brew installation confirmed (/opt/homebrew, Rosseta 2: false)\033[0m"
    else
        echo -e "\033[33m> Incorrect Brew configuration detected at /usr/local. This seems to be a Rosetta 2 emulation.\033[0m"
        echo -e "\033[33m> 💡 Do you want to remove it and reinstall the native arm64 Brew? (y/n)\033[0m"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo -e "\033[36mRemoving the Rosetta 2 emulated Brew at /usr/local...\033[0m"
            curl -fsSLO https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh
            /bin/bash uninstall.sh --path /usr/local
            echo -e "\033[36mReinstalling the native arm64 Brew...(it could take some time.. wait!)\033[0m"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            echo -e "\033[31m> Aborting. Please manually correct your Brew configuration.\033[0m"
            exit 1
        fi
    fi
fi

# Check Brew shellenv configuration
# shellcheck disable=SC2016
if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile; then
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Check if Installation dir already exists and warn user
echo -e "\033[34m> Check Installation Directory\033[0m"
if [ -d "$HOME/$MAVROS_INSTALL_ROOT" ]; then
    echo -e "\033[33m⚠️ WARNING: The directory $MAVROS_INSTALL_ROOT already exists at home ($HOME)."
    echo -e "\033[33m         This script will merge and overwrite the existing directory.\033[0m"
    echo -e "\033[96mDo you want to continue? [y/n/r/c]\033[0m"
    read -p "(y) Merge (n) Cancel (r) Change directory, (c) Clean re-install: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\033[33mMerging and overwriting existing directory...\033[0m"
    elif [[ $REPLY =~ ^[Rr]$ ]]; then
        # shellcheck disable=SC2162
        read -p "Enter a new directory name (which will be generated at home): " ROS_INSTALL_ROOT
        if [ -d "$HOME/$MAVROS_INSTALL_ROOT" ]; then
            echo -e "\033[31m❌ Error: $HOME/$MAVROS_INSTALL_ROOT already exists. Please choose a different directory.\033[0m"
            exit 1
        fi
    elif [[ $REPLY =~ ^[Cc]$ ]]; then
        echo -e "\033[33mPerforming clean reinstall...\033[0m"
        # shellcheck disable=SC2115
        rm -rf "$HOME/$MAVROS_INSTALL_ROOT"
    else
        echo -e "\033[31mInstallation aborted.\033[0m"
        exit 1
    fi
fi

# Generate Directory
echo -e "\033[36m> Creating directory $HOME/$MAVROS_INSTALL_ROOT...\033[0m"
mkdir -p "$HOME/$MAVROS_INSTALL_ROOT"/src
chown -R "$USER": "$HOME/$MAVROS_INSTALL_ROOT" > /dev/null 2>&1

# Move to working directory
pushd "$HOME/$MAVROS_INSTALL_ROOT" || { 
    echo -e "\033[31m❌ Error: Failed to change to directory $HOME/$MAVROS_INSTALL_ROOT. \
    Please check if the directory exists and you have the necessary permissions.\033[0m"
    exit 1
}

# ------------------------------------------------------------------------------
# Install Dendencies
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [2/6] Installing Dependencies with Brew and PIP\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
# Installing dependencies with brew
echo -e "\033[36m> Installing dependencies with Brew...\033[0m"
brew install yaml-cpp

# Confirm message
echo -e "\033[36m\n> Packages installation with Brew completed.\033[0m"


# Install Python3.11 dependencies with pip
echo -e "\033[36m> Installing Python3.11 dependencies with PIP in virtual environment...\033[0m"
# Check Python3.11 installation
if ! python3.11 --version > /dev/null 2>&1; then
    echo -e "\033[31m❌ Error: Python3.11 installation failed. Please check the installation.\033[0m"
    exit 1
fi

# Activate Python3.11 virtual environment
# shellcheck disable=SC1091,SC1090
source "$HOME/$VIRTUAL_ENV_ROOT/bin/activate"
# shellcheck disable=SC1091,SC1090
source "$HOME/$ROS_INSTALL_ROOT/install/setup.bash"

# Install dependencies
python3 -m pip install --upgrade pip
python3 -m pip install -U future pyproj

# Confirm message
echo -e "\033[36m> Packages installation with PIP completed.\033[0m"

# Install GeographicLib
echo -e "\033[36m> Installing GeographicLib...\033[0m"
wget https://github.com/ObjSal/GeographicLib/archive/refs/tags/v1.44.tar.gz
tar xfpz v1.44.tar.gz && rm v1.44.tar.gz
if [ -d "GeographicLib" ]; then
    rm -rf GeographicLib
fi
mv GeographicLib-1.44 GeographicLib
cd GeographicLib || exit

# Build GeographicLib
mkdir -p BUILD && cd BUILD || exit
../configure
make && make install

# Download GeographicLib Datasets
echo -e "\033[36m> Downloading GeographicLib datasets...\033[0m"
geographiclib-get-geoids egm96-5
geographiclib-get-gravity egm96
geographiclib-get-magnetic emm2015

# Set Environment Variables
echo -e "\033[36m> Setting Environment Variables of Brew packages...(OPENSSL_ROOT_DIR, CMAKE_PREFIX_PATH, PATH)\033[0m"
export GEOGRAPHICLIB_GEOID_PATH=/usr/local/share/GeographicLib
export CMAKE_MODULE_PATH=/usr/local/share/cmake/GeographicLib:$CMAKE_MODULE_PATH
# Disable notification error on mac
export COLCON_EXTENSION_BLOCKLIST=colcon_core.event_handler.desktop_notification

# ------------------------------------------------------------------------------
# Downloading MAVROS Source Code
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [3/6] Downloading MAVROS Source Code\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
# Reset git directories (git clean -d -f .) if they exist inside src directory
if [ -d "src" ]; then
    echo -e "\033[36m> Resetting git directories inside src...\033[0m"
    find src -name ".git" -type d -execdir bash -c 'if [ -d ".git" ]; then git clean -d -f .; fi' \;
fi

# Get Source Code
echo -e "As long as the spinner at of the terminal is running, it is downloading the source code. It does take long."
echo -e "If you see 'E' in the progress, it means the download failed (slow connection does this), it will try again."
echo -e "If it takes too long, please check your network connection and try again. To cancel, Ctrl+C."

# Define maximum number of retries
max_retries=3
# Start loop
for ((i=1;i<=max_retries;i++)); do
    # Try to import the repositories
    cd "$HOME/$MAVROS_INSTALL_ROOT" || exit
    if vcs import --force --shallow --retry 0 \
        --input https://raw.githubusercontent.com/IOES-Lab/ROS2_MAVROS_AppleSilicon/main/repos.yaml src;
        then
        echo -e "\033[36m\n> Source Code Import Successful\033[0m"
        break
    else
        echo -e "\033[31m\nSource Code Import failed, retrying ($i/$max_retries)\033[0m"
    fi
    # If we've reached the max number of retries, exit the script
    if [ $i -eq $max_retries ]; then
        echo -e "\033[31m\Source Code Import failed after $max_retries attempts, terminating script.\033[0m"
        exit 1
    fi
    # Wait before retrying
    sleep 5
done

echo -e "\033[36m> Git clone matek_imu test package...\033[0m"
git clone https://github.com/IOES-Lab/ROS2_MAVROS_AppleSilicon.git src/matek_imu

# Compile once to generate structure to apply patch (for libmavconn edian)
echo -e "\033[36m> Compiling to generate structure to apply patch...\033[0m"
python3.11 -m colcon build --symlink-install --cmake-args \
  -DPython3_EXECUTABLE="$HOME/$VIRTUAL_ENV_ROOT/bin/python3" \
  -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
  -DCMAKE_MODULE_PATH=/usr/local/share/cmake/GeographicLib:"$CMAKE_MODULE_PATH" \
  -Wno-dev \
  --no-warn-unused-cli \
  -DBUILD_TESTING=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  --cmake-force-configure --packages-up-to mavlink

# ------------------------------------------------------------------------------
# Patch files for Mac OS X Installation
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [4/6] Patching files for Mac OS X (Apple Silicon) Installation\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
# Patch for mavros
echo -e "\033[36m> Applying patch for mavros...\033[0m"
cd src/mavros || exit
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_MAVROS_AppleSilicon/main/mavros.patch \
  | patch -p1 -Ns
cd "$HOME/$MAVROS_INSTALL_ROOT" || exit

# Patch for mavlink
echo -e "\033[36m> Applying patch for mavlink...\033[0m"
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_MAVROS_AppleSilicon/main/install_mavlink.patch \
  | patch -p1 -Ns
curl -sSL \
  https://raw.githubusercontent.com/IOES-Lab/ROS2_MAVROS_AppleSilicon/main/mavlink_generator.patch \
  | patch -p1 -Ns

# Fix brew linking of qt5
echo -e "\033[36m> Fixing brew linking of qt5...\033[0m"
brew unlink qt && brew link qt@5

# ------------------------------------------------------------------------------
# Building
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [5/6] Building (This may take about 15 minutes)\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
if ! python3.11 -m colcon build --symlink-install --cmake-args \
        -DPython3_EXECUTABLE="$HOME/$VIRTUAL_ENV_ROOT/bin/python3" \
        -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
        -DCMAKE_MODULE_PATH=/usr/local/share/cmake/GeographicLib:"$CMAKE_MODULE_PATH" \
        -Wno-dev \
        --no-warn-unused-cli \
        -DBUILD_TESTING=OFF \
        -DCMAKE_BUILD_TYPE=Release \
        --cmake-force-configure;
    then
    echo -e "\033[31m❌ Error: Build failed, aborting script.\033[0m"
    exit 1
fi

# ------------------------------------------------------------------------------
# Post Installation Configuration
printf '\n\n\033[34m'; printf '=%.0s' {1..75}; printf '\033[0m\n'
echo -e "\033[34m### [6/6] Post Installation Configuration\033[0m"
printf '\033[34m%.0s=\033[0m' {1..75} && echo
# ------------------------------------------------------------------------------
# save GZ_INSTALL_ROOT in a file
if [ -f "$HOME/.ros2_jazzy_install_config" ]; then
    echo "MAVROS_INSTALL_ROOT=$MAVROS_INSTALL_ROOT" >> "$HOME/.ros2_jazzy_install_config"
fi

# Download sentenv.sh
if [ -f setenv.sh ]; then
    rm setenv.sh
fi
if [ -f setenv_gz.sh ]; then
    rm setenv_gz.sh
fi
if [ -f setenv_gz.sh ]; then
    rm setenv_mavros.sh
fi
curl -s -O https://raw.githubusercontent.com/IOES-Lab/ROS2_MAVROS_AppleSilicon/main/setenv_mavros.sh

# Replace string inside sentenv.sh
sed -i '' "s|ROS_INSTALL_ROOT|$ROS_INSTALL_ROOT|g" setenv_mavros.sh
sed -i '' "s|VIRTUAL_ENV_ROOT|$VIRTUAL_ENV_ROOT|g" setenv_mavros.sh
sed -i '' "s|GZ_INSTALL_ROOT|$GZ_INSTALL_ROOT|g" setenv_mavros.sh
sed -i '' "s|MAVROS_INSTALL_ROOT|$MAVROS_INSTALL_ROOT|g" setenv_mavros.sh

# Rename sentenv.sh to activate_ros
if [ -f "$HOME/$ROS_INSTALL_ROOT/activate_ros" ]; then
    rm "$HOME/$ROS_INSTALL_ROOT/activate_ros"
fi
mv setenv_mavros.sh "$HOME/$ROS_INSTALL_ROOT/activate_ros"

# Print post messages
printf '\033[32m%.0s=\033[0m' {1..75} && echo
echo -e "\033[32m🎉 Done. Hurray! 🍎 (Apple Silicon) + 🤖 = 🚀❤️🤩🎉🥳 \033[0m"
echo
echo "To activate the new ROS2 Jazzy - Gazebo Harmonic framework, run the following command:"
echo -e "\033[32msource $HOME/$VIRTUAL_ENV_ROOT/activate_ros\033[0m"
echo -e "\nThen, try '\033[32mros2\033[0m' or '\033[32mrviz2\033[0m' in the terminal to start ROS2 Jazzy."
echo -e "\nTo test gazebo, \033[31mrun following commands separately in two termianls (one for server(-s) and one for gui(-g))"
echo -e "(IMPORTANT, both terminals should have \033[0msource $HOME/$VIRTUAL_ENV_ROOT/activate_ros\033[31m activated)\033[0m"
echo -e '\033[32m gz sim shapes.sdf -s \033[0m'
echo -e '\033[32m gz sim -g \033[0m'
printf '\033[32m%.0s=\033[0m' {1..75} && echo

# For mavros
echo -e "\n\033[32mTo test MAVROS, first connect Matek with ardupilot installed on machine\033[0m"
echo -e "\033[32mThen, run the following command in a new terminal (with \033[0msource $HOME/$VIRTUAL_ENV_ROOT/activate_ros\033[32m activated)\033[0m"
echo -e "\033[32mros2 launch matek_imu matek_imu.launch\033[0m"
echo -e "\033[32mThen, on run following command on next terminal to read imu sensor data.\033[0m"
echo -e "\033[32mros2 topic echo /imu/data\033[0m"

echo "To make alias for fast start, run the following command to add to ~/.zprofile:"
echo -e "\033[34mecho 'alias ros=\"source $HOME/$ROS_INSTALL_ROOT/activate_ros\"' >> ~/.zprofile && source ~/.zprofile\033[0m"
echo
echo -e "Then, you can start ROS2 Jazzy - Gazebo Harmonic framework by typing '\033[34mros\033[0m' in the terminal (new terminal)."
echo -e "You may change the alias name to your preference in above alias command."
echo
echo "To deactivate this workspace, run:"
echo -e "\033[33mdeactivate\n\n\033[0m"

popd || exit