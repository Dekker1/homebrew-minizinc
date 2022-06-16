class Geas < Formula
  desc "Lazy clause generation FlatZinc solver"
  homepage "https://bitbucket.org/gkgange/geas/"
  url "https://bitbucket.org/gkgange/geas.git",
    revision: "d409105631b24663f84a95273dfcdc065c104de0"
  version "2022-05-16"
  head "https://bitbucket.org/gkgange/geas.git", branch: "master"

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
