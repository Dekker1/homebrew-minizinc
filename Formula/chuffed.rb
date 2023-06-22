class Chuffed < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://github.com/chuffed/chuffed"
  url "https://github.com/chuffed/chuffed/archive/refs/tags/0.12.1.tar.gz"
  sha256 "f84a4b5efe176b95c2cf9c58e00a57b0f4c2674b90640e263c07c9de29372ece"
  license "MIT"
  head "https://github.com/chuffed/chuffed.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, monterey:     "f585acb7c8e5d1526d5c3aa06a937948892822558936fab9cde0baf098e17831"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "536db8dd333c254d8f97145217a77f705b92f07f545c1a05858a931095fef34c"
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
