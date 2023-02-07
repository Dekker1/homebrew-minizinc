class Choco < Formula
  desc "Open-Source Java library for Constraint Programming and FlatZinc solver"
  homepage "https://choco-solver.org"
  url "https://github.com/chocoteam/choco-solver/archive/refs/tags/v4.10.11.tar.gz"
  sha256 "9e48e7ffe25a13a09babd5ffc1ad185e09879dac488f582045ea80c373330284"
  license "BSD-4-Clause"
  head "https://github.com/chocoteam/choco-solver.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, big_sur:      "2b638940dd02ccd671c0b248c16a3bd03dfb87d542876993c46b0180e9d9affc"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8968b7a7082af6be410a26f92707eb5d505d8c1342025afced859df8537cb1fa"
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
