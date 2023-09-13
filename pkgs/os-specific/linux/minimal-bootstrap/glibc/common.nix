{ lib }:
{
  pname = "glibc";

  meta = with lib; {
    description = "The GNU C Library";
    homepage = "https://www.gnu.org/software/libc";
    license = licenses.lgpl2Plus;
    maintainers = teams.minimal-bootstrap.members;
    platforms = platforms.linux;
  };
}
