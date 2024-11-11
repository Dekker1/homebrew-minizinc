class Pumpkin < Formula
  desc "Lazy clause generation constraint solver written in Rust"
  homepage "https://github.com/ConSol-Lab/Pumpkin"
  url "https://github.com/ConSol-Lab/Pumpkin/archive/refs/tags/pumpkin-solver-v0.1.4.tar.gz"
  sha256 "7c4bb0ce85d456685b1339370d7dd04e3f3c16a989b93b16f66f0aa266fa5d9e"
  license "Apache-2.0"

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
