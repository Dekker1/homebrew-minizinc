class FznJacop < Formula
  desc "FlatZinc interface for the JaCoP constraint programming solver"
  homepage "https://github.com/radsz/jacop"
  # TODO: Currently there is no actual GitHub Release
  url "https://github.com/radsz/jacop/archive/4f623957bc2cc1b90c254cec70f73b28f68a9278.tar.gz"
  version "4.7.0"
  sha256 "ca5f920b1e34ba0f2893944e9808f67885f87e620517afc093a1a896c4a916ff"
  license "AGPL-3.0-or-later"
  head "https://github.com/radsz/jacop.git", branch: "develop"

  depends_on "maven" => :build
  depends_on "openjdk"

  def install
    system "mvn", "clean", "package", "-DskipTests=true", "-Dmaven.javadoc.skip=true"
    libexec.install Dir["target/jacop-*.jar"]
    bin.write_jar_script libexec/"jacop-#{version}.jar", "fzn-jacop"

    (share / "minizinc").mkpath
    (share / "minizinc").install "src/main/minizinc/org/jacop/minizinc" => "jacop"

    inreplace "src/main/minizinc/org.jacop.msc" do |s|
      s.gsub! /"executable":\s+"[^"]*"/, "\"executable\": \"#{bin}/fzn-jacop\""
      s.gsub! /"mznlib":\s+"[^"]*"/, "\"mznlib\": \"#{share}/minizinc/jacop\""
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
