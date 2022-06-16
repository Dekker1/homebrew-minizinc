class Fzn2lp < Formula
  desc "Converter from FlatZinc into an ASP fact format"
  homepage "https://github.com/potassco/fzn2lp"
  url "https://github.com/potassco/fzn2lp/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "00358ce7518ce939dcc3b1ee6e981e97000d4f941f4539a18a1d6e9dba52567d"
  license "MIT"
  head "https://github.com/potassco/fzn2lp.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, big_sur:      "c7efd7779e0fec0bb8457536104daf1398fbd26ac6475e09e7e287a8aa10f666"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1ea8fcfc649cd7f2a5bccd3503270dc35b0d23a9be33997b8115b27117541082"
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
