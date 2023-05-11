class Chuffed < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://github.com/chuffed/chuffed"
  url "https://github.com/chuffed/chuffed/archive/refs/tags/0.12.0.tar.gz"
  sha256 "f7aaad123700848af14bbb505defb2e9d7ca0697eee4350c7a5cf36099202dea"
  license "MIT"
  head "https://github.com/chuffed/chuffed.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, monterey:     "3d590f67ff602ac7f27ecbab5715cc9da0c959c2d464d7cfa40ca08e6a38d3ee"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "63c76fa289ccfc89e0c19abc288be429cb821a42084c54732b801bef07408761"
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
