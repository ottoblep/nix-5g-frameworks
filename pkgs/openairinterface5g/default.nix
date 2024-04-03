{ lib
, stdenv
, fetchFromGitLab
, fetchFromGitHub
, ninja
, cmake
, asn1c
, pkg-config
, vim
, atlas
, lapack
, readline
, libconfig
, lksctp-tools
, libffi
, openssl
, libtool
, unixtools
, blas
, simde
, zlib
, # For asn1c
  automake115x
, autoconf
, ccache
, bison
, flex
, perl
, # Config
  with_eNB ? false
, with_gNB ? true
, with_RU ? false
, with_UE ? false
, with_nrUE ? false
, with_sim ? false
, ...
  # TODO: Options are missing here
}:
let
  pname = "openairinterface5g";
  version = "2.1.0";

  asn1c = stdenv.mkDerivation {
    pname = "asn1c";
    version = "fa46ff2";

    src = fetchFromGitHub {
      owner = "mouse07410";
      repo = "asn1c";
      rev = "vlm_master";
      sha256 = "sha256-afDsDE3VHHys9SjXOEF7SJ2zu3QHoTAboDtknJlIgMA=";
    };

    configurePhase =
      '' 
        patchShebangs ./examples/crfc2asn1.pl
        test -f configure || autoreconf -iv
        ./configure --prefix=$out
      '';

    enableParallelBuild = true;

    nativeBuildInputs = [
      automake115x
      autoconf
      ccache
      libtool
      bison
      flex
      perl
    ];
  };

  # simde-oai = simde.overrideAttrs {
  #   version = "v0.8.0";

  #   src = fetchFromGitHub {
  #     owner = "simd-everywhere";
  #     repo = "simde";
  #     rev = "v0.8.0";
  #     hash = "sha256-hQtSxO8Uld6LT6V1ZhR6tbshTK1QTGgyQ99o3jOIbQk=";
  #   };

  #   mesonFlags = [
  #     "-Dtests=false"
  #   ];
  # };

  base_build_targets = "params_libconfig coding rfsimulator dfts ";
  extra_build_targets = "" +
    lib.optionalString with_eNB "lte-softmodem " +
    lib.optionalString with_gNB "nr-softmodem nr-cuup " +
    lib.optionalString with_RU "oairu " +
    lib.optionalString with_UE "lte-uesoftmodem " +
    lib.optionalString with_nrUE "nr-uesoftmodem " +
    lib.optionalString with_sim "dlsim ulsim ldpctest polartest smallblocktest nr_pbchsim nr_dlschsim nr_ulschsim nr_dlsim nr_ulsim nr_pucchsim nr_prachsim ";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitLab {
    domain = "gitlab.eurecom.fr";
    owner = "oai";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-VnvSu6PwlYx9FQHrxPy8Q4qEBvnpgb9OSGwjfJLTHoc=";
  };

  # We don't use the build_oai script but call cmake directly
  # This is kind of supported
  # https://gitlab.eurecom.fr/oai/openairinterface5g/-/blob/v2.1.0/doc/BUILD.md#running-cmake-directly

  enableParallelBuild = true;

  # Something introduces arch dependent flags (in this case -DAVX2) into gcc flags which breaks the SIMDE abstraction 
  # TODO: This makes the package impure 
  NIX_ENFORCE_NO_NATIVE = 0;

  cmakeFlags = [
    "-GNinja"
  ];

  # Alternative: cmake --build . --target ${base_build_targets + extra_build_targets} -j $NIX_BUILD_CORES
  buildPhase = ''
    ninja ${base_build_targets + extra_build_targets}
  '';

  installPhase = ''
    mkdir -p $out/bin $out/lib
    install -Dm755 -t $out/bin ${extra_build_targets} 
    install -Dm644 -t $out/lib *.so
  '';

  nativeBuildInputs = [
    ninja
    cmake
    asn1c
    pkg-config
    vim
  ];

  buildInputs = [
    atlas
    lapack
    readline
    libconfig
    lksctp-tools
    libffi
    openssl
    libtool
    unixtools.xxd
    blas
    simde
    zlib
  ];

  meta = with lib; {
    homepage = "https://openairinterface.org/oai-5g-ran-project/";
    description = "OpenAirInterface 5G Radio Access Network Project";
    # TODO: Apache license has been modified by OAI
    license = licenses.asl20;
    platforms = with platforms; linux;
    maintainers = with maintainers; [ ];
  };
}
