# Generated file, do not edit.

# Simplified Flutter CMake for development builds
# This file provides minimal Flutter integration

# Flutter configuration
set(FLUTTER_EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")

# Set basic variables
set(FLUTTER_LIBRARY "${FLUTTER_EPHEMERAL_DIR}/flutter_windows.dll")
set(FLUTTER_ICU_DATA_FILE "${FLUTTER_EPHEMERAL_DIR}/icudtl.dat")

# Published to parent scope for install step
set(FLUTTER_LIBRARY ${FLUTTER_LIBRARY} PARENT_SCOPE)
set(FLUTTER_ICU_DATA_FILE ${FLUTTER_ICU_DATA_FILE} PARENT_SCOPE)

# Create interface library for Flutter
add_library(flutter INTERFACE)

# Simple wrapper library for compatibility
add_library(flutter_wrapper_app STATIC
  "${FLUTTER_EPHEMERAL_DIR}/cpp_client_wrapper/core_implementations.cc"
  "${FLUTTER_EPHEMERAL_DIR}/cpp_client_wrapper/flutter_engine.cc"
  "${FLUTTER_EPHEMERAL_DIR}/cpp_client_wrapper/flutter_view_controller.cc"
)

apply_standard_settings(flutter_wrapper_app)
target_include_directories(flutter_wrapper_app PUBLIC
  "${FLUTTER_EPHEMERAL_DIR}"
)

# Simplified install function
function(flutter_assemble_install_bundle_data)
  if(EXISTS "${FLUTTER_LIBRARY}")
    install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)
  endif()
  
  if(EXISTS "${FLUTTER_ICU_DATA_FILE}")
    install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)
  endif()
endfunction()
