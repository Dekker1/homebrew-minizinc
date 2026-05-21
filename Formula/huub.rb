class Huub < Formula
  desc "CP+SAT solver framework built to be reliable, performant, and extensible"
  homepage "https://github.com/huub-solver/huub"
  url "https://github.com/huub-solver/huub/archive/refs/tags/huub-v100.0.0.tar.gz"
  sha256 "789fc798e8b238c2e8e525c34fb414b4cb967818f3a817ea785f934294c398b2"
  license "MPL-2.0"

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
