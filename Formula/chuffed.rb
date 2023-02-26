class Chuffed < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://github.com/chuffed/chuffed"
  url "https://github.com/chuffed/chuffed/archive/refs/tags/0.11.0.tar.gz"
  sha256 "9c65de6224053a9325b216bcb2f2a78f84884bbd9eee54d9e0d0f0cf625f2a7b"
  license "MIT"
  head "https://github.com/chuffed/chuffed.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    rebuild 1
    sha256 cellar: :any_skip_relocation, big_sur:      "6d861a59affb6fd7aca25d91939df4349b9366971a8262b0c2858a480ef63778"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d967eb753f9c37fe542ec9cc764b5fbd34c42456a452c1de3e33105c3f1cf640"
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
