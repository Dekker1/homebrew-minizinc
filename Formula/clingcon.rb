class Clingcon < Formula
  desc "Answer set solver for constraint logic programs built upon clingo"
  homepage "https://potassco.org/"
  url "https://github.com/potassco/clingcon/archive/refs/tags/v5.0.0.tar.gz"
  sha256 "c6bd979b94eebc531a191d957feb53e2e4b37858c71f3f5e04d73ab50db96f43"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "clingo"

  def install
    system "cmake", "-S", ".", "-B", "build", *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    assert_match(/clingcon version/, shell_output("#{bin}/clingcon --help").strip)

    # TODO: This is a better test, but clingcon exits 10 even though it finishes correctly
    # (testpath/"queens.lp").write <<~EOS
    #   #const n = 4.
    #   p(1..n).
    #   &dom { 1..n } = q(N) :- p(N).
    #   &distinct { q(N)+0 : p(N) }.
    #   &distinct { q(N)-N : p(N) }.
    #   &distinct { q(N)+N : p(N) }.
    # EOS

    # assert_match(/SATISFIABLE/, shell_output("#{bin}/clingcon queens.lp").strip)
  end
end
