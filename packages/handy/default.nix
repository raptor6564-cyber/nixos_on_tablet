{ lib, stdenv, fetchurl, appimageTools
}:

let
  pname = "handy";
  version = "0.9.6";

  appimage = fetchurl {
    url = "https://github.com/cjpais/Handy/releases/download/v${version}/Handy_${version}_amd64.AppImage";
    hash = "sha256-xlL2lXLMhGMC12B2GYoHtNYrX3tUgoWTNSdYSjxi9P0=";
  };

  # Распаковка + патч через postExtract (официальный крючок)
  contents = appimageTools.extract {
    inherit pname version;
    src = appimage;
    postExtract = ''
      chmod -R u+w $out
      substituteInPlace $out/apprun-hooks/linuxdeploy-plugin-gtk.sh \
        --replace-fail 'export GDK_BACKEND=x11' 'export GDK_BACKEND=wayland'
    '';
  };

  # Обёртка: передаём src = contents (ОБЯЗАТЕЛЬНО!)
  wrapped = appimageTools.wrapAppImage {
    inherit pname version;
    src = contents;
    extraPkgs = pkgs: with pkgs; [
      glib-networking libayatana-appindicator pipewire alsa-lib
    ];
  };
in
# Финальная обёртка для .desktop и иконок
stdenv.mkDerivation {
  inherit pname version;
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor
    ln -s ${wrapped}/bin/${pname} $out/bin/${pname}
    cp ${contents}/Handy.desktop $out/share/applications/
    cp -r ${contents}/usr/share/icons/hicolor/* $out/share/icons/hicolor/
    sed -i "s|^Exec=.*|Exec=${pname}|g" $out/share/applications/Handy.desktop
    sed -i "/^TryExec=/d" $out/share/applications/Handy.desktop
  '';
  meta.mainProgram = pname;
}
