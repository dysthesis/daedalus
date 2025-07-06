# LACKLUSTER THEME BEGIN
color_lack="#708090"
color_luster="#deeeed"
color_orange="#ffaa88"
color_green="#789978"
color_blue="#7788AA"
color_red="#D70000"
color_black="#000000"
color_white="#white"
color_gray1="#080808"
color_gray2="#191919"
color_gray3="#2a2a2a"
color_gray4="#444444"
color_gray5="#555555"
color_gray6="#7a7a7a"
color_gray7="#aaaaaa"
color_gray8="#cccccc"
color_gray9="#DDDDDD"

# Status bar position and style
set-option -g status-position "bottom"
set-option -g status-style "bg=default,fg=default"
set-option -g status-justify "centre"

# Indicator for prefix - using direct color values
set -g status-left-length 30 # could be any number
set-option -g status-left "#[fg=$color_orange]󰒋 #[fg=default,bg=default]#H #[fg=$color_blue] #[fg=default,bg=default]#(whoami)"

# Session name on the right
set-option -g status-right "#[fg=$color_green]   #[fg=default,bg=default]#S"

# Window status format
set-option -g window-status-format "#[bg=$color_gray2,fg=$color_lack] #I: #W "

# Current window status format with arrows
set-option -g window-status-current-format "#[fg=$color_gray2]#[bg=$color_lack,fg=$color_gray2,bold]  #W #{?window_zoomed_flag,󰊓 ,}#[fg=$color_gray2,bg=default]"

# Rest of the settings remain the same...
