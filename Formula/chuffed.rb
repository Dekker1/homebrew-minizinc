class Chuffed < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://github.com/chuffed/chuffed"
  url "https://github.com/chuffed/chuffed/archive/refs/tags/0.10.4.tar.gz"
  sha256 "f7e7028d5a6b0d936f39d33e1e70ff71ccd34e39a5728928699132b213e52fde"
  license "MIT"
  head "https://github.com/chuffed/chuffed.git", branch: "master"

  depends_on "cmake" => :build

  def install
    mkdir "build" do
      system "cmake", "..", *std_cmake_args
      system "cmake", "--build", ".", "--target", "install"
    end
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_equal "----------", shell_output("#{bin}/fzn-chuffed test.fzn").strip
  end
end
