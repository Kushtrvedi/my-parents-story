# PDF System

## Overview

The PDF system generates print-quality memoir books from collected responses and AI-generated chapters.

## Book Structure

```
Cover Page
├── Parent name
├── Photo (initial)
├── Birth year & city
├── Quote
└── App branding

Table of Contents
├── Auto-generated chapter list
└── Final letter

Chapters (1-12)
├── Chapter number
├── Chapter title
├── Content paragraphs
└── Page breaks

Final Letter
├── Title: "What I Hope My Family Remembers"
├── AI-generated content
└── Signature
```

## Design System

### Typography
- **Titles**: Lora (serif) - 28-36pt
- **Body**: Lora - 12pt
- **Line spacing**: 18pt
- **Margins**: 60pt horizontal, 80pt vertical

### Colors
- **Background**: #FFFFFF
- **Text**: #111111
- **Secondary**: #666666
- **Accent**: #C9A96E (Warm Gold)
- **Divider**: #E8E8E8

### Layout
- A4 page format
- Large margins for print
- Chapter breaks on new pages
- Consistent spacing

## Generation Process

1. Create PDF document
2. Build cover page with parent info
3. Generate table of contents
4. Format each chapter with proper typography
5. Add final letter
6. Write to device storage
7. Return file for sharing

## Export Options

### Share PDF
- Uses `share_plus` package
- Opens system share sheet
- Supports email, messages, cloud storage

### Save Locally
- Saves to app documents directory
- Filename: `{ParentName}_memoir.pdf`

## Dependencies

- `pdf`: Core PDF generation
- `printing`: PDF rendering and sharing
- `path_provider`: File system access

## Future Enhancements

- Photo embedding in chapters
- Custom cover designs
- Print-on-demand integration
- Multiple page sizes
- Table of contents with page numbers
