class Blast < Formula
  desc "Basic Local Alignment Search Tool"
  homepage "http://blast.ncbi.nlm.nih.gov/"
  # doi "10.1016/S0022-2836(05)80360-2"
  # tag "bioinformatics"

  url "ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.3.0/ncbi-blast-2.3.0+-src.tar.gz"
  mirror "http://mirrors.vbi.vt.edu/mirrors/ftp.ncbi.nih.gov/blast/executables/blast+/2.3.0/ncbi-blast-2.3.0+-src.tar.gz"
  version "2.3.0"
  sha256 "7ce8dc62f58141b6cdcd56b55ea3c17bea7a672e6256dfd725e6ef94825e94e9"

  bottle do
    sha256 "b0e39942bafa2b3305043d5dd43ddc0e63636bfe98342a69502dfa2ac9919eea" => :el_capitan
    sha256 "9518aa8bce05ae78120c1b0d8c2450bc1b117105814404d9cbcc020fa9c4a41b" => :yosemite
    sha256 "b19893de12e222d793c65013904680273e4de920d6b193d2f3bea272e20201df" => :mavericks
  end

  option "without-static", "Build without static libraries & binaries"
  option "with-dll", "Build dynamic libraries"
  option "without-check", "Skip the self tests (Boost not needed)"

  depends_on "boost" if build.with? "check"
  depends_on "freetype" => :optional
  depends_on "gnutls"   => :optional
  depends_on "hdf5"     => :optional
  depends_on "jpeg"     => :recommended
  depends_on "libpng"   => :recommended
  depends_on "lzo"      => :optional
  depends_on "pcre"     => :recommended
  depends_on :mysql     => :optional
  depends_on :python if MacOS.version <= :snow_leopard

  def install
    # Move libraries to libexec. Libraries and headers conflict with ncbi-c++-toolkit.
    args = %W[--prefix=#{prefix} --libdir=#{libexec} --without-debug --with-mt]

    args << (build.with?("mysql") ? "--with-mysql" : "--without-mysql")
    args << (build.with?("freetype") ? "--with-freetype=#{Formula["freetype"].opt_prefix}" : "--without-freetype")
    args << (build.with?("gnutls") ? "--with-gnutls=#{Formula["gnutls"].opt_prefix}" : "--without-gnutls")
    args << (build.with?("jpeg")   ? "--with-jpeg=#{Formula["jpeg"].opt_prefix}" : "--without-jpeg")
    args << (build.with?("libpng") ? "--with-png=#{Formula["libpng"].opt_prefix}" : "--without-png")
    args << (build.with?("pcre")   ? "--with-pcre=#{Formula["pcre"].opt_prefix}" : "--without-pcre")
    args << (build.with?("hdf5")   ? "--with-hdf5=#{Formula["hdf5"].opt_prefix}" : "--without-hdf5")

    if build.without? "static"
      args << "--with-dll" << "--without-static" << "--without-static-exe"
    else
      args << "--with-static"
      args << "--with-static-exe" unless OS.linux?
      args << "--with-dll" if build.with? "dll"
    end

    # Boost is used only for unit tests.
    args << (build.with?("check") ? "--with-check" : "--without-boost")

    cd "c++" do
      system "./configure", *args
      system "make"
      system "make", "install"

      # Remove headers. Libraries and headers conflict with ncbi-c++-toolkit.
      rm_r include
    end
  end

  def caveats; <<-EOS.undent
    Using the option '--without-static' will create dynamic binaries instead of
    static. The NCBI Blast static installation is approximately 7 times larger
    than the dynamic.

    Static binaries should be used for speed if the executable requires
    fast startup time, such as if another program is frequently restarting
    the blast executables.
    EOS
  end

  test do
    system bin/"blastn", "-version"
  end
end
