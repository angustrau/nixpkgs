
export PATH="$PWD/result/bin:$PATH"

ac_delim=^M

sed -n '
h
s/^/S["/; s/!.*/"]=/
p
g
s/^[^!]*!//
:repl
t repl
s/'"$ac_delim"'$//
t delim
:nl
h
s/\(.\{148\}\).*/\1/
t more1
s/["\\]/\\&/g; s/^/"/; s/$/\\n"\\/
p
n
b repl
:more1
s/["\\]/\\&/g; s/^/"/; s/$/"\\/
p
g
s/.\{148\}//
t nl
:delim
h
s/\(.\{148\}\).*/\1/
t more2
s/["\\]/\\&/g; s/^/"/; s/$/"/
p
b
:more2
s/["\\]/\\&/g; s/^/"/; s/$/"\\/
p
g
s/.\{148\}//
t delim
' </dev/null| sed '
/^[^""]/{
  N
  s/\n//
}
' > /dev/null
