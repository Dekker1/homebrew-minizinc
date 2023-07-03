class OpenWbo < Formula
  desc "State-of-the-art MaxSAT and Pseudo-Boolean solver"
  homepage "https://github.com/sat-group/open-wbo"
  url "https://github.com/sat-group/open-wbo.git",
     revision: "80f3073e41028b219b0b0ad7c61fba28351f88e6"
  version "2.1"
  license "MIT"
  head "https://github.com/sat-group/open-wbo.git", branch: "master"

  depends_on "gmp"
  depends_on "zlib"

  def install
    system "make", "r"
    bin.install "open-wbo_release" => "open-wbo"
    (share / "minizinc/solvers/open-wbo.msc").write <<~EOS
      {
        "id": "org.sat-group.open-wbo",
        "name": "Open WBO",
        "description": "#{desc}",
        "version": "#{version}",
        "mznlib": "-Gsat",
        "executable": "#{bin}/open-wbo",
        "tags": ["maxsat", "sat", "bool"],
        "stdFlags": ["-a", "-f", "-s", "-t", "-i"],
        "extraFlags": [],
        "inputType": "WDIMACS",
        "needsSolns2Out": true,
        "needsMznExecutable": false,
        "needsStdlibDir": false,
        "isGUIApplication": false
      }
    EOS
  end

  test do
    (testpath/"test.wdimacs").write <<~EOS
      p cnf 3 4
      1 -2 0
      -1 2 -3 0
      -3 2 0
      1 3 0
    EOS
    assert_match "s OPTIMUM FOUND", shell_output("#{bin}/open-wbo test.wdimacs", 30).strip
  end
end
