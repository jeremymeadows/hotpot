{
  lib,
  pkgs,
  fetchurl,
  appimageTools,
}:

let
  pname = "hotpot";
  version = "1.0.1";

  src = fetchurl {
    url = "https://github.com/jeremymeadows/hotpot/releases/download/v${version}/hotpot-x86_64.appimage";
    hash = "sha256-Axu9AifsF3GiccoYTt/MlNCOU/3qxp0pltjR55id6Nk=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [ ];

  extraInstallCommands = ''
    install -Dm444 "${appimageContents}/${pname}.desktop" "$out/share/applications/${pname}.desktop"
    install -Dm444 "${appimageContents}/${pname}.png" "$out/share/icons/hicolor/256x256/apps/${pname}.png"
    substituteInPlace "$out/share/applications/${pname}.desktop" --replace "Exec=AppRun" "Exec=${pname}-linux-x86_64"
  '';

  meta = {
    description = "Hotpot card game";
    homepage = "https://github.com/jeremymeadows/hotpot";
    downloadPage = "https://github.com/jeremymeadows/hotpot/releases";
    maintainers = with lib.maintainers; [ jeremymeadows ];
    # license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
  };
}
