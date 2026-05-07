class I3wmOsx < Formula
  desc "Tiling window manager for macOS that reads i3 config files"
  homepage "https://github.com/grepsedawk/i3wm-osx"
  url "https://github.com/grepsedawk/i3wm-osx/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "1547031ef2a99d3ddaea4821d5511d8be46d275a5ca10e7b1e8cd13a691a46a0"
  license "MIT"
  head "https://github.com/grepsedawk/i3wm-osx.git", branch: "main"

  depends_on macos: :ventura
  depends_on xcode: ["14.0", :build]

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release"

    bin_path = Utils.safe_popen_read("swift", "build", "-c", "release", "--show-bin-path").strip
    daemon = "#{bin_path}/i3wm-osx"
    msg = "#{bin_path}/i3-msg"

    app = prefix/"i3wm-osx.app"
    macos_dir = app/"Contents/MacOS"
    res_dir = app/"Contents/Resources"
    macos_dir.mkpath
    res_dir.mkpath

    cp daemon, macos_dir/"i3wm-osx"
    cp msg, macos_dir/"i3-msg"
    cp "Resources/Info.plist", app/"Contents/Info.plist"
    (app/"Contents/PkgInfo").write "APPL????"

    # Ad-hoc sign so the bundle launches; users who want stable TCC grants
    # across `brew upgrade` should run setup-signing.sh once and rebuild
    # locally (HOMEBREW_NO_INSTALL_FROM_API=1 brew install --build-from-source).
    system "codesign", "--force", "--deep", "--sign", "-",
           "--identifier", "org.piechowski.i3wm-osx", app

    bin.install_symlink macos_dir/"i3-msg"
    bin.install_symlink macos_dir/"i3wm-osx" => "i3wm-osx-bin"

    (etc/"i3wm-osx").mkpath
    cp "examples/config-macos", etc/"i3wm-osx/config.example"
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

      TCC grants persist across `brew upgrade` only if the cdhash is stable.
      Homebrew's bottle/build pipeline ad-hoc signs, so each install changes
      the cdhash and re-prompts for permissions. To pin a stable identity,
      run setup-signing.sh from the source repo and rebuild locally.
    EOS
  end

  service do
    run [opt_prefix/"i3wm-osx.app/Contents/MacOS/i3wm-osx"]
    keep_alive true
    log_path var/"log/i3wm-osx.log"
    error_log_path var/"log/i3wm-osx.log"
  end

  test do
    assert_match "i3wm-osx", shell_output("#{bin}/i3-msg --version 2>&1", 0..1)
  end
end
