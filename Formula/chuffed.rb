class Chuffed < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://github.com/chuffed/chuffed"
  url "https://github.com/chuffed/chuffed/archive/refs/tags/0.13.2.tar.gz"
  sha256 "39426a580690759ecf77ec5704caf5f2e21d41ff0aa09028827f5156bf5cb978"
  license "MIT"
  head "https://github.com/chuffed/chuffed.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "3cf1d7625618fa86eb4a07e7bd0f9fc5a7ff58b0717844806997e7392fc74993"
    sha256 cellar: :any_skip_relocation, sequoia:      "1fe6d533282540b65b7868c769f573f6b67a219cc7204d1c7ba993085ed29098"
    sha256 cellar: :any,                 x86_64_linux: "64701e15a33dc90e2870cffeed57ebb07d1426d7f4ad0995fa6be85f16aed52a"
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
