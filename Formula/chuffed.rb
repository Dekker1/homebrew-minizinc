class Chuffed < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://github.com/chuffed/chuffed"
  url "https://github.com/chuffed/chuffed/archive/refs/tags/0.13.2.tar.gz"
  sha256 "39426a580690759ecf77ec5704caf5f2e21d41ff0aa09028827f5156bf5cb978"
  license "MIT"
  head "https://github.com/chuffed/chuffed.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "6222a6b1cd0c2b0b0fe9531e22876a00720983ceb1e7a348737d8a7045835191"
    sha256 cellar: :any_skip_relocation, ventura:      "05155a13d9377e2a982925f978b1027847c53d847cb4c402ad194184074b4bef"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "17b228b49295cf9f5da4e32e30ca6c0cecbd96f59c5905845ceb03260cda264c"
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
