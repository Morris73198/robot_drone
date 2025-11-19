#!/bin/bash
#
# Fix for Protobuf Version Incompatibility with Gazebo 11 and Ignition Msgs 5
#
# Issue: 'struct google::protobuf::internal::ArenaStringPtr' has no member named 'SetNoArena'
# Cause: Version mismatch between protobuf and ignition-msgs5
#
# This script provides the proper fix for the compilation errors in turtlebot3_gazebo
# obstacle plugins due to protobuf API incompatibility.

set -e

echo "========================================================================"
echo "Protobuf Compatibility Fix for Gazebo 11 / Ignition Msgs 5"
echo "========================================================================"
echo ""
echo "This will reinstall ignition-msgs packages to match your protobuf version."
echo "You may need to enter your password for sudo commands."
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Step 1: Checking for conflicting protobuf installations..."
echo "----------------------------------------"

# Check for multiple protobuf installations
if [ -f "/usr/local/bin/protoc" ]; then
    echo "WARNING: Found custom protobuf installation in /usr/local/"
    echo "This may conflict with system packages."
    read -p "Remove custom protobuf installations? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing custom protobuf installations..."
        sudo rm -rf /usr/local/bin/protoc /usr/local/include/google /usr/local/lib/libproto*
    fi
fi

echo ""
echo "Step 2: Reinstalling system protobuf and ignition-msgs packages..."
echo "----------------------------------------"

# Reinstall libprotobuf-dev and ignition-msgs packages
sudo apt update
sudo apt reinstall -y libprotobuf-dev
sudo apt reinstall -y libignition-msgs5-dev || sudo apt install -y libignition-msgs5-dev

echo ""
echo "Step 3: Verifying installation..."
echo "----------------------------------------"

if dpkg -l | grep -q libignition-msgs5-dev; then
    echo "✓ libignition-msgs5-dev is installed"
else
    echo "✗ libignition-msgs5-dev is NOT installed"
    echo "  Trying alternative installation method..."
    sudo apt install -y ignition-msgs5
fi

echo ""
echo "Step 4: Re-enabling obstacle plugins in CMakeLists.txt..."
echo "----------------------------------------"

# Restore the obstacle plugin builds in CMakeLists.txt
CMAKELISTS="/home/user/robot_drone/turtlebot3_gazebo/CMakeLists.txt"

if grep -q "# Temporarily disabled due to protobuf" "$CMAKELISTS"; then
    echo "Uncommenting obstacle plugin builds..."

    # Create a backup
    cp "$CMAKELISTS" "${CMAKELISTS}.backup"

    # Uncomment the obstacle plugin lines
    sed -i '/# Temporarily disabled due to protobuf/,+6d' "$CMAKELISTS"

    # Add back the original lines
    sed -i '/add_executable(${EXEC_NAME} src\/turtlebot3_drive.cpp)/a\
\
add_library(obstacle1 SHARED models/turtlebot3_dqn_world/obstacle_plugin/obstacle1.cc)\
target_link_libraries(obstacle1 ${GAZEBO_LIBRARIES})\
\
add_library(obstacle2 SHARED models/turtlebot3_dqn_world/obstacle_plugin/obstacle2.cc)\
target_link_libraries(obstacle2 ${GAZEBO_LIBRARIES})\
\
add_library(obstacles SHARED models/turtlebot3_dqn_world/obstacle_plugin/obstacles.cc)\
target_link_libraries(obstacles ${GAZEBO_LIBRARIES})' "$CMAKELISTS"

    echo "✓ Obstacle plugins re-enabled"
else
    echo "✓ Obstacle plugins already enabled"
fi

echo ""
echo "========================================================================"
echo "Fix Complete!"
echo "========================================================================"
echo ""
echo "Now you can rebuild your workspace:"
echo "  cd ~/multiRobotExploration"
echo "  colcon build --packages-select turtlebot3_gazebo"
echo ""
echo "If you still encounter errors, you may need to:"
echo "  1. Clean your build: rm -rf build/ install/ log/"
echo "  2. Rebuild all packages: colcon build"
echo ""
