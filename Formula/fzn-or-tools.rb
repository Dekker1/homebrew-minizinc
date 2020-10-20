class FznOrTools < Formula
  desc ""
  homepage ""
  url "https://github.com/google/or-tools/archive/v8.0.tar.gz"
  sha256 "ac01d7ebde157daaeb0e21ce54923a48e4f1d21faebd0b08a54979f150f909ee"
  license "Apache-2.0"

  head "https://github.com/google/or-tools.git"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "wget" => :build

  def install
    system "make", "third_party"
    system "make", "cc", "fz"

    lib.install Dir["lib/*"]
    bin.install "bin/fz" => "fzn-or-tools"

    (share / "minizinc").mkpath
    (share / "minizinc").install "ortools/flatzinc/mznlib" => "or-tools"

    pkgshare.install "examples"

    (share / "minizinc/solvers").mkpath
    (share / "minizinc/solvers/or-tools.msc").write <<~EOS
      {
        "id": "com.google.or-tools",
        "name": "OR-Tools",
        "description": "OR-Tools FlatZinc executable",
        "version": "#{pkg_version}",
        "mznlib": "../or-tools",
        "executable": "../../../bin/fzn-or-tools",
        "tags": ["cp", "lcg", "int"],
        "stdFlags": ["-a", "-f", "-n", "-p", "-s", "-t", "-v"],
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
    assert_match "----------", shell_output("#{bin}/fzn-or-tools #{pkgshare}/examples/flatzinc/queens3.fzn")
  end
end
