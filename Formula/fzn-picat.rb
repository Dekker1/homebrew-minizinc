class FznPicat < Formula
  desc "FlatZinc solver based on the Picat Language SAT Engine"
  homepage "http://picat-lang.org"
  url "https://github.com/nfzhou/fzn_picat/archive/e32c8a0ec02c4ebcfdab3ee53b0f76fca424b79e.tar.gz"
  version "3.0.2"
  sha256 "aac52c4853572999be199d2571405b389ea6d1317bc37983d79c597fce6b389e"
  license "MPL-2.0"
  revision 1
  head "https://github.com/nfzhou/fzn_picat.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, big_sur:      "c7efd7779e0fec0bb8457536104daf1398fbd26ac6475e09e7e287a8aa10f666"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1ea8fcfc649cd7f2a5bccd3503270dc35b0d23a9be33997b8115b27117541082"
  end

  depends_on "picat"

  def install
    libexec.install "fzn_parser.pi", "fzn_tokenizer.pi", "fzn_picat_sat.pi"
    (bin / "fzn-picat").write <<~EOS
      #!/bin/bash
      TMPDIR=$(mktemp -d -t fzn-picat.XXX) || exit 1
      trap 'rm -rf "$TMPDIR"' EXIT
      ln -s #{libexec}/*.pi $TMPDIR
      #{HOMEBREW_PREFIX}/bin/picat $TMPDIR/fzn_picat_sat.pi "$@"
    EOS

    inreplace "picat.msc.in" do |s|
      s.gsub!(/"executable":\s+"[^"]*"/, "\"executable\": \"#{bin}/fzn-picat\"")
      s.gsub!(/"mznlib":\s+"[^"]*"/, "\"mznlib\": \"#{share}/minizinc/picat\"")
    end

    (share / "minizinc").mkpath
    (share / "minizinc").install "mznlib" => "picat"

    (share / "minizinc/solvers").mkpath
    (share / "minizinc/solvers").install "picat.msc.in" => "picat.msc"
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_match "----------", shell_output("#{bin}/fzn-picat test.fzn").strip
  end
end
