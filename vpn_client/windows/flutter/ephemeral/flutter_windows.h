// Flutter Windows API Header
// This is a minimal header for build compatibility

#ifndef FLUTTER_WINDOWS_H_
#define FLUTTER_WINDOWS_H_

#include "flutter_export.h"

#ifdef __cplusplus
extern "C" {
#endif

// Flutter Engine Handle
typedef struct FlutterEngine* FlutterEngineRef;

// Minimal Flutter API declarations
FLUTTER_EXPORT FlutterEngineRef FlutterEngineCreate();
FLUTTER_EXPORT void FlutterEngineDestroy(FlutterEngineRef engine);

#ifdef __cplusplus
}
#endif

#endif  // FLUTTER_WINDOWS_H_
