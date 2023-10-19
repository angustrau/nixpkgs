{ callPackage, llvm_16, llvm_14, llvm_11 }:
callPackage ./generic.nix {
  # version = "1.35.0";
  # sha256 = "sha256-bilpk3BsdsCT5gkTmqCz+HBDVfoPN1b2dY141EIm36A=";
  # version = "1.32.0";
  # sha256 = "1b5y57in1r6j2aqvx0n7k72011m4nrkv5nak2djdava13gwhpvn4";
  # version = "1.30.0";
  # sha256 = "1kfs4fpr1525sv2ny10hlfppy8c075vjm8m649wr2b9411pkgfzx";
  version = "1.29.0";
  sha256 = "0h51mslahp176yg1yq33lgzvjl9lb06c0xaykifn4rsljvmndh6h";
  # llvm = llvm_16;
  # llvm = llvm_14;
  llvm = llvm_11;
  bootstrapping = false;
  ldcBootstrap = callPackage ./bootstrap.nix { };
}
