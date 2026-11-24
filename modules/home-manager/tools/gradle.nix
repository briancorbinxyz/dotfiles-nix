{
  config,
  pkgs,
  lib,
  ...
}:

# Registers the Nix-provided JDKs with Gradle, so a `JavaLanguageVersion.of(n)`
# toolchain block resolves off disk instead of going looking.
#
# The problem this solves: Gradle toolchains declare intent but delegate
# discovery to auto-detection, and auto-detection was coming up short here.
# JAVA_HOME was unset and /usr/libexec/java_home reported no runtime at all
# (asdf installs itself outside macOS's registry), so Gradle fell through to
# the foojay resolver and downloaded its own — ~528MB of JDK archives from
# three vendors had accumulated under ~/.gradle/jdks, including an Azul Zulu 25
# alongside an asdf Temurin 25 that would have done.
#
# org.gradle.java.installations.paths is Gradle's explicit registry: given it,
# detection is a disk read. It has to be a *Gradle property*, which means a
# gradle.properties file — passing -Dorg.gradle.java.installations.paths via
# GRADLE_OPTS does NOT work, because GRADLE_OPTS configures the client JVM
# while toolchain detection happens in the daemon, which never sees it.
#
# Deliberately user-level rather than per-project: it then applies to every
# Gradle repo on this machine and needs no .envrc, no flake and no committed
# file in any project, so contributors are entirely unaffected.
#
# Writing the store paths here is also what keeps the JDKs alive — the
# generated file references them, so the home-manager generation roots them
# against nix-collect-garbage.
#
# auto-download is left enabled on purpose: a build asking for a version not
# listed in modules/jdks.nix still works, it just falls back to the network.
# Add `org.gradle.java.installations.auto-download=false` below to make that a
# hard error instead.
let
  jdks = import ../../jdks.nix pkgs;
in
{
  home.file.".gradle/gradle.properties".text = ''
    # Managed by home-manager (modules/home-manager/tools/gradle.nix).
    # JDK set is defined in modules/jdks.nix.
    org.gradle.java.installations.paths=${jdks.installationPaths}
  '';
}
