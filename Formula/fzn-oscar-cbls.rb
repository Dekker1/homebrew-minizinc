class FznOscarCbls < Formula
  desc "Constraint-Based Local Search Backend for MiniZinc using Oscar CBLS"
  homepage "https://bitbucket.org/oscarlib/oscar/"
  url "https://github.com/Dekker1/homebrew-minizinc/files/9966035/oscar-cbls-flatzinc.zip"
  version "1.0"
  sha256 "3e0b432f4f8009466b4260a92b63f8036f026c88bccb7b041247defcb8788b67"
  license "LGPL-3.0-or-later"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, big_sur:      "7861df5fdda7f1cff3ff833b8f06e6f20d991cb39db3e49e9e534d01af9fd00f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "7456db85bd6fa321f7dc881aff8ff2836470fcad8897e0fb4dcca4d9f1b8871d"
  end

  depends_on "openjdk"

  def install
    libexec.install "lib/oscar-fzn-cbls.jar"
    bin.write_jar_script libexec/"oscar-fzn-cbls.jar", "fzn-oscar-cbls"

    (share / "minizinc").mkpath
    (share / "minizinc").install "oscar_cbls"

    inreplace "fzn-oscar-cbls.msc" do |s|
      s.gsub!(/"executable":\s+"[^"]*"/, "\"executable\": \"#{bin}/fzn-oscar-cbls\"")
      s.gsub!(/"mznlib":\s+"[^"]*"/, "\"mznlib\": \"#{share}/minizinc/oscar_cbls\"")
    end
    (share / "minizinc/solvers").mkpath
    (share / "minizinc/solvers").install "fzn-oscar-cbls.msc"
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_match "----------", shell_output("#{bin}/fzn-oscar-cbls test.fzn").strip
  end
end
