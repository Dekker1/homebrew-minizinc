class Fzn2lp < Formula
  desc "Converter from FlatZinc into an ASP fact format"
  homepage "https://github.com/potassco/fzn2lp"
  url "https://github.com/potassco/fzn2lp/archive/refs/tags/v0.1.6.tar.gz"
  sha256 "bded501f3207e986501c42ceac466eb22ca5236350e19480958e0017b376f52d"
  license "MIT"
  head "https://github.com/potassco/fzn2lp.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "1cf8cc62b48eabe4b07fb22cf57be06fcea64a0ad3d624160c20912a90b09a04"
    sha256 cellar: :any,                 x86_64_linux: "6c11b35c1b3f76b18cb9a5ebffb63eb7242796456689717e604a52f66d64483c"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--bin", "fzn2lp", *std_cargo_args
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_equal "variable_type(\"x1\",bool).\nsolve(satisfy).", shell_output("#{bin}/fzn2lp test.fzn").strip
  end
end
