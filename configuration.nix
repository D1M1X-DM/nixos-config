# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, inputs, ... }:

let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # ─────────────────────────────────────────────
  # SPICETIFY
  # ─────────────────────────────────────────────
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.comfy;
    colorScheme = "catppuccin-mocha";
    enabledCustomApps = with spicePkgs.apps; [ marketplace ];
    enabledExtensions = with spicePkgs.extensions; [
      adblock
      hidePodcasts
      shuffle
    ];
  };

  # ─────────────────────────────────────────────
  # NIRI (основний compositor, KDE прибрано)
  # ─────────────────────────────────────────────
  programs.niri.enable = true;
  programs.niri.package = inputs.niri.packages.${pkgs.system}.niri-unstable;

  # SDDM залишаємо як display manager (без KDE Plasma)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  #Включение службы автоматического обнаружения и управления дисками
  services.udisks2.enable = true;

  # Поддержка NTFS для корректного отображения и монтирования разделов Windows
  boot.supportedFilesystems = [ "ntfs" ];
  # ─────────────────────────────────────────────
  # ЗАВАНТАЖУВАЧ
  # ─────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Необхідно для Nvidia на Wayland (без цього — чорний екран або висока VRAM)
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  # ─────────────────────────────────────────────
  # МЕРЕЖА
  # ─────────────────────────────────────────────
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ─────────────────────────────────────────────
  # NIX
  # ─────────────────────────────────────────────
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Автоочищення store
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;

  # ─────────────────────────────────────────────
  # ЧАС ТА ЛОКАЛІЗАЦІЯ
  # ─────────────────────────────────────────────
  time.timeZone = "Europe/Kyiv";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "uk_UA.UTF-8";
    LC_IDENTIFICATION = "uk_UA.UTF-8";
    LC_MEASUREMENT    = "uk_UA.UTF-8";
    LC_MONETARY       = "uk_UA.UTF-8";
    LC_NAME           = "uk_UA.UTF-8";
    LC_NUMERIC        = "uk_UA.UTF-8";
    LC_PAPER          = "uk_UA.UTF-8";
    LC_TELEPHONE      = "uk_UA.UTF-8";
    LC_TIME           = "uk_UA.UTF-8";
  };

  # ─────────────────────────────────────────────
  # РОЗКЛАДКИ КЛАВІАТУРИ (us / ru / uk)
  # Перемикання: Shift+Alt  (grp:lalt_lshift_toggle)
  # ─────────────────────────────────────────────
  services.xserver.enable = true;          # потрібен для xkb-налаштувань та SDDM
  services.xserver.xkb = {
    layout  = "us,ru,ua";
    variant = ",,";
    options = "grp:lalt_lshift_toggle";    # Shift+Alt — перемикання розкладки
  };

  # ─────────────────────────────────────────────
  # ДРУК
  # ─────────────────────────────────────────────
  services.printing.enable = true;

  # ─────────────────────────────────────────────
  # ЗВУК
  # ─────────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # ─────────────────────────────────────────────
  # ЖИВЛЕННЯ ТА УПРАВЛІННЯ НОУТБУКОМ
  # ─────────────────────────────────────────────
  services.upower.enable = true;
  powerManagement.enable = true;
  services.thermald.enable = true;          # охолодження Intel CPU

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandlePowerKey  = "suspend";
  };

  # zram замість swap-розділу
  zramSwap.enable = true;

  # ─────────────────────────────────────────────
  # BLUETOOTH
  # ─────────────────────────────────────────────
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ─────────────────────────────────────────────
  # ЗМІННІ ОТОЧЕННЯ
  # ─────────────────────────────────────────────
  environment.variables = {
    QT_LOGGING_RULES = "qt.multimedia.symbolsresolver.warning=false";
    # Wayland backend для Qt та GTK застосунків
    QT_QPA_PLATFORM    = "wayland;xcb";
    GDK_BACKEND        = "wayland,x11";
    NIXOS_OZONE_WL     = "1";              # Chromium/Electron через Wayland
    MOZ_ENABLE_WAYLAND = "1";             # Firefox через Wayland
    XDG_SESSION_TYPE   = "wayland";
    XDG_CURRENT_DESKTOP = "niri";          # Додано для ідентифікації Niri
  };

  # ─────────────────────────────────────────────
  # КОРИСТУВАЧ
  # ─────────────────────────────────────────────
  users.users."dimix-pc" = {
    isNormalUser = true;
    description  = "Dmyro L.";
    extraGroups  = [ "networkmanager" "wheel" "video" "audio" ];
    packages     = with pkgs; [
      kdePackages.kate          # текстовий редактор
    ];
  };

  # ─────────────────────────────────────────────
  # ГРАФІКА — NVIDIA + Intel (PRIME sync)
  # ─────────────────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      sync.enable  = true;
      intelBusId   = "PCI:0:2:0";
      nvidiaBusId  = "PCI:1:0:0";
    };
  };

  # ─────────────────────────────────────────────
  # ІГРИ
  # ─────────────────────────────────────────────
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  # ─────────────────────────────────────────────
  # ШРИФТИ
  # ─────────────────────────────────────────────
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  # ─────────────────────────────────────────────
  # ЗАСТОСУНКИ — СИСТЕМНІ ПАКЕТИ
  # ─────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  nixpkgs.config.permittedInsecurePackages = [
    "pnpm-10.29.2"
  ];


# Налаштування порталів для роботи демонстрації екрана в Niri
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.niri.default = [ "gnome" "gtk" ];
  };

  environment.systemPackages = with pkgs; [
    # ── Термінали ──
    alacritty
    kitty

    # ── Браузери ──
    firefox
    google-chrome

    # ── Месенджери ──
    vesktop
    telegram-desktop

    # ── Розробка ──
    vim
    git
    wget

    # ── Системна інформація ──
    fastfetch
    hardinfo2
    pciutils
    lshw
    # ── Файловий менеджер (GTK, добре працює на Wayland) ──
    nautilus           # Files — простий та зручний
    gvfs               # Монтування MTP/SMB/SFTP для nautilus

    # ── Архіватори (GUI + CLI) ──
    file-roller        # Графічний менеджер архівів (GTK)
    unzip
    p7zip
    unrar

    # ── Перегляд медіа ──
    mpv                # Відеоплеєр (легкий, Wayland-native)
    eog                # Eye of GNOME — переглядач зображень
    loupe              # Сучасний GTK4 переглядач зображень
    cava               # Аудіо візуалізатор в термінал
    # ── Офіс ──
    libreoffice-fresh  # Повний офісний пакет (Writer, Calc, Impress…)
    hunspell           # Перевірка орфографії
    hunspellDicts.uk_UA
    hunspellDicts.ru_RU
    hunspellDicts.en_US

    # ── Графіка та дизайн ──
    gimp               # Редактор растрових зображень
    inkscape           # Векторна графіка (SVG)

    # ── GUI налаштувань системи ──
    gnome-disk-utility       # Управління дисками
    kdePackages.partitionmanager
    kdePackages.kpmcore
    pavucontrol              # Графічний мікшер Pipewire/PulseAudio
    blueman                  # GUI для Bluetooth
    networkmanagerapplet     # Іконка мережі в треї

    # ── nwg-tools — GUI налаштувань для Wayland (обої, монітори, теми) ──
    nwg-displays             # 🖥️  Графічне налаштування моніторів (роздільна здатність, розташування, масштаб)
    nwg-look                 # 🎨  GTK тема, іконки, курсори, шрифти — як GNOME Tweaks
    # nwg-bar / nwg-menu / nwg-panel — прибрано, Noctalia вже є панеллю

    # ── Обої ──
    swaybg                   # Встановлення обоїв через CLI: swaybg -i ~/photo.jpg
    waypaper                 # 🖼️  Графічний вибір обоїв (GUI поверх swaybg/swww)
    awww                     # Анімована зміна обоїв із ефектами переходу (колишній swww)

    # ── Скринлок ──
    swaylock           # Локскрін для Wayland

    # ── Утиліти Wayland ──
    xwayland-satellite
    fuzzel             # Лаунчер застосунків
    wl-clipboard       # Буфер обміну для Wayland (wl-copy / wl-paste)
    grim               # Скріншоти Wayland
    slurp              # Вибір регіону для grim
    cliphist           # Менеджер буферу обміну з історією

    # ── Яскравість та звук ──
    brightnessctl
    pipewire

    # ── Файловий менеджер (KDE Dolphin) ──
    kdePackages.dolphin
    kdePackages.kio-extras
    kdePackages.kdegraphics-thumbnailers # Виправлено: тепер використовується версія для Qt6
    gvfs

    # ── Ігри ──
    steam
    r2modman
    # ── Теми та курсори ──
    bibata-cursors
    adwaita-icon-theme

    # ── Qt / KDE бібліотеки ──
    kdePackages.qtmultimedia
    kdePackages.qt6ct        # GUI для налаштування Qt-теми поза KDE
    libsForQt5.qt5ct         # Те саме для Qt5
  ];

  system.stateVersion = "26.05";
}
