{ stdenv, fetchurl, perl, python, ruby, bison, gperf, cmake
, pkgconfig, gettext, gobjectIntrospection, libnotify
, gtk2, gtk3, wayland, libwebp, enchant
, libxml2, libsoup, libsecret, libxslt, harfbuzz, libpthreadstubs
, enableGeoLocation ? true, geoclue2, sqlite, xorg
, gst-plugins-base
}:

assert enableGeoLocation -> geoclue2 != null;

with stdenv.lib;
stdenv.mkDerivation rec {
  name = "webkitgtk-${version}";
  version = "2.10.4";

  meta = {
    description = "Web content rendering engine, GTK+ port";
    homepage = "http://webkitgtk.org/";
    license = licenses.bsd2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ iyzsong koral ];
  };

  preConfigure = "patchShebangs Tools";

  src = fetchurl {
    url = "http://webkitgtk.org/releases/${name}.tar.xz";
    sha256 = "0mghsbfnmmf6nsf7cb3ah76s77aigkzf3k6kw96wgh6all6jdy6v";
  };

  patches = [ ./finding-harfbuzz-icu.patch ];

  cmakeFlags = [ "-DPORT=GTK" "-DUSE_LIBHYPHEN=0" ];

  # XXX: WebKit2 missing include path for gst-plugins-base.
  # Filled: https://bugs.webkit.org/show_bug.cgi?id=148894
  NIX_CFLAGS_COMPILE = "-I${gst-plugins-base}/include/gstreamer-1.0";

  nativeBuildInputs = [
    cmake perl python ruby bison gperf sqlite
    pkgconfig gettext gobjectIntrospection
  ];

  buildInputs = [
    gtk2 wayland libwebp enchant libnotify
    libxml2 libsecret libxslt harfbuzz libpthreadstubs
    gst-plugins-base xorg.libXt
  ] ++ optional enableGeoLocation geoclue2;

  propagatedBuildInputs = [
    libsoup gtk3
  ];

  enableParallelBuilding = true;
}
