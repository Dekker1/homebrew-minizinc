class Chuffed < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://github.com/chuffed/chuffed"
  url "https://github.com/chuffed/chuffed/archive/refs/tags/0.13.1.tar.gz"
  sha256 "7408d35e85559ecbf4b5b7ef8aa2278e536b1231dc29e18b0b2f9a7e878a1bc0"
  license "MIT"
  head "https://github.com/chuffed/chuffed.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, ventura:      "bd3a046d20438dc0e4a8d1f8b3869def5e0e54448334600794689302ec3af661"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "7fcb448133c1d362e968121b1ab9d604d0db0a6cf28f82b89bec4395f1cd7b5d"
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
