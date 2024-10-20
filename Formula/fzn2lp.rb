class Fzn2lp < Formula
  desc "Converter from FlatZinc into an ASP fact format"
  homepage "https://github.com/potassco/fzn2lp"
  url "https://github.com/potassco/fzn2lp/archive/refs/tags/v0.1.6.tar.gz"
  sha256 "bded501f3207e986501c42ceac466eb22ca5236350e19480958e0017b376f52d"
  license "MIT"
  head "https://github.com/potassco/fzn2lp.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "cb2e7850b7236d99b6faa2eff9661e65ed3087044b7cfaf7c8d626d9b2ac9cb7"
    sha256 cellar: :any_skip_relocation, ventura:      "9267efb06ffe50455bb607cb97bab2a6de2894b26338c7a5d291d3b37bbd94f2"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f93d54aaf101a0c1bb18889c3d3e11b4eccea93d5a3d45a377867c6ff6e6bd53"
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
