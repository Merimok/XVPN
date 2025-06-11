#
# Generated file, do not edit.
#

list(APPEND FLUTTER_PLUGIN_LIST
  path_provider_windows
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
)

set(PLUGIN_BUNDLED_LIBRARIES)

# For CI/CD builds, create minimal plugin implementations
foreach(plugin ${FLUTTER_PLUGIN_LIST})
  if(plugin STREQUAL "path_provider_windows")
    # Create minimal path_provider_windows plugin
    add_library(${plugin}_plugin INTERFACE)
    target_include_directories(${plugin}_plugin INTERFACE
      "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral"
    )
  endif()
endforeach(plugin)

foreach(ffi_plugin ${FLUTTER_FFI_PLUGIN_LIST})
  # Handle FFI plugins if needed in the future
endforeach(ffi_plugin)
