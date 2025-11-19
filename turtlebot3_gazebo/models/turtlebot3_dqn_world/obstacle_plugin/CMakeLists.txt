################################################################################
# CMake
################################################################################
cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

################################################################################
# Packages
################################################################################
find_package(gazebo REQUIRED)
find_package(Protobuf REQUIRED)

################################################################################
# Build
################################################################################
link_directories(${GAZEBO_LIBRARY_DIRS})

include_directories(${GAZEBO_INCLUDE_DIRS})
include_directories(${PROTOBUF_INCLUDE_DIRS})

list(APPEND CMAKE_CXX_FLAGS "${GAZEBO_CXX_FLAGS}")

# Add compiler flag to use older protobuf API for compatibility
add_definitions(-DPROTOBUF_USE_DLLS)

add_library(obstacle1 SHARED obstacle1.cc)
target_link_libraries(obstacle1 ${GAZEBO_LIBRARIES} ${PROTOBUF_LIBRARIES})

add_library(obstacle2 SHARED obstacle2.cc)
target_link_libraries(obstacle2 ${GAZEBO_LIBRARIES} ${PROTOBUF_LIBRARIES})

add_library(obstacles SHARED obstacles.cc)
target_link_libraries(obstacles ${GAZEBO_LIBRARIES} ${PROTOBUF_LIBRARIES})
