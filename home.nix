{ pkgs, inputs, ... }: {
  home.username = "dimix-pc";
  home.homeDirectory = "/home/dimix-pc";

  home.packages = [
    inputs.quickshell.packages.${pkgs.system}.default
    inputs.noctalia.packages.${pkgs.system}.default
  ];

  xdg.configFile."niri/config.kdl".text = ''
    // Автозапуск Xwayland та Noctalia Shell
    spawn-at-startup "xwayland-satellite"
    spawn-at-startup "noctalia-shell"

    output "eDP-1" {
        mode "1920x1080@144.00"
        position x=0 y=0
    }

    output "HDMI-A-1" {
        mode "1920x1080@180.00"
        position x=1920 y=0
    }

    input {
        touchpad {
            tap
            natural-scroll
        }
    }

    layout {
        gaps 14
        center-focused-column "never"
        default-column-width { proportion 0.5; }
        focus-ring {
            width 2
            active-color "#7aa2f7"
        }
    }

    animations {
        slowdown 1.1
    }

    binds {
        // Запуск терміналу, лаунчера та закриття вікон
        Mod+Return { spawn "kitty"; }
        Mod+D { spawn "fuzzel"; }
        Mod+Q { close-window; }

        // Гаряча клавіша швидкого перезапуску панелей Noctalia
        Mod+Shift+R { spawn "sh" "-c" "pkill noctalia-shell; noctalia-shell"; }

        // Навігація нескінченною горизонтальною стрічкою вікон
        Mod+Left  { focus-column-left; }
        Mod+Right { focus-column-right; }
        Mod+H     { focus-column-left; }
        Mod+L     { focus-column-right; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Right { move-column-right; }

        // Вертикальний скролінг робочих просторів
        Mod+Up    { focus-workspace-up; }
        Mod+Down  { focus-workspace-down; }

        // Мультимедіа клавіші
        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }

        XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "set" "10%+"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "10%-"; }

        // Скріншоти (Вбудований інтерактивний інструмент Niri)
        Print { screenshot; }
        Alt+Print { screenshot-window; }
        Ctrl+Print { screenshot-screen; }
    }
  '';

  home.stateVersion = "26.05";
}
