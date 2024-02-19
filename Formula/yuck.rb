class Yuck < Formula
  desc "Local-search constraint solver with FlatZinc interface"
  homepage "https://github.com/informarte/yuck"
  url "https://github.com/informarte/yuck.git",
     tag:      "20240207",
     revision: "555e489a9437b5cc3f440cdfaa36815117d48cf8"
  license "MPL-2.0"
  head "https://github.com/informarte/yuck.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, ventura:      "36a6291454d6941a7728a3ea2b2a9d8b8af47789ff4871d381d5c2efd0f96094"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "661b1053fe053d9c4299f6a3b65d3d60a179ada6117a4baa967e0ac1e6dc0d8e"
  end

  depends_on "coreutils" # realpath in script
  depends_on "openjdk@17"

  def install
    system "./mill", "yuck.dev.corePackage"

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
