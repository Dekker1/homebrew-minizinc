class FznPicat < Formula
  desc "FlatZinc solver based on the Picat Language SAT Engine"
  homepage "http://picat-lang.org"
  url "https://github.com/nfzhou/fzn_picat/archive/ccda772920580a9e188d6188adf586f83c4e8633.tar.gz"
  version "3.7"
  sha256 "b6ff4ef33b095c8e8e99ae93bd336cebc1e8b34c30bc94ee975d809de5d660ba"
  license "MPL-2.0"
  head "https://github.com/nfzhou/fzn_picat.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, ventura:      "eea89087e920500e66a19e7fde2e7dc32edf24252d34a01c175a33a927866a79"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "3d2f808e665f1fd46f22756bc50bc61e2f9dd8be9e69777a89930f02d767ee91"
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
      s.gsub!(/"version":\s+"[^"]*"/, "\"version\": \"#{version}\"")
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
