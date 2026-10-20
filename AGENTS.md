# Contributor instructions

This repository is a portable QML component library and demo workspace.
Read README.md, docs/Architecture.md and docs/Components.md before editing.

- Canonical components live in shared/qml. Demos consume them through demo/Kos/Ui
  source mappings. Do not create separate visual implementations for the Gallery.
- Keep components free of Quickshell, KWin, Wayland protocols and NextKde services.
  Quickshell is allowed only in the demo host for windows and reading example source.
- Do not confuse in-window texture sampling with access to the desktop. Do not add
  native blur requests or wallpaper replicas as an implicit desktop backdrop.
- Keep business logic, persistence and service calls in application adapters.
- Preserve host-owned state and existing public signals when changing controls.
- Register new types in source qmldir files, the demo facade and shared/qml/CMakeLists.txt.
  Commit GLSL and its matching QSB assets together. Bake shaders only in a VM or CI.
- Do not launch demos, compile, run tests or perform graphical verification on the
  maintainer workstation. Execute these only when explicitly requested, in a VM or
  hosted CI. Source review, edits and Git operations on the workstation are allowed.
- Do not add automatic verification workflows without a request. Do not describe an
  extraction or source review as successful runtime acceptance.
- English is the default. Update Chinese companions with maintained documentation.
  Keep docs operational for AI/app contributors; keep captures, logs and temporary
  reports out of tracked docs. Preserve LICENSE and extraction provenance.
- Preserve unrelated edits. Stage explicit paths. Do not merge or publish releases
  without maintainer authorization.
