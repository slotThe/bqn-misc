# Parsing a subset of JSON. The rules are:
#
# + Only integers.
# + Only ASCII in strings.
# + No constants.
# + Currently there is no input validation -- it better be valid!
#

# 'Lex json' yields 'tokens‿numbers‿strings', where 'tokens' is a string of
# characters each representing a token -- with '"' for strings and '0' for
# numbers --, 'numbers' is a list of numbers in order of occurrence, and
# 'strings' is a list of strings in order of occurrence.
#
#     Lex "{""a"": 123, ""bcde"": [1,42,30]}"
# ⟨ "{"":0,"":[0,0,0]}" ⟨ 123 1 42 30 ⟩ ⟨ "a" "bcde" ⟩ ⟩
Lex ← {
  x ← (¬∊)⟜(@+10‿13‿32)⊸/𝕩 # Remove whitespace
  # Numbers
  nb ← »⊸< n←x∊'0'+↕10     # Number beginnings
  numbers ← •Parsefloat¨ x⊔˜ 1-˜n×+`nb
  # Strings
  sb ← »⊸< s←≠`'"'=x       # String beginnings
  strings ← x⊔˜ 1-˜(s>sb)×+`sb
  # Tokenise
  ts ← nb∨sb∨x∊"{}[],:"    # Tokens
  ⟨ '0'¨⌾((ts/nb)⊸/) ts/x
    numbers
    strings
  ⟩
}

# XXX: WIP. Only parses purely numeric lists right now.
Parse ← {
  ts‿ns‿ss ← Lex 𝕩
  o←ts='[' ⋄ c←ts=']' ⋄ d←⍋+`(o-c)
  n ← ts∊"0]"                           # Numbers and nesting
  vi ← ⍋⍋ (n/ts='0') + 2×n/c            # Value indices
  l ← (⍋d)⊏+`'['=d⊏ts
  i ← vi⊏(↕≠ns)∾(≠ns)+ ≠⊸- c/»l
  vs ← ns
  {vs ∾↩ <𝕩⊏vs ⋄@}¨ ⌽i⊔˜(+´c)∾˜1-˜n/l
  ¯1⊑vs
}

### Tests

#### Lexing

⟨"{"":0,"":[0,0,0]}", 123‿1‿42‿30, "a"‿"bcde"⟩≡ Lex "{""a"": 123, ""bcde"": [1,42,30]}"

#### Parsing

⟨⟩≡ Parse "[ ]"
⟨1,2,3⟩≡ Parse " [ 1 , 2 , 3 ] "
⟨1,⟨42,⟨⟨0⟩,2,3⟩⟩,30⟩≡ Parse "[1, [42, [[0 ], 2, 3]], 30]"
⟨1,2,⟨⟩,⟨3,4,⟨5,6⟩⟩,7,8,⟨9,⟨⟩,10⟩⟩≡ Parse "[1,2,[ ],[3,4,[5,6]],7,8,[9,[],10]]"
