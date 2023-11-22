class Chuffed < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://github.com/chuffed/chuffed"
  url "https://github.com/chuffed/chuffed/archive/refs/tags/0.13.1.tar.gz"
  sha256 "7408d35e85559ecbf4b5b7ef8aa2278e536b1231dc29e18b0b2f9a7e878a1bc0"
  license "MIT"
  head "https://github.com/chuffed/chuffed.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, ventura:      "cd1b9533cebb22cb0e8a5188a80df535fea09b2272030cc943014c0913990f0d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e0add6fcf3f181e5c5b10826dfaf1ab215ab390278d0dacddcd0c7549c634f8b"
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
