class Huub < Formula
  desc "CP+SAT solver framework built to be reliable, performant, and extensible"
  homepage "https://github.com/huub-solver/huub"
  url "https://github.com/huub-solver/huub/archive/refs/tags/huub-v100.1.0.tar.gz"
  sha256 "028abbbf3361bb2ec0cfb51b0f5b7a266a1c9b6e8834dc2d30f595e496779f65"
  license "MPL-2.0"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "12282c897277f8384aea98ccb81798fd100cc8bb2c46cc6a8391b47bcfa3c6b0"
    sha256 cellar: :any,                 x86_64_linux: "690a19055ae1918bfc1346275da7b8adc9ad8e858994c74d7f4c750381f2e0a7"
  end

  depends_on "rust" => :build

  def install
    cd "crates/huub-cli" do
      system "cargo", "install", *std_cargo_args
    end

    mkdir_p "share/minizinc/solvers"
    system "cargo", "xtask", "mzn-config", "--output-path", "share/minizinc/solvers/huub.msc"

    (share / "minizinc").mkpath
    (share / "minizinc").install "share/minizinc/huub" => "huub"

    inreplace "share/minizinc/solvers/huub.msc" do |s|
      s.gsub!(/"executable":\s*"[^"]*"/, "\"executable\": \"#{bin}/huub\"")
      s.gsub!(/"mznlib":\s*"[^"]*"/, "\"mznlib\": \"#{share}/minizinc/huub\"")
    end

    (share / "minizinc/solvers").mkpath
    (share / "minizinc/solvers").install "share/minizinc/solvers/huub.msc"

    system "cargo", "xtask", "completions", "--output-dir", "completions"
    bash_completion.install "completions/share/bash-completion/completions/huub"
    fish_completion.install "completions/share/fish/vendor_completions.d/huub.fish"
    zsh_completion.install "completions/share/zsh/site-functions/_huub"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/huub --version")

    msc = share/"minizinc/solvers/huub.msc"
    assert_path_exists msc
    assert_match "\"executable\": \"#{bin}/huub\"", msc.read
  end
end
