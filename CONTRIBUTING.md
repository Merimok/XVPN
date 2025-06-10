# Contributing to XVPN

Thank you for your interest in contributing to XVPN! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (≥3.0.0)
- Visual Studio 2022 with C++ build tools
- Git
- Windows 10/11 for testing

### Development Setup
1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/XVPN.git
   cd XVPN/vpn_client
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Create a new branch for your feature:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 📝 Development Guidelines

### Code Style
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format` before committing
- Maximum line length: 80 characters
- Use meaningful variable and function names

### Commit Messages
Follow the conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(vpn): add automatic reconnection feature
fix(ui): resolve connection status display issue
docs(readme): update installation instructions
```

### Testing
- Write tests for new features
- Ensure all existing tests pass
- Aim for good test coverage
- Run tests before submitting PR:
  ```bash
  flutter test
  ```

### Documentation
- Update README.md for significant changes
- Add inline documentation for public APIs
- Update CHANGELOG.md for user-facing changes

## 🐛 Bug Reports

When reporting bugs, please include:

### System Information
- OS version (Windows 10/11)
- Flutter version
- Application version
- Hardware architecture (x64/ARM64)

### Bug Description
- Clear, concise description
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

### Logs and Diagnostics
- Application logs from the diagnostics screen
- Error messages
- System event logs if relevant

### Minimal Reproduction
Provide the smallest possible code example that demonstrates the issue.

## 💡 Feature Requests

Before submitting a feature request:
1. Check existing issues and discussions
2. Ensure it aligns with project goals
3. Consider implementation complexity
4. Think about user impact

Include in your request:
- Clear use case description
- Proposed solution (if any)
- Alternative solutions considered
- Additional context

## 🔧 Pull Request Process

### Before Submitting
1. Ensure your code follows the style guidelines
2. Add or update tests as needed
3. Update documentation
4. Test on Windows (primary target platform)
5. Rebase your branch on latest main:
   ```bash
   git fetch origin
   git rebase origin/main
   ```

### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass locally
- [ ] Added tests for new functionality
- [ ] Tested on Windows

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No merge conflicts
```

### Review Process
1. Automated checks must pass
2. Code review by maintainers
3. Testing on multiple Windows versions
4. Final approval and merge

## 🏗️ Architecture Guidelines

### Project Structure
```
lib/
├── main.dart              # Entry point
├── models/               # Data models
├── screens/              # UI screens
├── services/             # Business logic
├── state/                # State management
└── utils/                # Helper utilities
```

### Design Patterns
- **Provider Pattern**: State management
- **Repository Pattern**: Data access
- **Service Layer**: Business logic separation
- **Factory Pattern**: Object creation

### Dependencies
- Keep dependencies minimal
- Prefer stable, well-maintained packages
- Document new dependencies in PR description

## 🔒 Security Guidelines

### Sensitive Data
- Never commit credentials or API keys
- Use secure storage for sensitive information
- Validate all user inputs
- Follow principle of least privilege

### Code Review Focus
- Input validation
- Error handling
- Resource cleanup
- Permission requirements

## 📋 Issue Labels

- `bug`: Something isn't working
- `enhancement`: New feature request
- `documentation`: Improvements to docs
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention needed
- `priority/high`: High priority items
- `priority/low`: Low priority items

## 🤝 Community Guidelines

### Code of Conduct
- Be respectful and inclusive
- Focus on constructive feedback
- Help newcomers
- Follow GitHub's Community Guidelines

### Communication
- Use clear, professional language
- Provide context in discussions
- Be patient with response times
- Use appropriate channels (issues vs discussions)

## 📚 Resources

### Learning
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Material Design Guidelines](https://material.io/design)

### Tools
- [Flutter Inspector](https://flutter.dev/docs/development/tools/flutter-inspector)
- [Dart DevTools](https://dart.dev/tools/dart-devtools)
- [VS Code Flutter Extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)

## ❓ Questions

If you have questions about contributing:
1. Check existing documentation
2. Search closed issues
3. Open a discussion (not an issue)
4. Join community chat if available

Thank you for contributing to XVPN! 🎉
