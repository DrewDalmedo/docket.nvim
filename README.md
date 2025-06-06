# docket.nvim

Global and project-based docket management

## About

Basically a project progress / ideas tracker. Can also be used as an easily accessible and
auto-saved scratchpad.

Uses markdown files saved to your nvim-data directory by default.

There are two kinds of dockets:
- Global docket (for tracking project-independent / personal ideas & items)
- Project-specific dockets (not yet implemented)

## Installation

For Lazy.nvim:

```lua
{
    "DrewDalmedo/docket.nvim",

    -- (Optional) set keybindings for opening dockets
    keys = {
        {
            "<leader>dg", 
            "<cmd>DocketGlobal<cr>", 
            desc = "Open the global docket in a full window" 
        },
        {
            "<leader>df",
            "<cmd>DocketGlobalFloating<cr>",
            desc = "Open the global docket in a floating window (closed with Esc)",
        },
    },
}
```

## Command Quick Reference

- `DocketGlobal`: Open the global docket in a full window
- `DocketGlobalFloating`: Open the global docket in a floating window (closed with Esc)
