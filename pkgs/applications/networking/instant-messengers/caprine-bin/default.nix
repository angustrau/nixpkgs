{ pkgs, stdenv }:
let
  version = "2.51.2";
  callBin = pathExpression:
    (pkgs.callPackage pathExpression { inherit version; }).overrideAttrs
    (oldAttrs: { meta = meta // (oldAttrs.meta or { }); });
  passthru = {
    appimage = callBin ./appimage.nix;
  };
  meta = with stdenv.lib; {
    description = "An elegant Facebook Messenger desktop app";
    homepage = "https://sindresorhus.com/caprine/";
    license = licenses.mit;
    maintainers = with maintainers; [ ShamrockLee ];
  };
in passthru.appimage.overrideAttrs (oldAttrs: {
  passthru = (oldAttrs.passthru or { }) // passthru;
  meta = oldAttrs.meta // {
    platforms = passthru.appimage.meta.platforms;
  };
})
