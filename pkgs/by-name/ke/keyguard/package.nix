{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle,
  binutils,
  fakeroot,
  jdk17,
  fontconfig,
  autoPatchelfHook,
  libXinerama,
  libXrandr,
  file,
  gtk3,
  glib,
  cups,
  lcms2,
  alsa-lib,
  makeDesktopItem,
  copyDesktopItems,
}:
stdenv.mkDerivation (finalAttrs: rec {
  pname = "keyguard";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "AChep";
    repo = "keyguard-app";
    tag = "r20241212.2";
    hash = "sha256-3i2+zs75Fq3wV894AkWyhj0uSw8BDDBjU/Y0+IBpnNE=";
  };

  gradleBuildTask = ":desktopApp:createDistributable";

  gradleUpdateTask = gradleBuildTask;

  desktopItems = [
    (makeDesktopItem {
      name = "keyguard";
      exec = "Keyguard";
      icon = "keyguard";
      comment = "Keyguard";
      desktopName = "Keyguard";
    })
  ];

  nativeBuildInputs = [
    gradle
    binutils
    fakeroot
    jdk17
    autoPatchelfHook
    copyDesktopItems
  ];

  mitmCache = gradle.fetchDeps {
    inherit (finalAttrs) pname;
    data = ./deps.json;
    silent = false;
    useBwrap = false;
  };

  doCheck = false;

  __darwinAllowLocalNetworking = true;

  gradleFlags = [ "-Dorg.gradle.java.home=${jdk17}" ];

  env.JAVA_HOME = jdk17;

  buildInputs = [
    fontconfig
    libXinerama
    libXrandr
    file
    gtk3
    glib
    cups
    lcms2
    alsa-lib
  ];

  installPhase = ''
    runHook preInstall

    cp -r ./desktopApp/build/compose/binaries/main/app/Keyguard $out
    install -Dm0644 $out/lib/Keyguard.png $out/share/pixmaps/keyguard.png

    runHook postInstall
  '';

  meta = {
    description = "Alternative client for the Bitwarden platform, created to provide the best user experience possible";
    homepage = "https://github.com/AChep/keyguard-app";
    mainProgram = "Keyguard";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ aucub ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryBytecode
    ];
    platforms = lib.platforms.linux;
  };
})
