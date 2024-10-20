class Fzn2lp < Formula
  desc "Converter from FlatZinc into an ASP fact format"
  homepage "https://github.com/potassco/fzn2lp"
  url "https://github.com/potassco/fzn2lp/archive/refs/tags/v0.1.6.tar.gz"
  sha256 "bded501f3207e986501c42ceac466eb22ca5236350e19480958e0017b376f52d"
  license "MIT"
  head "https://github.com/potassco/fzn2lp.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, ventura:      "6ea941b44ea76062ad3404d1ad17aaa09feeca8cdbf7c3b1601e33523d87ed92"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "582e839d88d428caf63d0ff6b43bf15b18a74a6cab8480143e30be91591a5084"
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
