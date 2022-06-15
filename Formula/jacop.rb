class Jacop < Formula
  desc "FlatZinc interface for the JaCoP constraint programming solver"
  homepage "https://github.com/radsz/jacop"
  url "https://github.com/radsz/jacop/archive/refs/tags/v4.8.0.tar.gz"
  sha256 "bbd4be59be8641d4d13e34f15191f48e894dce02eca441cb9b14982b312a0096"
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
