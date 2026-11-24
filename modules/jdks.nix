# The JDK set shared by the Gradle toolchain registry
# (home-manager/tools/gradle.nix) and the mutastic-java devShell in flake.nix.
# Kept in one place so the two can't drift: Gradle resolves toolchains from
# `all`, and the devShell puts `primary` on PATH.
#
# Temurin rather than pkgs.jdk*, for two reasons. It's the vendor the asdf
# setup already used, so nothing silently switches to a Zulu or OpenJDK build
# — and the jdk* attributes stop at 25 while temurin-bin reaches 27.
#
# This is every GA JDK that still has a Temurin build on all three supported
# systems, not a selection: Temurin removed 23 and 24 at end of life, and 8
# has no aarch64 build at all.
pkgs:

rec {
  all = with pkgs; [
    temurin-bin-11 # 11.0.32  legacy LTS
    temurin-bin-17 # 17.0.20  LTS
    temurin-bin-21 # 21.0.12  LTS
    temurin-bin-25 # 25.0.4   LTS
    temurin-bin-26 # 26.0.2   GA
    temurin-bin-27 # 27.0.0   GA, current
  ];

  # What bare `java` resolves to: the newest LTS, and the version most of the
  # mutastic toolchain blocks ask for.
  primary = pkgs.temurin-bin-25;

  # Comma-separated JAVA_HOMEs, the format Gradle's
  # org.gradle.java.installations.paths expects.
  installationPaths = pkgs.lib.concatMapStringsSep "," (jdk: jdk.home) all;
}
