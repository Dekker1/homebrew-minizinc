class Findmus < Formula
  desc "Tool to find minimal unsatisfiable subsets of constraints in a MiniZinc instance"
  homepage "https://gitlab.com/minizinc/FindMUS"
  url "https://gitlab.com/minizinc/FindMUS.git",
    revision: "8abdc8039657ef6277be8b34c3e83ea77bedaa70"
  version "0.7.0"
  license "MPL-2.0"
  head "https://gitlab.com/minizinc/FindMUS.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    rebuild 1
    sha256 cellar: :any,                 big_sur:      "b7442e71744d1898257b807ea8e12b6920621eb5ca03907d223c17d2af20ca6b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "fbaa7bf8431366dd02d339333327c004cd0ab401d6c4f68571787e0664a1fdea"
  end

  depends_on "cmake" => :build
  depends_on "minizinc"

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
