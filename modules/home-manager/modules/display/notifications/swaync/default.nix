{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.display.notifications;
in
  with lib; {
    options = {
      modules = {
        display = {
          notifications = {
            swaync = {
              enable = mkEnableOption "Enable swaync" // {default = cfg.enable;};
            };
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.swaync.enable) {
      home = {
        packages = with pkgs; [
          swaynotificationcenter
        ];
      };
      xdg = {
        configFile = {
          "swaync/style.css" = {
            text =
              /*
              css
              */
              ''
                * {
                  all: unset;
                  font-size: ${builtins.toString config.modules.fonts.size}px;
                  font-family: "${config.modules.fonts.defaultFont}";
                  transition: 200ms;
                }

                trough highlight {
                  background: #cad3f5;
                }

                scale trough {
                  margin: 0rem 1rem;
                  background-color: #363a4f;
                  min-height: 8px;
                  min-width: 70px;
                }

                slider {
                  background-color: #8aadf4;
                }

                .floating-notifications.background .notification-row .notification-background {
                  box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px #363a4f;
                  border-radius: 12.6px;
                  margin: 18px;
                  background-color: #24273a;
                  color: #cad3f5;
                  padding: 0;
                }

                .floating-notifications.background .notification-row .notification-background .notification {
                  padding: 7px;
                  border-radius: 12.6px;
                }

                .floating-notifications.background .notification-row .notification-background .notification.critical {
                  box-shadow: inset 0 0 7px 0 #ed8796;
                }

                .floating-notifications.background .notification-row .notification-background .notification .notification-content {
                  margin: 7px;
                }

                .floating-notifications.background .notification-row .notification-background .notification .notification-content .summary {
                  color: #cad3f5;
                }

                .floating-notifications.background .notification-row .notification-background .notification .notification-content .time {
                  color: #a5adcb;
                }

                .floating-notifications.background .notification-row .notification-background .notification .notification-content .body {
                  color: #cad3f5;
                }

                .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * {
                  min-height: 3.4em;
                }

                .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action {
                  border-radius: 7px;
                  color: #cad3f5;
                  background-color: #363a4f;
                  box-shadow: inset 0 0 0 1px #494d64;
                  margin: 7px;
                }

                .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
                  box-shadow: inset 0 0 0 1px #494d64;
                  background-color: #363a4f;
                  color: #cad3f5;
                }

                .floating-notifications.background .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
                  box-shadow: inset 0 0 0 1px #494d64;
                  background-color: #7dc4e4;
                  color: #cad3f5;
                }

                .floating-notifications.background .notification-row .notification-background .close-button {
                  margin: 7px;
                  padding: 2px;
                  border-radius: 6.3px;
                  color: #24273a;
                  background-color: #ed8796;
                }

                .floating-notifications.background .notification-row .notification-background .close-button:hover {
                  background-color: #ee99a0;
                  color: #24273a;
                }

                .floating-notifications.background .notification-row .notification-background .close-button:active {
                  background-color: #ed8796;
                  color: #24273a;
                }

                .control-center {
                  box-shadow: 0 0 8px 0 rgba(0, 0, 0, 0.8), inset 0 0 0 1px #363a4f;
                  border-radius: 12.6px;
                  margin: 18px;
                  background-color: #24273a;
                  color: #cad3f5;
                  padding: 14px;
                }

                .control-center .widget-title > label {
                  color: #cad3f5;
                  font-size: 1.3em;
                }

                .control-center .widget-title button {
                  border-radius: 7px;
                  color: #cad3f5;
                  background-color: #363a4f;
                  box-shadow: inset 0 0 0 1px #494d64;
                  padding: 8px;
                }

                .control-center .widget-title button:hover {
                  box-shadow: inset 0 0 0 1px #494d64;
                  background-color: #5b6078;
                  color: #cad3f5;
                }

                .control-center .widget-title button:active {
                  box-shadow: inset 0 0 0 1px #494d64;
                  background-color: #7dc4e4;
                  color: #24273a;
                }

                .control-center .notification-row .notification-background {
                  border-radius: 7px;
                  color: #cad3f5;
                  background-color: #363a4f;
                  box-shadow: inset 0 0 0 1px #494d64;
                  margin-top: 14px;
                }

                .control-center .notification-row .notification-background .notification {
                  padding: 7px;
                  border-radius: 7px;
                }

                .control-center .notification-row .notification-background .notification.critical {
                  box-shadow: inset 0 0 7px 0 #ed8796;
                }

                .control-center .notification-row .notification-background .notification .notification-content {
                  margin: 7px;
                }

                .control-center .notification-row .notification-background .notification .notification-content .summary {
                  color: #cad3f5;
                }

                .control-center .notification-row .notification-background .notification .notification-content .time {
                  color: #a5adcb;
                }

                .control-center .notification-row .notification-background .notification .notification-content .body {
                  color: #cad3f5;
                }

                .control-center .notification-row .notification-background .notification > *:last-child > * {
                  min-height: 3.4em;
                }

                .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action {
                  border-radius: 7px;
                  color: #cad3f5;
                  background-color: #181926;
                  box-shadow: inset 0 0 0 1px #494d64;
                  margin: 7px;
                }

                .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:hover {
                  box-shadow: inset 0 0 0 1px #494d64;
                  background-color: #363a4f;
                  color: #cad3f5;
                }

                .control-center .notification-row .notification-background .notification > *:last-child > * .notification-action:active {
                  box-shadow: inset 0 0 0 1px #494d64;
                  background-color: #7dc4e4;
                  color: #cad3f5;
                }

                .control-center .notification-row .notification-background .close-button {
                  margin: 7px;
                  padding: 2px;
                  border-radius: 6.3px;
                  color: #24273a;
                  background-color: #ee99a0;
                }

                .close-button {
                  border-radius: 6.3px;
                }

                .control-center .notification-row .notification-background .close-button:hover {
                  background-color: #ed8796;
                  color: #24273a;
                }

                .control-center .notification-row .notification-background .close-button:active {
                  background-color: #ed8796;
                  color: #24273a;
                }

                .control-center .notification-row .notification-background:hover {
                  box-shadow: inset 0 0 0 1px #494d64;
                  background-color: #8087a2;
                  color: #cad3f5;
                }

                .control-center .notification-row .notification-background:active {
                  box-shadow: inset 0 0 0 1px #494d64;
                  background-color: #7dc4e4;
                  color: #cad3f5;
                }

                .notification.critical progress {
                  background-color: #ed8796;
                }

                .notification.low progress,
                .notification.normal progress {
                  background-color: #8aadf4;
                }

                .control-center-dnd {
                  margin-top: 5px;
                  border-radius: 8px;
                  background: #363a4f;
                  border: 1px solid #494d64;
                  box-shadow: none;
                }

                .control-center-dnd:checked {
                  background: #363a4f;
                }

                .control-center-dnd slider {
                  background: #494d64;
                  border-radius: 8px;
                }

                .widget-dnd {
                  margin: 0px;
                  font-size: 1.1rem;
                }

                .widget-dnd > switch {
                  font-size: initial;
                  border-radius: 8px;
                  background: #363a4f;
                  border: 1px solid #494d64;
                  box-shadow: none;
                }

                .widget-dnd > switch:checked {
                  background: #363a4f;
                }

                .widget-dnd > switch slider {
                  background: #494d64;
                  border-radius: 8px;
                  border: 1px solid #6e738d;
                }

                .widget-mpris .widget-mpris-player {
                  background: #363a4f;
                  padding: 7px;
                }

                .widget-mpris .widget-mpris-title {
                  font-size: 1.2rem;
                }

                .widget-mpris .widget-mpris-subtitle {
                  font-size: 0.8rem;
                }

                .widget-menubar > box > .menu-button-bar > button > label {
                  font-size: 3rem;
                  padding: 0.5rem 2rem;
                }

                .widget-menubar > box > .menu-button-bar > :last-child {
                  color: #ed8796;
                }

                .power-buttons button:hover,
                .powermode-buttons button:hover,
                .screenshot-buttons button:hover {
                  background: #363a4f;
                }

                .control-center .widget-label > label {
                  color: #cad3f5;
                  font-size: 2rem;
                }

                .widget-buttons-grid {
                  padding-top: 1rem;
                }

                .widget-buttons-grid > flowbox > flowboxchild > button label {
                  font-size: 2.5rem;
                }

                .widget-volume {
                  padding-top: 1rem;
                }

                .widget-volume label {
                  font-size: 1.5rem;
                  color: #7dc4e4;
                }

                .widget-volume trough highlight {
                  background: #7dc4e4;
                }

                .widget-backlight trough highlight {
                  background: #eed49f;
                }

                .widget-backlight label {
                  font-size: 1.5rem;
                  color: #eed49f;
                }

                .widget-backlight .KB {
                  padding-bottom: 1rem;
                }

                .image {
                  padding-right: 0.5rem;
                }

              '';
          };
          "swaync/config.json" = {
            text =
              /*
              json
              */
              ''
                {
                  "positionX": "right",
                  "positionY": "top",
                  "control-center-margin-top": 10,
                  "control-center-margin-bottom": 10,
                  "control-center-margin-right": 10,
                  "control-center-margin-left": 10,
                  "notification-icon-size": 64,
                  "notification-body-image-height": 100,
                  "notification-body-image-width": 200,
                  "timeout": 10,
                  "timeout-low": 5,
                  "timeout-critical": 0,
                  "fit-to-screen": true,
                  "control-center-width": 500,
                  "control-center-height": 900,
                  "notification-window-width": 500,
                  "keyboard-shortcuts": true,
                  "image-visibility": "when-available",
                  "transition-time": 200,
                  "hide-on-clear": false,
                  "hide-on-action": false,
                  "script-fail-notify": true,
                  "widgets": [
                    "title",
                    "mpris",
                    "dnd",
                    "notifications"
                  ],
                  "widget-config": {
                    "title": {
                      "text": "Notification Center",
                      "clear-all-button": true,
                      "button-text": "󰆴 Clear All"
                    },
                    "dnd": {
                      "text": "Do Not Disturb"
                    },
                    "label": {
                      "max-lines": 1,
                      "text": "Notification Center"
                    },
                    "mpris": {
                      "image-size": 96,
                      "image-radius": 7
                    }
                  }
                }
              '';
          };
        };
      };
    };
  }
