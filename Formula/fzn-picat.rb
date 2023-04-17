class FznPicat < Formula
  desc "FlatZinc solver based on the Picat Language SAT Engine"
  homepage "http://picat-lang.org"
  url "https://github.com/nfzhou/fzn_picat/archive/8d18e1f5b06c9e52c227f7adf91fa9728c83faeb.tar.gz"
  version "3.4.0"
  sha256 "8d74006bce80c6caeb302c96270346b4c130d966ac1f5876f95846f8a3b3aa2b"
  license "MPL-2.0"
  head "https://github.com/nfzhou/fzn_picat.git", branch: "main"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, big_sur:      "86a06b81ddecbdcab1a126cbc76ae7399accd9f7243a26e740e36f42bb8cfda9"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "beb55a32104db8ee82edae9652873051261fda65002cd7e0d4c269e36293cebe"
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
