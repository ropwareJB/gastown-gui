{ self }:
{ config, lib, pkgs, ... }:
let
  cfg = config.services.gastown-gui;
in {
  options.services.gastown-gui = {
    enable = lib.mkEnableOption "gastown-gui web service";

    package = lib.mkOption {
      type = lib.types.package;
      default = self.packages.${pkgs.system}.default;
      description = "Gastown GUI package to run.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host interface for the gastown-gui HTTP server.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 7667;
      description = "Port for the gastown-gui HTTP server.";
    };

    gtRoot = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/var/lib/gastown/gt";
      description = "Optional GT_ROOT path passed to gastown-gui.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Extra environment variables for the gastown-gui service.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.gastown-gui = {
      description = "Gastown GUI";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      environment = cfg.environment // lib.optionalAttrs (cfg.gtRoot != null) {
        GT_ROOT = toString cfg.gtRoot;
      };
      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} start --host ${cfg.host} --port ${toString cfg.port}";
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = "2s";
      };
    };
  };
}
