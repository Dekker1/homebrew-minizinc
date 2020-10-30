class FznChoco < Formula
  desc "Open-Source Java library for Constraint Programming"
  homepage "https://choco-solver.org"
  url "https://github.com/chocoteam/choco-solver/archive/4.10.5.tar.gz"
  sha256 "c0e28db042c6f8199778243bd9fd2f3f5b9392ef493d5028e3a170e8d4b68b8c"
  license "BSD-4-Clause"

  bottle do
    root_url "https://github.com/Dekker1/homebrew-minizinc/releases/download/fzn-choco-4.10.5"
    cellar :any_skip_relocation
    sha256 "34343873ef95eeac94c99631e51da2bb9de1719979d8ed806ccbfedd5632cae6" => :catalina
    sha256 "da559c6e93646b62ce17e09cba6a893bd878e8f5c495d404cba0403fc617f373" => :x86_64_linux
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
        s.gsub! /"executable":\s+"[^"]*"/, "\"executable\": \"#{bin}/fzn-choco\""
        s.gsub! /"mznlib":\s+"[^"]*"/, "\"mznlib\": \"#{share}/minizinc/choco\""
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
