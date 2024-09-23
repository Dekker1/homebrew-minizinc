class Choco < Formula
  desc "Open-Source Java library for Constraint Programming and FlatZinc solver"
  homepage "https://choco-solver.org"
  url "https://github.com/chocoteam/choco-solver/archive/refs/tags/v4.10.17.tar.gz"
  sha256 "95628b526f5cc00f8d6cf3f62575541126a61aa247b47b4854170f7b3ed21ef1"
  license "BSD-4-Clause"
  head "https://github.com/chocoteam/choco-solver.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "4489a39dde6963dc563c95c373bbf71079a6b9a73f032d13679c968454c4f6fa"
    sha256 cellar: :any_skip_relocation, ventura:      "a97a144dcf6b301962df15d9c6fdba87e76b93d6eeb01e30627266fa30227d56"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1cc8ece78f1d6a6382548bf0150e6b4152648f325720fe27d04518430b7531b3"
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
        s.gsub!(/"executable"\s*:\s*"[^"]*"/, "\"executable\": \"#{bin}/fzn-choco\"")
        s.gsub!(/"mznlib"\s*:\s*"[^"]*"/, "\"mznlib\": \"#{share}/minizinc/choco\"")
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
