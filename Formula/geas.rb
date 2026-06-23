class Geas < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://github.com/gkgange/geas/"
  url "https://github.com/gkgange/geas.git",
    revision: "50147419443ea90bcf679f9bdd459bbe0be772f7"
  version "2023-09-06"
  head "https://github.com/gkgange/geas.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    rebuild 1
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "e791e6c88d796e9b159edca1385afcfca47a56f3fbb54a16168f351651e61565"
    sha256 cellar: :any,                 x86_64_linux: "0636b73b5986b82df909a49ab5ccb7d2246b85cf98856163d204c59684adef3e"
  end

  depends_on "opam" => :build

  def install
    inreplace "Makefile" do |s|
      s.gsub!("-march=native", "")
      # - GCC 13+ no longer transitively includes <cstdint>, so force-include.
      # - Clang 19+ rejects the bare `template` keyword; downgrade that diagnostic.
      s.gsub!("--std=c++11", "--std=c++11 -include cstdint -Wno-missing-template-arg-list-after-template-kw")
    end
    Dir.mktmpdir("opamroot") do |opamroot|
      ENV["OPAMROOT"] = opamroot
      ENV["OPAMYES"] = "1"
      ENV["OPAMVERBOSE"] = "1"
      system "opam", "init", "--no-setup", "--disable-sandboxing", "--compiler=4.14.2"
      # Tell opam not to try to install external dependencies
      system "opam", "option", "depext=false"
      modules = %w[
        camlidl
      ]
      system "opam", "exec", "opam", "install", *modules

      ENV.deparallelize { system "opam", "config", "exec", "make" }
    end

    bin.install "fzn/fzn_geas"
    lib.install "libgeas.a"

    (share / "minizinc").mkpath
    (share / "minizinc").install "fzn/mznlib" => "geas"

    (share / "minizinc/solvers").mkpath
    (share / "minizinc/solvers/geas.msc").write <<~EOS
      {
        "id": "org.geas.geas",
        "name": "Geas",
        "description": "Geas LCG solver",
        "version": "#{version}",
        "mznlib": "#{share}/minizinc/geas",
        "executable": "#{bin}/fzn_geas",
        "tags": ["cp", "lcg", "int", "bool", "float"],
        "stdFlags": ["-a", "-f", "-n", "-r", "-s", "-t"],
        "extraFlags": [],
        "supportsMzn": false,
        "supportsFzn": true,
        "needsSolns2Out": true,
        "needsMznExecutable": false,
        "needsStdlibDir": false,
        "isGUIApplication": false
      }
    EOS
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_match "----------", shell_output("#{bin}/fzn_geas test.fzn").strip
  end
end
