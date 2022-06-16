class Findmus < Formula
  desc "Tool to find minimal unsatisfiable subsets of constraints in a MiniZinc instance"
  homepage "https://gitlab.com/minizinc/FindMUS"
  url "https://gitlab.com/minizinc/FindMUS/-/archive/8abdc8039657ef6277be8b34c3e83ea77bedaa70/FindMUS-8abdc8039657ef6277be8b34c3e83ea77bedaa70.tar.gz"
  version "0.7.0"
  sha256 "d9e4f164303e3b8cf9b78e06b019a691b797e229fdd2c8882a90239155ab1216"
  license "MPL-2.0"
  head "https://gitlab.com/minizinc/FindMUS.git", branch: "master"

  depends_on "cmake" => :build
  depends_on "minizinc"

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "cmake", "--build", ".", "--target", "install"
    end
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
