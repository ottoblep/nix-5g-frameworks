{ stdenv, lib, fetchFromGitHub, kernel, kmod }:
stdenv.mkDerivation rec {
  name = "gtp5g-${version}-${kernel.version}";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "free5gc";
    repo = "gtp5g";
    rev = "v${version}";
    sha256 = "sha256-xSldmXiIeyPE5WYM+R41DoZWWsb0JErZ38nRQawtBdo=";
  };

  # sourceRoot = "source/linux/gtp5g";
  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KVER=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "DESTDIR=$(out)"
  ];

  configurePhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net
  '';

  installPhase = ''
    cp gtp5g.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net
  '';

  meta = with lib; {
    description = "A customized Linux kernel module gtp5g to handle packet by PFCP IEs such as PDR and FAR.";
    homepage = "https://github.com/free5gc/gtp5g";
    license = licenses.gpl2;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
