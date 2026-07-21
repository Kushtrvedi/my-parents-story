#!/usr/bin/env python3
"""Carefully resolve merge conflicts one at a time, keeping HEAD version."""
path = r'C:\Users\kush_\my_parents_story\lib\l10n\translations.dart'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

print(f"Original: {len(content)} chars")
print(f"Conflicts found: {content.count('<<<<<<< HEAD')}")

# Resolve each conflict individually using a non-greedy approach
import re

# Split by conflict markers and reassemble keeping HEAD
parts = []
remaining = content
conflict_count = 0

while '<<<<<<< HEAD' in remaining:
    conflict_count += 1
    # Find the start of this conflict
    start = remaining.index('<<<<<<< HEAD')
    # Add everything before the conflict
    parts.append(remaining[:start])
    
    # Find ======= after <<<<<<< HEAD
    after_head = remaining[start + len('<<<<<<< HEAD\n'):]
    mid = after_head.index('=======\n')
    head_content = after_head[:mid]
    
    # Find >>>>>>> after =======
    after_equal = after_head[mid + len('=======\n'):]
    end = after_equal.index('>>>>>>> ') 
    # Skip past the hash line
    end_line = after_equal.index('\n', end)
    
    # Keep HEAD version
    parts.append(head_content)
    
    # Move remaining past this conflict
    remaining = after_equal[end_line + 1:]

parts.append(remaining)
resolved = ''.join(parts)

print(f"Resolved {conflict_count} conflicts")
print(f"Result: {len(resolved)} chars")

# Verify
if '<<<<<<< HEAD' in resolved:
    print("ERROR: Still have conflicts!")
else:
    print("No more conflict markers. Writing file.")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(resolved)
    print("Done!")
