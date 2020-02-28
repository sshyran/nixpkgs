{ stdenv, lib, fetchurl, openssl, fetchpatch, static ? false }:

let
  pkgname = "ipmitool";
  version = "1.8.18";
in
stdenv.mkDerivation {
  name = "${pkgname}-${version}";

  src = fetchurl {
    url = "mirror://sourceforge/${pkgname}/${pkgname}-${version}.tar.gz";
    sha256 = "0kfh8ny35rvwxwah4yv91a05qwpx74b5slq2lhrh71wz572va93m";
  };

  patches = [
    (fetchpatch {
      url = "https://sources.debian.org/data/main/i/ipmitool/1.8.18-6/debian/patches/0120-openssl1.1.patch";
      sha256 = "1xvsjxb782lzy72bnqqnsk3r5h4zl3na95s4pqn2qg7cic2mnbfk";
    })
  ];

  buildInputs = [ openssl ];

  configureFlags = [
    "--infodir=${placeholder "out"}/share/info"
    "--mandir=${placeholder "out"}/share/man"
  ] ++ stdenv.lib.optionals static [
    "LDFLAGS=-static"
    "--enable-static"
    "--disable-shared"
  ] ++ stdenv.lib.optionals (!static) [
    "--enable-shared"
  ];

  makeFlags = stdenv.lib.optional static "AM_LDFLAGS=-all-static";
  dontDisableStatic = static;

  meta = with lib; {
    description = ''Command-line interface to IPMI-enabled devices'';
    license = licenses.bsd3;
    homepage = https://sourceforge.net/projects/ipmitool/;
    platforms = platforms.linux;
    maintainers = with maintainers; [ fpletz ];
  };
}
