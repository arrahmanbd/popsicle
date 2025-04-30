
## 1.0.0-rc.1

### 🧪 Release Candidate – Finalizing API for 1.0.0

- 🧩 **New Core State: `PopsicleState<T>`**
  - Lightweight reactive state class added for simplified state management.
  - Offers a minimal API while integrating with the existing reactive ecosystem.

- 🚀 **Dependency Bootstrap Enhancement**
  - Refactored and improved DI bootstrap logic to support more modular and testable setups.


> ⚠️ This is a **release candidate** for 1.0.0. While the API is considered feature-complete, minor refinements and naming adjustments may still occur before final release.


## 0.1.1-beta 

### 🎉 Beta Release Highlights
- 🧠 **Middleware Revamp**
  - Introduced type-safe `MiddlewareContext<T>` and `MiddlewarePipeline<T>` to support chained middleware with contextual awareness (`oldValue`, `newValue`, `key`, `scope`).

- ⚙️ **Modular & Scalable Dependency Injection**
- 💥 **Declarative State Access**
  - Introduced `ReactiveProvider.get<T>()` for easy and declarative access to state.

- 🧩 **Clean Architecture Improvements**
  - Refactored internals to better support separation of concerns and composability.
  - Reduced boilerplate and improved clarity in the state registration lifecycle.

- 🧪 **Enhanced Testability**
  - State and DI system now fully testable in isolation.
  - Easier to mock, override, and inject test-specific dependencies or states.

- 📦 **Scalability Enhancements**
  - Popsicle is now ready for large-scale applications with a robust foundation for reactive state and modular DI.

---

> Note: This is a **beta release**, APIs may change slightly before the stable 1.0.0. Feedback is welcome!
## 0.0.2-alpha

### ✨ Initial Release

**🔁 Popsicle State Management**
- ✅ `ReactiveState`, `AsyncState`, and `StreamState` for fully reactive and composable state handling
- ✅ Lifecycle-aware state observers with automatic disposal
- ✅ Middleware support to intercept or transform state changes

**📦 Built-in Dependency Injection**
- ✅ Zero-boilerplate DI with centralized configuration via `AppDI` class
- ✅ No global variables required — clean and testable setup
- ✅ Context-free access using `inject<T>()`
- ✅ `context.get<T>()` extension for widget-based DI

**🛠️ Architecture**
- ✅ Designed for both small and large-scale applications
- ✅ Works in Flutter apps and Dart CLI projects

**🌱 Ideal for**
- Developers looking for a lightweight yet powerful state management and DI solution with minimal setup.
