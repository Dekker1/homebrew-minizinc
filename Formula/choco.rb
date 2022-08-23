class Choco < Formula
  desc "Open-Source Java library for Constraint Programming and FlatZinc solver"
  homepage "https://choco-solver.org"
  url "https://github.com/chocoteam/choco-solver/archive/refs/tags/4.10.9.tar.gz"
  sha256 "f17a6f9157973e768f0db486c7f07ddd07076adf3a5002757a31c6776c251fdd"
  license "BSD-4-Clause"
  head "https://github.com/chocoteam/choco-solver.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, big_sur:      "0f1d72d2ad3f41e0da0d897dfbb7a5d98a4b569116189bf71468a646a25f77a9"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6fa095b1d673ea46150e28ebbe98352ea4168b24c720f3ec82a14fb188ba78eb"
  end

  depends_on "maven" => :build
  depends_on "openjdk"

  def install
    cd "parsers" do
      system "mvn", "clean", "package", "-DskipTests=true", "-Dmaven.javadoc.skip=true"
      libexec.install "target/choco-parsers-#{version}-jar-with-dependencies.jar"
      bin.write_jar_script libexec/"choco-parsers-#{version}-jar-with-dependencies.jar", "fzn-choco"

      (share / "minizinc").mkpath
      (share / "minizinc").install "src/main/minizinc/mzn_lib" => "choco"

      inreplace "src/main/minizinc/choco.msc" do |s|
        s.gsub!(/"executable":\s+"[^"]*"/, "\"executable\": \"#{bin}/fzn-choco\"")
        s.gsub!(/"mznlib":\s+"[^"]*"/, "\"mznlib\": \"#{share}/minizinc/choco\"")
      end
      (share / "minizinc/solvers").mkpath
      (share / "minizinc/solvers").install "src/main/minizinc/choco.msc"
    end
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_match "----------", shell_output("#{bin}/fzn-choco test.fzn").strip
  end
end
