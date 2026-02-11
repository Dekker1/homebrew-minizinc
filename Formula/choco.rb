class Choco < Formula
  include Language::Python::Shebang

  desc "Open-Source Java library for Constraint Programming and FlatZinc solver"
  homepage "https://choco-solver.org"
  url "https://github.com/chocoteam/choco-solver/archive/refs/tags/v5.0.0.tar.gz"
  sha256 "0c99663fc51124907c05c6d72e4a039bfa55bdf920c16fa5a3649b3c0473e0ef"
  license "BSD-4-Clause"
  head "https://github.com/chocoteam/choco-solver.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "082d9e2d8a02ea240a4fc8e459dd190659b8d9617fb3fd6e80c2a916189ad082"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e707d35be5b0f2819923c1dd689e3fad8a36a61a5f7dedc5781f50ebae01db66"
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
