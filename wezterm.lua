local wezterm = require 'wezterm';
local act = wezterm.action

return {
    use_ime = true,
    font = wezterm.font_with_fallback({
        { family = "Cica" },
        { family = "Cica", assume_emoji_presentation = true },
    }),
    font_size = 12.0,
    color_scheme = "Hybrid (terminal.sexy)",
    window_background_opacity=0.9,
    hide_tab_bar_if_only_one_tab = true,
    warn_about_missing_glyphs = false,
    initial_cols = 120,
    initial_rows = 40,
    adjust_window_size_when_changing_font_size = false,
    keys = {{
        key = '"',
        mods = 'CTRL|SHIFT',
        action = act.SplitVertical {
            domain = 'CurrentPaneDomain'
        }
    }, {
        key = '%',
        mods = 'CTRL|SHIFT',
        action = act.SplitHorizontal {
            domain = 'CurrentPaneDomain'
        }
    }, {
        key = 'h',
        mods = 'CTRL|SHIFT',
        action = act.ActivatePaneDirection 'Left'
    }, {
        key = 'l',
        mods = 'CTRL|SHIFT',
        action = act.ActivatePaneDirection 'Right'
    }, {
        key = 'k',
        mods = 'CTRL|SHIFT',
        action = act.ActivatePaneDirection 'Up'
    }, {
        key = 'j',
        mods = 'CTRL|SHIFT',
        action = act.ActivatePaneDirection 'Down'
    }}
}
