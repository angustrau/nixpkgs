{ lib
, buildGoModule
, fetchFromGitHub
, hamlib
}:
buildGoModule rec {
  pname = "pat";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "la5nta";
    repo = pname;
    rev = "v${version}";
    sha256 = "ydv7RQ6MJ+ifWr+babdsDRnaS7DSAU+jiFJkQszy/Ro=";
  };

  vendorHash = "sha256-TMi5l9qzhhtdJKMkKdy7kiEJJ5UPPJLkfholl+dm/78=";

  meta = with lib; {
    description = "Cross-platform Winlink client";
    homepage = "https://getpat.io";
    license = licenses.mit;
    maintainers = with maintainers; [ emilytrau ];
  };
}
