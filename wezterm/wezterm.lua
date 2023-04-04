
-- Pull in the wezterm API
local wezterm = require 'wezterm'
smartsplits_keys = require('smartsplits')

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'HaX0R_GR33N'
config.color_scheme = 'Green Screen (base16)'
--config.color_scheme = 'Matrix (terminal.sexy)'

config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true

config.disable_default_key_bindings = true
config.font_size = 10.5

--config.font = wezterm.font_with_fallback {'Ubuntu Mono', 'Roman Mono'}
config.warn_about_missing_glyphs = false


-- timeout_milliseconds defaults to 1000 and can be omitted
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
  {
    key = '|',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  -- Send "CTRL-A" to the terminal when pressing CTRL-A, CTRL-A
  {
    key = 'a',
    mods = 'LEADER|CTRL',
    action = wezterm.action.SendString '\x01',
  },
}

config.keys = {
  -- Turn off the default CMD-m Hide action, allowing CMD-m to
  -- be potentially recognized and handled by the tab
  { mods = 'CTRL', key = '=', action = wezterm.action.IncreaseFontSize, },
  { mods = 'CTRL', key = '-', action = wezterm.action.DecreaseFontSize, },
  --{ mods = 'CTRL', key = 'j', action = wezterm.action.ActivatePaneDirection("Down"), },
  --{ mods = 'CTRL', key = 'k', action = wezterm.action.ActivatePaneDirection("Up"), },
  --{ mods = 'CTRL', key = 'h', action = wezterm.action.ActivatePaneDirection("Left"), },
  --{ mods = 'CTRL', key = 'l', action = wezterm.action.ActivatePaneDirection("Right"), },
  { mods = 'LEADER', key = '\\', action = wezterm.action.SplitHorizontal {domain = "CurrentPaneDomain"}, },
  { mods = 'LEADER', key = '-', action = wezterm.action.SplitVertical {domain = "CurrentPaneDomain"}, },
  { mods = 'LEADER', key = 'q', action = wezterm.action.CloseCurrentTab {confirm = true}, },
  { mods = 'LEADER', key = 't', action = wezterm.action.SpawnTab ("DefaultDomain"), },
  { mods = 'LEADER', key = 'n', action = wezterm.action.ActivateTabRelative (1), },
  { mods = 'LEADER', key = 'p', action = wezterm.action.ActivateTabRelative (-1), },
  { mods = 'LEADER', key = 'b', action = wezterm.action.ActivateLastTab, },
 -- paste from the clipboard
  { mods = 'CTRL', key = 'V', action = wezterm.action.PasteFrom 'Clipboard' },
  -- paste from the primary selection
  { mods = 'CTRL', key = 'V', action = wezterm.action.PasteFrom 'PrimarySelection' },
  table.unpack(smartsplits_keys.keys)
}

config.key_tables = smartsplits_keys.key_tables

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    if tab.is_active then
      return {
        { Background = { Color = 'green' } },
        { Text = ' ' .. tab.active_pane.title .. ' ' },
      }
    end
    return tab.active_pane.title
  end
)


-- and finally, return the configuration to wezterm
return config
