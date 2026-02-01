# Floating Glass Navbar Implementation Plan

This plan details the transition to a modern, top-aligned sticky header with a glassmorphism effect.

## Proposed Changes

### [MODIFY] [layout.erb](file:///Users/user/RubyProjects/SinatraWorks/myai/views/layout.erb)
- Relocate the `<header>` block outside of the `.app-wrapper` to be a direct child of `<body>`.
- Add a new container (e.g., `.page-content`) to wrap the sidebar and main content for better alignment.
- Simplify header internal structure for a horizontal layout.

### [MODIFY] [style.css](file:///Users/user/RubyProjects/SinatraWorks/myai/public/css/style.css)
- **Navbar Styling:**
    - Set `position: sticky; top: 0;` for the header.
    - Apply `backdrop-filter: blur(15px)` and semi-transparent background.
    - Add a subtle bottom border (`1px solid rgba(255,255,255,0.1)`).
    - Use `display: flex` to align logo/title and potentially new actions horizontally.
- **Layout Adjustments:**
    - Increase `padding-top` on the body or main content area to prevent overlap.
    - Adjust `.app-wrapper` to handle the new page structure.
    - Ensure logo size transition is smooth in the navbar context.

## Verification Plan

### Automated Tests
- Browser test: Scroll the page and verify the header remains at the top.
- Browser test: Check visibility and accessibility of header links.

### Manual Verification
- Visual check for "premium" feel: blur effect, spacing, and font clarity.
- Responsive test: Ensure the navbar scales or collapses correctly on mobile.
