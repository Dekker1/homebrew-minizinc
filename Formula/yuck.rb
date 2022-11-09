class Yuck < Formula
  desc "Local-search constraint solver with FlatZinc interface"
  homepage "https://github.com/informarte/yuck"
  url "https://github.com/informarte/yuck/releases/download/20221101/yuck-20221101.zip"
  sha256 "2195b8b4280f81326c7a9710f2ac1f6a3be7176c9235d12ec0e813a43a2655da"
  license "MPL-2.0"
  head "https://github.com/informarte/yuck.git", branch: "master"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, big_sur:      "958eb0770e054c888281a4b4618e3dfbd48dfb94a800ea530ca122859c4a5bf2"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a73efafac2b2ab3cf0ad3bd0274f147ccfee3f0e568ef14bd6411336db8b1378"
  end

  # FIXME: Building does not succeed in the formula <== depends_on "mill" => :build
  depends_on "coreutils" # realpath in script
  depends_on "openjdk"

  def install
    # system "mill", "yuck.universalPackage"

    # out_loc = buildpath / Dir.glob("out/yuck/corePackage.dest/yuck-*")[0]
    out_loc = buildpath

    inreplace (out_loc / "bin/yuck") do |s|
      s.gsub!("APP_HOME\/lib", "APP_HOME\/libexec")
    end
    bin.install (out_loc / "bin/yuck")

    prefix.install (out_loc / "lib") => "libexec"

    (share / "minizinc").mkpath
    (share / "minizinc").install (out_loc / "mzn/lib") => "yuck"

    inreplace "mzn/yuck.msc" do |s|
      s.gsub!(/"executable":\s+"[^"]*"/, "\"executable\": \"#{bin}/yuck\"")
      s.gsub!(/"mznlib":\s+"[^"]*"/, "\"mznlib\": \"#{share}/minizinc/yuck\"")
      s.gsub!(/"version":\s+"[^"]*"/, "\"version\": \"#{version}\"")
    end
    (share / "minizinc/solvers").mkpath
    (share / "minizinc/solvers").install "mzn/yuck.msc"
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_match "----------", shell_output("#{bin}/yuck test.fzn").strip
  end
end
