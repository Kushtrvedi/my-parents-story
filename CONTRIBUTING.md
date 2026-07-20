# Contributing to My Parents' Story

Thank you for your interest in helping preserve family memories. Every contribution makes this project better for families everywhere.

## Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch: `git checkout -b feature/your-feature`
4. Make your changes
5. Run tests: `flutter test`
6. Run analyzer: `flutter analyze`
7. Commit: `git commit -m "feat: add your feature"`
8. Push: `git push origin feature/your-feature`
9. Open a Pull Request

## Development Setup

```bash
# Clone the repo
git clone https://github.com/your-username/my-parents-story.git
cd my-parents-story

# Install dependencies
flutter pub get

# Copy environment file
cp .env.example .env

# Configure Firebase
flutterfire configure

# Run the app
flutter run
```

## Code Style

- Follow Dart style guide
- Use `dart format` before committing
- Keep functions small and focused
- Write meaningful variable and function names
- Add comments only when the code isn't self-explanatory

## Commit Convention

We use [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Formatting changes
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Maintenance tasks

Examples:
```
feat: add voice recording support
fix: resolve PDF export crash on iOS
docs: update installation instructions
refactor: simplify question database loading
```

## Pull Request Process

1. Update README.md with details of changes if applicable
2. Update CHANGELOG.md with a summary of changes
3. Ensure all tests pass
4. Ensure flutter analyze has no errors
5. Request review from maintainers

## Reporting Bugs

Use the GitHub Issues with the bug report template. Include:
- Device and OS information
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if possible

## Feature Requests

Open an issue with the feature request template. Describe:
- The problem you're trying to solve
- Your proposed solution
- Why this would help preserve memories

## Code of Conduct

Be respectful, inclusive, and constructive. We're building something that matters for families.

## Questions?

Open an issue with the label `question` or reach out to maintainers.
