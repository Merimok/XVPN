# Generated file, do not edit.

# Minimal Flutter CMake configuration for CI/CD compatibility
cmake_minimum_required(VERSION 3.15)
project(flutter_wrapper LANGUAGES CXX)

# Flutter library and tool build rules.
set(FLUTTER_ROOT "C:\\flutter" CACHE STRING "Flutter SDK root directory")
set(FLUTTER_EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Published to parent scope for install step.
set(FLUTTER_LIBRARY "${FLUTTER_EPHEMERAL_DIR}/flutter_windows.dll" PARENT_SCOPE)
set(FLUTTER_ICU_DATA_FILE "${FLUTTER_EPHEMERAL_DIR}/icudtl.dat" PARENT_SCOPE)

# Create Flutter interface library
add_library(flutter INTERFACE)

# Create flutter_assemble target
add_custom_target(flutter_assemble
  COMMENT "Flutter assemble step for Windows build"
)

# Simple install function for CI/CD
function(flutter_assemble_install_bundle_data)
  # Install Flutter runtime if it exists
  if(EXISTS "${FLUTTER_EPHEMERAL_DIR}/flutter_windows.dll")
    install(FILES "${FLUTTER_EPHEMERAL_DIR}/flutter_windows.dll"
      DESTINATION "." COMPONENT Runtime)
  endif()
  
  # Install ICU data if it exists
  if(EXISTS "${FLUTTER_EPHEMERAL_DIR}/icudtl.dat")
    install(FILES "${FLUTTER_EPHEMERAL_DIR}/icudtl.dat"
      DESTINATION "." COMPONENT Runtime)
  endif()
  
  # Install Flutter assets if they exist
  if(EXISTS "${FLUTTER_EPHEMERAL_DIR}/flutter_assets")
    install(DIRECTORY "${FLUTTER_EPHEMERAL_DIR}/flutter_assets"
      DESTINATION "." COMPONENT Runtime)
  endif()
endfunction()
