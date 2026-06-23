class Flatzingo < Formula
  desc "FlatZinc frontend for Clingcon"
  homepage "https://github.com/potassco/flatzingo"
  url "https://github.com/potassco/flatzingo/archive/refs/tags/minizinc_challenge_2022.tar.gz"
  version "1.7.0"
  sha256 "e43f007075cc5975e82e1256c48a957b2d57b0e1183ab7d6b9c79bf0c512982b"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "1ae28e62b4e1d57bf89c77342e7310dedff7ebc6453635b632fad65977dffd4a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4cdde4cde81a38a50451992bca98ece2aa944670ef6581b10589bbe97fc1a340"
  end

  depends_on "clingcon"
  depends_on "fzn2lp"
  depends_on "python"

  def install
    libexec.install "fzn-flatzingo.sh", "fzn-flatzingo.py", "encodings"
    (bin / "fzn-flatzingo").write <<~EOS
      #!/bin/bash
      #{libexec}/fzn-flatzingo.sh "$@"
    EOS

    (share / "minizinc").mkpath
    (share / "minizinc").install "share/minizinc/flatzingo" => "flatzingo"

    inreplace "configuration/flatzingo.msc" do |s|
      s.gsub!(/"executable":\s+"[^"]*"/, "\"executable\": \"#{bin}/fzn-flatzingo\"")
      s.gsub!(/"mznlib":\s+"[^"]*"/, "\"mznlib\": \"#{share}/minizinc/flatzingo\"")
    end

    (share / "minizinc/solvers").mkpath
    (share / "minizinc/solvers").install "configuration/flatzingo.msc" => "flatzingo.msc"
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_match "----------", shell_output("#{bin}/fzn-flatzingo test.fzn").strip
  end
end
