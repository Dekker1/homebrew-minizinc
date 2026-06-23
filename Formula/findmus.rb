class Findmus < Formula
  desc "Tool to find minimal unsatisfiable subsets of constraints in a MiniZinc instance"
  homepage "https://gitlab.com/minizinc/FindMUS"
  url "https://gitlab.com/minizinc/FindMUS.git",
    revision: "d986e4e114a11eddb7def41837f900e00845a800"
  version "0.7.0"
  license "MPL-2.0"
  head "https://gitlab.com/minizinc/FindMUS.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    rebuild 2
    sha256 arm64_tahoe:  "2bd53efc85543579e0505fcd73108203a1f5c2f95c4f75fcf779c162e11dce03"
    sha256 x86_64_linux: "27ae696b9940d848c52b99900cf46bccd8fdca4667f251b9ad279e13f32267e9"
  end

  depends_on "cmake" => :build
  # cbc, cgl, clp, coinutils, gecode and osi are minizinc dependencies that the
  # findmus binary links against transitively.
  depends_on "cbc"
  depends_on "cgl"
  depends_on "clp"
  depends_on "coinutils"
  depends_on "gecode"
  depends_on "minizinc"
  depends_on "osi"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.mzn").write <<~EOS
      var 1..10: x;
      var 1..10: y;

      constraint x < y;
      constraint y < x;
    EOS

    assert_match(/MUS: 0 1/, shell_output("minizinc --solver findmus test.mzn").strip)
  end
end
