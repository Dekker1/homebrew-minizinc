class Papilo < Formula
  desc "Parallel presolve routines for (mixed integer) linear programming problems"
  homepage "https://github.com/scipopt/papilo"
  url "https://github.com/scipopt/papilo/archive/refs/tags/v2.1.2.tar.gz"
  sha256 "7e3d829c957767028db50b5c5085601449b00671e7efc2d5eb0701a6903d102f"
  license "LGPL-3.0-or-later"
  head "https://github.com/scipopt/papilo.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any,                 monterey:     "a232570421a87a52e1600e7fdc9f5050f19acf131fd23ad2436d2d62823ce352"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "5d7940a66197cee2c61fbbbe64401f20b4063b1b7bea647e0088abb4df241c2b"
  end

  depends_on "cmake" => :build

  depends_on "boost"
  depends_on "gcc"
  depends_on "openblas" if OS.linux?
  depends_on "tbb"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.mps").write <<~EOS
      NAME          TESTPROB
      ROWS
        N  OBJ
        G  CON1
        G  CON2
      COLUMNS
          XONE      CON1                 1   CON2                 1
          XONE      OBJ                  1
          YTWO      CON1                 1   CON2                -1
          YTWO      OBJ                  2
      RHS
          RHS1      CON1                 1   CON2                -1
      BOUNDS
        LO BND1      XONE                 0
        LO BND1      YTWO                 0
      ENDATA
    EOS
    assert_match "presolving finished", shell_output("#{bin}/papilo presolve -f #{testpath}/test.mps").strip
  end
end
