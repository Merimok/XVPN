#
# Generated file, do not edit.
#

list(APPEND FLUTTER_PLUGIN_LIST
  path_provider_windows
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
)

set(PLUGIN_BUNDLED_LIBRARIES)

# Simplified plugin handling for development environment
# In a real build, Flutter tool would create proper plugin symlinks
foreach(plugin ${FLUTTER_PLUGIN_LIST})
  # Skip plugin linking in development mode
  # Real Flutter build will handle this properly
endforeach(plugin)

foreach(ffi_plugin ${FLUTTER_FFI_PLUGIN_LIST})
  # Skip FFI plugin linking in development mode
  # Real Flutter build will handle this properly
endforeach(ffi_plugin)
