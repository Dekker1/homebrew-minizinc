class Yuck < Formula
  desc "Local-search constraint solver with FlatZinc interface"
  homepage "https://github.com/informarte/yuck"
  url "https://github.com/informarte/yuck.git",
     tag:      "20260620",
     revision: "1b4fb95b2e83d0c36512c97f6b5bbf5e4d0d0d9d"
  license "MPL-2.0"
  head "https://github.com/informarte/yuck.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d516be080115106bf5ab3489553eecf8e617f08caab6aede670f43740b7652fd"
  end

  depends_on "coreutils" # realpath in script
  depends_on "openjdk"

  def install
    system "./mill", "yuck.corePackage"

    out_loc = buildpath / Dir.glob("out/yuck/corePackage.dest/yuck-*")[0]

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
