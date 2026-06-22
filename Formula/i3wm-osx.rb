class I3wmOsx < Formula
  desc "Tiling window manager for macOS that reads i3 config files"
  homepage "https://github.com/grepsedawk/i3wm-osx"
  url "https://github.com/grepsedawk/i3wm-osx/releases/download/v0.3.0/i3wm-osx-0.3.0-arm64.tar.gz"
  version "0.3.0"
  sha256 "c167203b765eb0f2689f4144f0a250a471a3372d7a3d56c61016ba82736e72dc"
  license "MIT"

  depends_on arch: :arm64
  depends_on macos: :ventura

  def install
    prefix.install "i3wm-osx.app"
    bin.install_symlink prefix/"i3wm-osx.app/Contents/MacOS/i3-msg"

    (etc/"i3wm-osx").mkpath
    (etc/"i3wm-osx/config.example").write File.read("config.example") if File.exist?("config.example")
  end

  def caveats
    <<~EOS
      i3wm-osx needs Accessibility and Input Monitoring permissions:
        System Settings → Privacy & Security → Accessibility → +
        → #{opt_prefix}/i3wm-osx.app

      Drop a config at ~/.config/i3wm-osx/config (sample at
      #{etc}/i3wm-osx/config.example).

      Start at login:
        brew services start i3wm-osx

      Run once:
        open #{opt_prefix}/i3wm-osx.app

      The bundle is signed with a stable self-signed identity, so TCC
      grants persist across `brew upgrade`. macOS will warn "unidentified
      developer" on first launch — right-click the bundle → Open.
    EOS
  end

  service do
    run [opt_prefix/"i3wm-osx.app/Contents/MacOS/i3wm-osx"]
    keep_alive true
    log_path var/"log/i3wm-osx.log"
    error_log_path var/"log/i3wm-osx.log"
  end

  test do
    assert_path_exists prefix/"i3wm-osx.app/Contents/MacOS/i3wm-osx"
    assert_path_exists bin/"i3-msg"
  end
end
