class Chuffed < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://github.com/chuffed/chuffed"
  url "https://github.com/chuffed/chuffed/archive/refs/tags/0.11.0.tar.gz"
  sha256 "9c65de6224053a9325b216bcb2f2a78f84884bbd9eee54d9e0d0f0cf625f2a7b"
  license "MIT"
  head "https://github.com/chuffed/chuffed.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, monterey:     "4871b4a36dd7a2419845a991d462c74e33b855bfec29eda152c21aa066e9e5a5"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "777dcd5f024196405b54301bb7430898d6f243f1f9abcccc4e756e6323542738"
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
