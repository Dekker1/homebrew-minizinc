class Pumpkin < Formula
  desc "Lazy clause generation constraint solver written in Rust"
  homepage "https://github.com/ConSol-Lab/Pumpkin"
  url "https://github.com/ConSol-Lab/Pumpkin/archive/refs/tags/pumpkin-solver-v0.3.0.tar.gz"
  sha256 "2cd08992413ff383115566f7214c333a5389b2db5e6c35b79b43c9ca0958f0cf"
  license "Apache-2.0"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "0de105b3eec3c990017892fc3212fde9dc4652b0f2566edff2bd88195971bb1b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d40eea72b1d088bd677ee1432b791ba9db2093da14210008b6f00214ef3ed955"
  end

  depends_on "rust" => :build

  def install
    chdir "pumpkin-solver" do
      system "cargo", "install", *std_cargo_args
    end

    (share / "minizinc").mkpath
    (share / "minizinc").install "minizinc/lib" => "pumpkin"

    inreplace "minizinc/pumpkin.msc" do |s|
      s.gsub!(/"executable":\s+"[^"]*"/, "\"executable\": \"#{bin}/pumpkin-solver\"")
      s.gsub!(/"mznlib":\s+"[^"]*"/, "\"mznlib\": \"#{share}/minizinc/pumpkin\"")
      s.gsub!(/"version":\s+"[^"]*"/, "\"version\": \"#{version}\"")
    end
    (share / "minizinc/solvers").mkpath
    (share / "minizinc/solvers").install "minizinc/pumpkin.msc"
  end

  test do
    (testpath/"test.fzn").write <<~EOS
      var bool: x1;
      solve satisfy;
    EOS
    assert_equal "----------", shell_output("#{bin}/pumpkin-solver test.fzn").strip
  end
end
