class FznPicat < Formula
  desc "FlatZinc solver based on the Picat Language SAT Engine"
  homepage "http://picat-lang.org"
  url "https://github.com/nfzhou/fzn_picat/archive/e32c8a0ec02c4ebcfdab3ee53b0f76fca424b79e.tar.gz"
  version "3.0.2"
  sha256 "aac52c4853572999be199d2571405b389ea6d1317bc37983d79c597fce6b389e"
  license "MPL-2.0"
  head "https://github.com/nfzhou/fzn_picat.git", branch: "main"

  bottle do
    root_url "https://github.com/Dekker1/homebrew-minizinc/releases/download/fzn-picat-3.0.2"
    cellar :any_skip_relocation
    sha256 "6a7748a870e5b785b4818f9582a35fece0cf07edc618089ada5ffc584c3ad033" => :catalina
    sha256 "0f350b5174f65c9076313ff0758e410b6b8c34b9e930429959c53c5838c5b028" => :x86_64_linux
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

    (share / "minizinc").mkpath
    (share / "minizinc/picat").install "mznlib" => "picat"

    (share / "minizinc/solvers").mkpath
    (share / "minizinc/solvers/picat.msc").write <<~EOS
      {
        "id": "org.picat-lang.picat",
        "name": "Picat SAT",
        "description": "Picat SAT solving engine",
        "version": "#{pkg_version}",
        "mznlib": "#{share}/minizinc/picat",
        "executable": "#{bin}/fzn-picat",
        "tags": ["sat", "int"],
        "stdFlags": ["-a", "-f", "-n", "-p"],
        "extraFlags": [],
        "supportsMzn": false,
        "supportsFzn": true,
        "needsSolns2Out": true,
        "needsMznExecutable": false,
        "needsStdlibDir": false,
        "isGUIApplication": false
      }
    EOS
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_match "----------", shell_output("#{bin}/fzn-picat test.fzn").strip
  end
end
