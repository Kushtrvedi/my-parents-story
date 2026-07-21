#!/usr/bin/env python3
"""Inspect the translations.dart file to find exact indentation patterns."""
with open(r'C:\Users\kush_\my_parents_story\lib\l10n\translations.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "'withLove'" in line:
        # Print context: 2 lines before and 2 after
        start = max(0, i - 1)
        end = min(len(lines), i + 3)
        for j in range(start, end):
            print(f"Line {j+1}: {repr(lines[j])}")
        print("---")
