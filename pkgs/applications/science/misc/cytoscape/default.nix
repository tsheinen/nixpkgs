{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
  replaceVars,
  coreutils,
}:

stdenv.mkDerivation rec {
  pname = "cytoscape";
  version = "3.10.3";

  src = fetchurl {
    url = "https://github.com/cytoscape/cytoscape/releases/download/${version}/${pname}-unix-${version}.tar.gz";
    sha256 = "sha256-62i3F6uGNoC8z55iUIYQDAimWcQocsZ52USdpruZRLQ=";
  };

  patches = [
    # By default, gen_vmoptions.sh tries to store custom options in $out/share
    # at run time. This patch makes sure $HOME is used instead.
    (replaceVars ./gen_vmoptions_to_homedir.patch {
      inherit coreutils;
    })
  ];

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ jre ];

  installPhase = ''
    mkdir -pv $out/{share,bin}
    cp -Rv * $out/share/

    ln -s $out/share/cytoscape.sh $out/bin/cytoscape

    wrapProgram $out/share/cytoscape.sh \
      --set JAVA_HOME "${jre}" \
      --set JAVA  "${jre}/bin/java"

    chmod +x $out/bin/cytoscape
  '';

  meta = {
    homepage = "http://www.cytoscape.org";
    description = "General platform for complex network analysis and visualization";
    mainProgram = "cytoscape";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.mimame ];
    platforms = lib.platforms.unix;
  };
}
