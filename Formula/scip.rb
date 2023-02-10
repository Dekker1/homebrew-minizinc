class Scip < Formula
  desc "Fast academically developed solver and framework for MIP and MINLP"
  homepage "https://www.scipopt.org"
  url "https://github.com/scipopt/scip/archive/refs/tags/v803.tar.gz"
  version "8.0.3"
  sha256 "fe7636f8165a8c9298ff55ed3220d084d4ea31ba9b69d2733beec53e0e4335d6"
  license "Apache-2.0"
  head "https://github.com/scipopt/scip.git", branch: "master"

  depends_on "cmake" => :build

  depends_on "gcc"
  depends_on "gmp"
  depends_on "papilo"
  depends_on "soplex"
  depends_on "tbb"
  depends_on "zlib"

  def install
    system "cmake", "-S", ".", "-B", "build", "-D", "ZIMPL=OFF", "-D", "IPOPT=OFF", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_match "optimal solution found", shell_output("#{bin}/scip -f test.fzn").strip
  end
end
