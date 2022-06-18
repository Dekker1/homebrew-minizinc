class Geas < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://bitbucket.org/gkgange/geas/"
  url "https://bitbucket.org/gkgange/geas.git",
    revision: "d409105631b24663f84a95273dfcdc065c104de0"
  version "2022-05-16"
  head "https://bitbucket.org/gkgange/geas.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, big_sur:      "7aa727dc51f1bb83a60264a4726e9a078787967fcc1b4b55adc19e03332d0559"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "64b073a90fd95732dcf4c5519369da1b69fa218a36370782dec4115968907fa0"
  end

  depends_on "opam" => :build

  def install
    inreplace "Makefile" do |s|
      s.gsub!("-march=native", "")
    end
    Dir.mktmpdir("opamroot") do |opamroot|
      ENV["OPAMROOT"] = opamroot
      ENV["OPAMYES"] = "1"
      ENV["OPAMVERBOSE"] = "1"
      system "opam", "init", "--no-setup", "--disable-sandboxing"
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
