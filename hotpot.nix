{
  lib,
  pkgs,
  fetchurl,
  appimageTools,
}:

let
  pname = "hotpot";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/jeremymeadows/hotpot/releases/download/v${version}/hotpot-x86_64.appimage";
    hash = "sha256-9cE7H56kMUfYEr+57xxcCENd7DTT8RA4oxzwGeKP4w4=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [ ];

  extraInstallCommands = ''
    install -Dm444 "${appimageContents}/${pname}.desktop" "$out/share/applications/${pname}.desktop"
    install -Dm444 "${appimageContents}/${pname}.png" "$out/share/icons/hicolor/256x256/apps/${pname}.png"
  '';

  meta = {
    description = "Hotpot card game";
    homepage = "https://github.com/jeremymeadows/hotpot";
    downloadPage = "https://github.com/jeremymeadows/hotpot/releases";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ jeremymeadows ];
    platforms = [ "x86_64-linux" ];
  };
}