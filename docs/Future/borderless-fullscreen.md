# Borderless fullscreen

[Back to Future patches](README.md)

Window behavior was inconsistent in my DXVK setup, especially when switching between the embedded game window and fullscreen.

Previously, Cxbx offered exclusive fullscreen and a separate keyboard-toggleable "faux fullscreen" mode. The latter changed the window style, detached the game window from the launcher, made it topmost and maximized it. It did not explicitly fit the window to the monitor bounds, and its embedded-window path mistakenly reapplied the original child style instead of the intended popup style.

Video Configuration now offers **Windowed**, **Borderless fullscreen** and **Exclusive fullscreen**, with the selection saved between launches. Borderless explicitly fills the current monitor while keeping Direct3D windowed, without changing the desktop display mode or forcing the game above other applications. **Alt+Enter** or **F10** switches between windowed and borderless; **Escape** returns borderless to windowed.

Windowed sizing and DPI handling were also corrected so the game follows the launcher's client area and returns to the right size after leaving borderless. These changes concern host-window handling and video settings; Xbox emulation logic and game timing were not changed.

The Release build passed. JSRF startup at 1920x1080 and a windowed–borderless–windowed round trip were checked with DXVK 3.1.1. Other monitor/DPI combinations, exclusive fullscreen and Wine/CrossOver still need checking.
