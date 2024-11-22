class Mistral < Formula
  desc "Open source constraint programming library and FlatZinc solver written in C++"
  homepage "https://github.com/ehebrard/Mistral-2.0"
  url "https://github.com/ehebrard/Mistral-2.0.git",
    revision: "353b2e0f549548b5a5f1dc95c45c03c911f5619f"
  version "2022-06-21"
  license "AGPL-3.0-only"
  head "https://github.com/ehebrard/Mistral-2.0.git", branch: "master"

  depends_on "boost" => :build
  # Issue with output: https://github.com/ehebrard/Mistral-2.0/issues/9
  depends_on "llvm" => :build

  depends_on "python"

  def install
    ENV.clang
    system "make", "-C", "fz"

    bin.install "fz/mistral-fzn"
    inreplace "fz/mistral-fz" do |s|
      s.gsub!("mcmd = ['./mistral-fzn']", "mcmd = ['#{bin}/mistral-fzn']")
    end
    bin.install "fz/mistral-fz"

    (share / "minizinc").mkpath
    (share / "minizinc").install "fz/mznlib" => "mistral"

    (share / "minizinc/solvers").mkpath
    (share / "minizinc/solvers/mistral.msc").write <<~EOS
      {
        "id": "org.mistral.mistral",
        "name": "Mistral",
        "description": "Mistral FlatZinc interface",
        "version": "#{version}",
        "mznlib": "#{share}/minizinc/mistral",
        "executable": "#{bin}/mistral-fz",
        "tags": ["cp", "int"],
        "stdFlags": ["-a"],
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
    assert_match "----------", shell_output("#{bin}/mistral-fz test.fzn").strip
  end
end
