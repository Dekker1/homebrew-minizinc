class FznChuffed < Formula
  desc "Chuffed FlatZinc Solver"
  homepage "https://github.com/chuffed/chuffed"
  url "https://github.com/chuffed/chuffed/archive/af110a7680849a4a31ba8d2fb6dbdb9dd0e897c3.tar.gz"
  version "0.10.4"
  sha256 "01c1411767edaf0f5d20d5df2177a7b64bdb9d6b9d766c9b4e7cca8fc6eed440"
  license "MIT"
  head "https://github.com/chuffed/chuffed.git", branch: "develop"

  depends_on "cmake" => :build

  def install
    inreplace "chuffed.msc.in" do |s|
      s.gsub! "org.chuffed.chuffed", "org.homebrew-minizinc.chuffed"
      s.gsub! "\"Chuffed\"", "\"Chuffed (Homebrew)\""
    end

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
