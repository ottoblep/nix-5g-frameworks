{ config, pkgs, lib, ... }:
{
  boot.extraModulePackages = [
    (config.boot.kernelPackages.callPackage ../../pkgs/gtp5g { })
  ];
}