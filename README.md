# smooth_list_view

A Flutter widget that creates a high-performance, interactive list where items follow the user's touch with a smooth, organic lag effect. It features built-in virtualization to handle large lists efficiently by only rendering visible items.

---

## Features

*   **Interactive Fluid Motion**: Items react to touch position with a dynamic delay based on distance.
*   **Efficient Virtualization**: Uses an optimized stack to render only items within the viewport.
*   **Directional Support**: Works seamlessly in both `Axis.vertical` and `Axis.horizontal`.
*   **Customizable Physics**: Control the "laziness" of the animation using the `delayFactor`.
*   **Lightweight**: Built using core Flutter widgets like `AnimatedPositioned` and `GestureDetector`.

---

## Getting started

Add to your `pubspec.yaml`:
```yaml
dependencies:
  smooth_list_view: ^1.0.0