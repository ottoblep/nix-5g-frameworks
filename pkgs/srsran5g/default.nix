{ gcc11Stdenv
, lib
, cmake
, fetchFromGitHub
, pkg-config
, fftwFloat
, mbedtls
, boost
, lksctp-tools
, libconfig
, pcsclite
, uhd
, soapysdr-with-plugins
, libbladeRF
, zeromq
, gtest
, yaml-cpp
}:

# This derivation fails currently
# New glibc version 2.38 instead of 2.35 has sctp included which results in a redefinition error
gcc11Stdenv.mkDerivation rec {
  pname = "srsran";
  version = "23.10.1";

  src = fetchFromGitHub {
    owner = "srsran";
    repo = "srsRAN_Project";
    rev = "release_${builtins.replaceStrings ["."] ["_"] version}";
    sha256 = "sha256-GJjArjjJI8a2um4WhEBpF/2jjlVWxQZy4S1jrM2zhXQ=";
  };

  nativeBuildInputs = [ gtest cmake pkg-config ];

  cmakeFlags = [
    "-DENABLE_ZEROMQ=ON"
    "-DENABLE_EXPORT=ON"
  ];

  buildInputs = [
    yaml-cpp
    fftwFloat
    mbedtls
    boost
    libconfig
    lksctp-tools
    pcsclite
    uhd
    soapysdr-with-plugins
    libbladeRF
    zeromq
  ];

  meta = with lib; {
    homepage = "https://www.srslte.com/";
    description = "Open-source 4G and 5G software radio suite.";
    license = licenses.gpl3;
    platforms = with platforms; linux ;
    maintainers = with maintainers; [ hexagonal-sun ];
  };
}