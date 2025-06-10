#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here is arbitrary since we maintain a 1:1 mapping between Dart
  // logical coordinates and ICU physical coordinates.
  const auto size = frame.right - frame.left;
  const auto height = frame.bottom - frame.top;

  // Ensure that we have a valid size.
  if (size <= 0 || height <= 0) {
    return false;
  }

  view_controller_ = std::make_unique<flutter::FlutterViewController>(
      size, height, project_);
  // Ensure that basic setup of the controller was successful.
  if (!view_controller_->engine() || !view_controller_->view()) {
    return false;
  }
  RegisterPlugins(view_controller_->engine());
  SetChildContent(view_controller_->view()->GetNativeWindow());

  flutter::MethodChannel<flutter::EncodableValue> window_channel(
      view_controller_->engine()->messenger(), "flutter/window",
      &flutter::StandardMethodCodec::GetInstance());
  window_channel.SetMethodCallHandler(
      [=](const flutter::MethodCall<flutter::EncodableValue>& call,
          std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
              result) {
        // Add window-related method handlers here if needed
        result->NotImplemented();
      });

  return true;
}

void FlutterWindow::OnDestroy() {
  if (view_controller_) {
    view_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (view_controller_) {
    std::optional<LRESULT> result =
        view_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                   lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      view_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
