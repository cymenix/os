{
  pkgs,
  config,
  osConfig,
  lib,
  ...
}: let
  cfg = config.modules.browser;
  user = osConfig.modules.users.user;
in
  with lib; {
    options = {
      modules = {
        browser = {
          firefox = {
            enable = mkEnableOption "Enable firefox" // {default = cfg.enable;};
          };
        };
      };
    };
    config = mkIf (cfg.enable && cfg.firefox.enable) {
      programs = {
        firefox = {
          enable = cfg.firefox.enable;
          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            decentraleyes
            ublock-origin
            bitwarden
            istilldontcareaboutcookies
            firefox-color
            sponsorblock
            df-youtube
          ];
          profiles = {
            ${user} = {
              id = 0;
              name = user;
              search = {
                force = true;
                default = "DuckDuckGo";
                privateDefault = "DuckDuckGo";
                order = [
                  "DuckDuckGo"
                  "Google"
                ];
                engines = {
                  "Nix Packages" = {
                    urls = [
                      {
                        template = "https://search.nixos.org/packages";
                        params = [
                          {
                            name = "type";
                            value = "packages";
                          }
                          {
                            name = "query";
                            value = "{searchTerms}";
                          }
                        ];
                      }
                    ];
                    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                    definedAliases = ["@np"];
                  };
                  "NixOS Wiki" = {
                    urls = [
                      {template = "https://nixos.wiki/index.php?search={searchTerms}";}
                    ];
                    iconUpdateURL = "https://nixos.wiki/favicon.png";
                    updateInterval = 24 * 60 * 60 * 1000;
                    definedAliases = ["@nw"];
                  };
                  "Google" = {
                    metadata = {
                      hidden = true;
                      alias = "@g";
                    };
                  };
                };
              };
              bookmarks = [
                {
                  name = "wikipedia";
                  tags = ["wiki"];
                  keyword = "wiki";
                  url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&amp;go=Go";
                }
                {
                  name = "kernel.org";
                  url = "https://www.kernel.org";
                }
                {
                  name = "Nix sites";
                  toolbar = true;
                  bookmarks = [
                    {
                      name = "homepage";
                      url = "https://nixos.org/";
                    }
                    {
                      name = "wiki";
                      tags = ["wiki" "nix"];
                      url = "https://wiki.nixos.org/";
                    }
                  ];
                }
              ];
              settings = {
                "general.smoothScroll" = true;
                "gfx.webrender.all" = true;
                "gfx.webrender.compositor" = true;
                "gfx.webrender.enabled" = true;
                "media.ffmpeg.vaapi.enabled" = true;
                "layers.acceleration.force-enabled" = true;
                "widget.use-xdg-desktop-portal" = true;
                "ui.context_menus.after_mouseup" = true;
                "browser.urlbar.suggest.quickactions" = false;
                "browser.urlbar.suggest.topsites" = false;
                "browser.download.useDownloadDir" = true;
                "browser.tabs.tabmanager.enabled" = false;
                "browser.contentblocking.category" = "strict";
                "browser.aboutConfig.showWarning" = false;
                "browser.tabs.warnOnClose" = false;
                "browser.aboutHomeSnippets.updateUrl" = "";
                "browser.bookmarks.showMobileBookmarks" = false;
                "browser.tabs.loadBookmarksInTabs" = false;
                "browser.toolbars.bookmarks.visibility" = "always";
                "network.protocol-handler.expose.magnet" = false;
                "network.dns.force_use_https_rr" = false;
                "browser.newtabpage.pinned" = [
                  {
                    title = "NixOS";
                    url = "https://nixos.org";
                  }
                ];
              };
              userChrome = ''
                # CSS
              '';
              userContent = ''
                # CSS
              '';
            };
          };
        };
      };
      xdg = {
        enable = cfg.firefox.enable;
        mimeApps = {
          enable = cfg.firefox.enable;
          associations = {
            added = {
              "x-scheme-handler/http" = ["firefox.desktop"];
              "x-scheme-handler/https" = ["firefox.desktop"];
              "x-scheme-handler/chrome" = ["firefox.desktop"];
              "text/html" = ["firefox.desktop"];
              "application/x-extension-htm" = ["firefox.desktop"];
              "application/x-extension-html" = ["firefox.desktop"];
              "application/x-extension-shtml" = ["firefox.desktop"];
              "application/xhtml+xml" = ["firefox.desktop"];
              "application/x-extension-xhtml" = ["firefox.desktop"];
              "application/x-extension-xht" = ["firefox.desktop"];
            };
          };
          defaultApplications = {
            "x-scheme-handler/http" = ["firefox.desktop"];
            "x-scheme-handler/https" = ["firefox.desktop"];
            "x-scheme-handler/chrome" = ["firefox.desktop"];
            "text/html" = ["firefox.desktop"];
            "application/x-extension-htm" = ["firefox.desktop"];
            "application/x-extension-html" = ["firefox.desktop"];
            "application/x-extension-shtml" = ["firefox.desktop"];
            "application/xhtml+xml" = ["firefox.desktop"];
            "application/x-extension-xhtml" = ["firefox.desktop"];
            "application/x-extension-xht" = ["firefox.desktop"];
          };
        };
        desktopEntries = {
          firefox = {
            name = "Firefox";
            genericName = "Web Browser";
            exec = "firefox %U";
            icon = "firefox";
            terminal = false;
            categories = ["Application" "Network" "WebBrowser"];
            mimeType = ["text/html" "text/xml"];
          };
        };
      };
    };
  }
