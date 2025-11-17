class Pumpkin < Formula
  desc "Lazy clause generation constraint solver written in Rust"
  homepage "https://github.com/ConSol-Lab/Pumpkin"
  url "https://github.com/ConSol-Lab/Pumpkin/archive/refs/tags/pumpkin-solver-v0.2.2.tar.gz"
  sha256 "95c9069bc1ed503a09112aff530dd1bf0b19a24a2589b2738c158d0fa378b589"
  license "Apache-2.0"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, arm64_sonoma: "a802682980849836bef1bf0792d2741fd0b9f89b2dae3d8c403c24154c54a22c"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f6cb1a3471b07feb7344887c66c1901c2b97ed1f0843811bf95da90bf7957a57"
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
