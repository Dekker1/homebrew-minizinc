class Clingcon < Formula
  desc "Answer set solver for constraint logic programs built upon clingo"
  homepage "https://potassco.org/"
  url "https://github.com/potassco/clingcon/archive/refs/tags/v5.2.1.tar.gz"
  sha256 "ff17294757f3f3f2420acd2145fe9cb039b9aaeace428f546fee3896b00ef724"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    rebuild 1
    sha256 cellar: :any, arm64_tahoe:  "4ac8a8f95f65a29707ae436fab8608176e3fd82d7d03a6e4e725992e16c3fcfe"
    sha256 cellar: :any, x86_64_linux: "86fb257b2de9bcf8bddafb62e8e2db198e5f8500b936c9b3dd22895dd2f5cf7b"
  end

  depends_on "cmake" => :build
  depends_on "python@3.12" => :build
  depends_on "clingo"

  def python
    deps.map(&:to_formula)
        .find { |f| f.name.match?(/^python@\d\.\d+$/) }
        .opt_libexec/"bin/python"
  end

  def install
    system "cmake", "-S", ".", "-B", "build",
           "-DPYCLINGCON_INSTALL_DIR=#{prefix/Language::Python.site_packages(python)}/lib/python3.9/site-packages",
           *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match(/clingcon version/, shell_output("#{bin}/clingcon --help").strip)

    # TODO: This is a better test, but clingcon exits 10 even though it finishes correctly
    # (testpath/"queens.lp").write <<~EOS
    #   #const n = 4.
    #   p(1..n).
    #   &dom { 1..n } = q(N) :- p(N).
    #   &distinct { q(N)+0 : p(N) }.
    #   &distinct { q(N)-N : p(N) }.
    #   &distinct { q(N)+N : p(N) }.
    # EOS

    # assert_match(/SATISFIABLE/, shell_output("#{bin}/clingcon queens.lp").strip)
  end
end
