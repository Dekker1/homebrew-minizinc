class Clingcon < Formula
  desc "Answer set solver for constraint logic programs built upon clingo"
  homepage "https://potassco.org/"
  url "https://github.com/potassco/clingcon/archive/refs/tags/v5.2.1.tar.gz"
  sha256 "ff17294757f3f3f2420acd2145fe9cb039b9aaeace428f546fee3896b00ef724"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any,                 ventura:      "c67fd7b5e54391d87699944510f47665826290fea3efb73e6ff153ae74a8f8f0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c8db2e8811fe35c5466cc3ec568350545c541f0bce68455053d69f35e5eec5e8"
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
