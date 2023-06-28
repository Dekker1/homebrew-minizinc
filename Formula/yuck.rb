class Yuck < Formula
  desc "Local-search constraint solver with FlatZinc interface"
  homepage "https://github.com/informarte/yuck"
  url "https://github.com/informarte/yuck.git",
     tag:      "20230623",
     revision: "7b41e0b7cc80754f275bbbfb2c41ea3cb6a73581"
  license "MPL-2.0"
  head "https://github.com/informarte/yuck.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    rebuild 2
    sha256 cellar: :any_skip_relocation, monterey:     "44a3e25cca6ae8edb4db13e052cdb909a030b90a7c833f16914043ffa9ea74bb"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f04ea499128e0d6caa5e8e2575c16d14fd88fabe1e14dd1a0fd62df3cac6f27f"
  end

  depends_on "coreutils" # realpath in script
  depends_on "openjdk"

  def install
    system "./mill", "yuck.dev.universalPackage"

    out_loc = buildpath / Dir.glob("out/yuck/dev/corePackage.dest/yuck-*")[0]

    inreplace (out_loc / "bin/yuck") do |s|
      s.gsub!("APP_HOME/lib", "APP_HOME/libexec")
    end
    bin.install (out_loc / "bin/yuck")

    prefix.install (out_loc / "lib") => "libexec"

    (share / "minizinc").mkpath
    (share / "minizinc").install (out_loc / "mzn/lib") => "yuck"

    inreplace "resources/mzn/yuck.msc.in" do |s|
      s.gsub!(/"executable":\s+"[^"]*"/, "\"executable\": \"#{bin}/yuck\"")
      s.gsub!(/"mznlib":\s+"[^"]*"/, "\"mznlib\": \"#{share}/minizinc/yuck\"")
      s.gsub!(/"version":\s+"[^"]*"/, "\"version\": \"#{version}\"")
    end
    (share / "minizinc/solvers").mkpath
    (share / "minizinc/solvers").install "resources/mzn/yuck.msc.in" => "yuck.msc"
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_match "----------", shell_output("#{bin}/yuck test.fzn").strip
  end
end
