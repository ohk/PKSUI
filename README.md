# PKSUI (Work in Progress)

PKSUI is a SwiftUI library that provides a set of customizable components and utilities for building iOS, macOS, tvOS, and watchOS applications. Its goal is to give developers ready-made UI elements that can be easily integrated and extended within any SwiftUI project.

## Table of Contents

1. [Overview](#overview)
2. [Roadmap](#roadmap)
3. [Components](#components)
   - [PKSTextField](#pkstextfield-component)
   - [PKSButton (planned)](#pksbutton-planned)
   - [PKSCard (planned)](#pkscard-planned)
4. [Contributing](#contributing)
5. [Code of Conduct](#code-of-conduct)
6. [License](#license)

---

## Overview

**PKSUI** aims to:

- Provide commonly-used UI components with minimal boilerplate.
- Support SwiftUI’s native look and feel, while enhancing it with advanced features.
- Offer customizable themes and appearance settings to fit various app designs.
- Be extensible and open to community contributions.

> **Supported Platforms**: iOS 15+, macOS 12+, tvOS 15+, watchOS 8+, visionOS 1+

## Roadmap

- [x] Add a **README.md** file to the project.
- [x] Add a **LICENSE** file to the project.
- [x] Add a **CHANGELOG.md** file to the project.
- [x] Add a **CONTRIBUTING.md** file to the project.
- [x] Add a **CODE_OF_CONDUCT.md** file to the project.
- [ ] **Add PKSTextField Component to the library.**
- [ ] More Components Coming Soon...

---

## Components

### PKSTextField Component

#### Features

- **Floating Label**: Uses SwiftUI’s TextField initializers and extends them to optionally include a floating label.
- **Start Content and End Content**: Add icons or supplementary views (such as a leading icon or trailing icon).
- **Default Animation**: Provides a subtle, built-in animation for transitioning the floating label.
- **Clearable**: An optional built-in clear button for quick text removal.
- **Read Only and Disabled States**: Allows controlling how users interact with the field.
- **Validations**: Built-in support for validating input data (e.g., email format, password strength).
- **Error View**: Displays validation errors with a default or fully customizable style.
- **Helper Text View**: Provides extra context or tips beneath the text field (customizable).
- **Keyboard and Return Key Types**: Fine-tune the user’s keyboard experience on iOS.
- **Autocapitalization, Autocorrection, and Spell Checking**: Integrates natively with SwiftUI’s text input traits.
- **Multiple Design Modes**:
  - Floating label (native or custom style).
  - Always visible label inside or outside the text field.

#### Extended Functionalities (Planned)

- **Theming/Styling**: Allow custom color schemes, fonts, corner radii, border styles, shadows, etc.
- **Internationalization**: Built-in support for RTL languages and dynamic type.
- **Accessibility**: Integrate SwiftUI’s accessibility modifiers for screen readers and voice control.

## Contributing

Contributions are welcome! We’d love your help in making **PKSUI** the best it can be. Before contributing, please read our:

- [CONTRIBUTING.md](CONTRIBUTING.md) to learn how to propose changes and submit pull requests.
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) to understand the expected behavior in our community.

### Ways to Contribute

- Submit bug reports and feature requests under [Issues](../../issues).
- Improve documentation.
- Write unit tests and/or UI tests.
- Propose new components or enhancements to existing ones.

---

## Code of Conduct

Please read our [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) to understand the standards of behavior we expect from our community.

---

## License

This project is licensed under the [MIT License](LICENSE).  
Feel free to use, modify, and distribute this library within your own projects under the terms of the license.

---

**Happy coding with PKSUI!**  
Your contributions and feedback are always welcome. If you have any questions or ideas, feel free to open a discussion or create a pull request.
