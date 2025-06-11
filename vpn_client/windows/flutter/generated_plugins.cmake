#
# Generated file for plugin configuration
#

set(FLUTTER_PLUGIN_LIST
  path_provider_windows
)

set(FLUTTER_FFI_PLUGIN_LIST
)

set(PLUGIN_BUNDLED_LIBRARIES)

# Create interface libraries for plugins
foreach(plugin ${FLUTTER_PLUGIN_LIST})
  add_library(${plugin}_plugin INTERFACE)
  target_include_directories(${plugin}_plugin INTERFACE 
    "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")
endforeach()

# Plugin targets  
set(path_provider_windows_bundled_libraries "" PARENT_SCOPE)
