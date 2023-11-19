class Jacop < Formula
  desc "FlatZinc interface for the JaCoP constraint programming solver"
  homepage "https://github.com/radsz/jacop"
  url "https://github.com/radsz/jacop/archive/refs/tags/4.10.0.tar.gz"
  sha256 "0983aae9f20ea2cdc747046bb079cf60ff697203ffa657b0d20d633d0b220270"
  license "AGPL-3.0-or-later"
  head "https://github.com/radsz/jacop.git", branch: "develop"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, big_sur:      "8e9ce1e8875d283162bc770c748affaf3a5851752735a842903303626f2048e7"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6ae7027e9a2abde71c1e297df40882c7738138a2765c5cf1984fe2a13e3a3104"
  end

  depends_on "maven" => :build
  depends_on "openjdk"

  def install
    system "mvn", "clean", "package", "-DskipTests=true", "-Dmaven.javadoc.skip=true"
    libexec.install Dir["target/jacop-*.jar"]
    bin.write_jar_script libexec/"jacop-#{version}.jar", "fzn-jacop"

    (share / "minizinc").mkpath
    (share / "minizinc").install "src/main/minizinc/org/jacop/minizinc" => "jacop"

    inreplace "src/main/minizinc/org.jacop.msc" do |s|
      s.gsub!(/"executable":\s+"[^"]*"/, "\"executable\": \"#{bin}/fzn-jacop\"")
      s.gsub!(/"mznlib":\s+"[^"]*"/, "\"mznlib\": \"#{share}/minizinc/jacop\"")
    end
    (share / "minizinc/solvers").mkpath
    (share / "minizinc/solvers").install "src/main/minizinc/org.jacop.msc"
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_match "----------", shell_output("#{bin}/fzn-jacop test.fzn").strip
  end
end
