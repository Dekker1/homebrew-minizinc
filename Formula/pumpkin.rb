class Pumpkin < Formula
  desc "Lazy clause generation constraint solver written in Rust"
  homepage "https://github.com/ConSol-Lab/Pumpkin"
  url "https://github.com/ConSol-Lab/Pumpkin/archive/refs/tags/pumpkin-solver-v0.4.0.tar.gz"
  sha256 "07d258d809f4852d4ddb8908f03c012f7991c25dadc51f86cd2058115c942ed2"
  license "Apache-2.0"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "94446ce851bcf6d0366f4702c6873296d8d0b31dfe84f65f2a321e03bcb7bc67"
    sha256 cellar: :any,                 x86_64_linux: "45879b492adfdab54f91a58d7f4bf62b29cffad087a9d3ed5c5268870354e44b"
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
