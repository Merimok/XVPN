// Flutter Windows API Export Header
// This is a minimal header for build compatibility

#ifndef FLUTTER_EXPORT_H_
#define FLUTTER_EXPORT_H_

#if defined(FLUTTER_PLUGIN_IMPL)
#define FLUTTER_EXPORT __declspec(dllexport)
#else
#define FLUTTER_EXPORT __declspec(dllimport)
#endif

#endif  // FLUTTER_EXPORT_H_
