class Huub < Formula
  desc "CP+SAT solver framework built to be reliable, performant, and extensible"
  homepage "https://github.com/huub-solver/huub"
  url "https://github.com/huub-solver/huub/archive/refs/tags/huub-v100.0.0.tar.gz"
  sha256 "789fc798e8b238c2e8e525c34fb414b4cb967818f3a817ea785f934294c398b2"
  license "MPL-2.0"

  bottle do
    root_url "https://ghcr.io/v2/dekker1/minizinc"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "eada5bfb820263d87843085d09e586cae793b6649d31b41431cbcfe38ef0076b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9c1183e3a4fda7a4623da2ca6211a22a31f07fabfbf5ea90676f3085a728408f"
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
