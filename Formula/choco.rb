class Choco < Formula
  include Language::Python::Shebang

  desc "Open-Source Java library for Constraint Programming and FlatZinc solver"
  homepage "https://choco-solver.org"
  url "https://github.com/chocoteam/choco-solver/archive/refs/tags/v6.0.1.tar.gz"
  sha256 "e246f1632d94aa40de6dd60a7e4b8219b69a5febe26df77a50bc3211e2259bb8"
  license "BSD-4-Clause"
  head "https://github.com/chocoteam/choco-solver.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "2efdde4d26275251a1e2d84882f6643b53cb9e4cee8d749631d4eb968c7a7c11"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "345b802f5358b18b59ef12d601f8748d4c4a589b2e4439dd511c33b02d64b7bc"
  end

  depends_on "maven" => :build
  depends_on "openjdk"
  depends_on "python@3.13"

  patch :DATA

  def install
    cd "parsers" do
      system "mvn", "clean", "package", "-DskipTests=true", "-Dmaven.javadoc.skip=true"
      libexec.install "target/choco-solver-#{version}-light.jar" => "choco-parsers-#{version}-light.jar"

      rewrite_shebang detected_python_shebang, "src/main/minizinc/fzn-choco.py"
      inreplace "src/main/minizinc/fzn-choco.py" do |s|
        s.gsub!(/JAR_FILE\s*=\s*'[^']*'/, "JAR_FILE='#{libexec}/choco-parsers-#{version}-light.jar'")
        s.gsub!("HOMEBREW_JAVA_HOME", Language::Java.java_home)
      end
      bin.install "src/main/minizinc/fzn-choco.py" => "fzn-choco"

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

__END__
diff --git a/parsers/src/main/minizinc/fzn-choco.py b/parsers/src/main/minizinc/fzn-choco.py
index 9965727..711dc16 100644
--- a/parsers/src/main/minizinc/fzn-choco.py
+++ b/parsers/src/main/minizinc/fzn-choco.py
@@ -1,3 +1,5 @@
+#!/usr/bin/env python3
+
 # Compilation mode, support OS-specific options
 # nuitka-project: --onefile
 # nuitka-project: --remove-output
@@ -107,7 +109,8 @@ if args.cp_profiler:
 if args.lazy_clause_generation:
     arguments += ' -lcg'

-cmd = f'java {args.jvm_args} -cp {args.jar_file} org.chocosolver.parser.flatzinc.ChocoFZN {args.fzn_file} {arguments}'
+os.environ.setdefault("JAVA_HOME", "HOMEBREW_JAVA_HOME")
+cmd = f'${{JAVA_HOME}}/bin/java {args.jvm_args} -cp {args.jar_file} org.chocosolver.parser.flatzinc.ChocoFZN {args.fzn_file} {arguments}'

 # if __lvl__ == 'INFO':
 #cprint(f'Running command: {cmd}')
