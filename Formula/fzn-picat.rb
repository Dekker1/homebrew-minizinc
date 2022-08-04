class FznPicat < Formula
  desc "FlatZinc solver based on the Picat Language SAT Engine"
  homepage "http://picat-lang.org"
  url "https://github.com/nfzhou/fzn_picat/archive/284705a4069855dfff3d10ce05254d78a640abcb.tar.gz"
  version "3.2.6"
  sha256 "41707a31e1634ee0f821d0d8c6c8e7cb4a862a028b6d73bd76f458cc09021033"
  license "MPL-2.0"
  head "https://github.com/nfzhou/fzn_picat.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, big_sur:      "f3744e99c2b6b1d28abb4bb761c6fc9e5ed5e06aeeab58244ced3784187d316b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c5a4a8e9c9c076d3abd42bcfdd25850d996b75aedfeb71578f57a4e458741318"
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
