class Chuffed < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://github.com/chuffed/chuffed"
  url "https://github.com/chuffed/chuffed/archive/refs/tags/0.12.0.tar.gz"
  sha256 "f7aaad123700848af14bbb505defb2e9d7ca0697eee4350c7a5cf36099202dea"
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
