class Flatzingo < Formula
  desc "FlatZinc frontend for Clingcon"
  homepage "https://github.com/potassco/flatzingo"
  url "https://github.com/potassco/flatzingo/archive/refs/tags/minizinc_challenge_2022.tar.gz"
  version "1.7.0"
  sha256 "e43f007075cc5975e82e1256c48a957b2d57b0e1183ab7d6b9c79bf0c512982b"
  license "MIT"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, big_sur:      "8732bfe5a1f8cb8ff603edb629d087ebaebd6d99c12f195f02bd6558a4576d5e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c7e56a8c706e7a28d55b6599bf7a8e0a3f016cb684dc4f6f18893d01ad37b656"
  end

  depends_on "clingcon"
  depends_on "fzn2lp"
  depends_on "python@3.11"

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
