#!/usr/bin/env python3
"""Fix merge conflicts and add 10 missing keys to all languages."""
import re

path = r'C:\Users\kush_\my_parents_story\lib\l10n\translations.dart'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Step 1: Resolve merge conflicts - keep HEAD version
# Pattern: <<<<<<< HEAD\n(HEAD content)\n=======\n(other content)\n>>>>>>> hash
pattern = r'<<<<<<< HEAD\n(.*?)\n=======\n.*?\n>>>>>>> [0-9a-f]+\n'
resolved = re.sub(pattern, r'\1\n', content, flags=re.DOTALL)

# Verify no conflicts remain
if '<<<<<<< HEAD' in resolved:
    print("ERROR: Still have merge conflicts after first pass!")
    import sys; sys.exit(1)
else:
    print(f"Resolved merge conflicts. File reduced from {len(content)} to {len(resolved)} chars.")

with open(path, 'w', encoding='utf-8') as f:
    f.write(resolved)

print("Step 1 done: merge conflicts resolved.")
