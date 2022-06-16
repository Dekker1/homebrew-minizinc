class Chuffed < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://github.com/chuffed/chuffed"
  url "https://github.com/chuffed/chuffed/archive/refs/tags/0.10.4.tar.gz"
  sha256 "f7e7028d5a6b0d936f39d33e1e70ff71ccd34e39a5728928699132b213e52fde"
  license "MIT"
  head "https://github.com/chuffed/chuffed.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, big_sur:      "b390bba3aebc3e89291fdd8ff2d64b513be27f789c02dd93cf680884c178b934"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "13d9317e356b582f5f4d5b50f048d7ddd8258129c52102e628e9f0928e6e34e2"
  end

  depends_on "cmake" => :build

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_equal "----------", shell_output("#{bin}/fzn-chuffed test.fzn").strip
  end
end
