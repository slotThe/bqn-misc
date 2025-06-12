# Parsing a subset of JSON. The rules are:
#
# + Only integers.
# + Only ASCII in strings.
# + No constants.
# + Currently there is no input validation -- it better be valid!
#

# 'Tokenise json' yields 'tokens‿numbers‿strings', where 'tokens' is a string
# of characters each representing a token -- with '"' for strings and '0' for
# numbers --, 'numbers' is a list of numbers in order of occurrence, and
# 'strings' is a list of strings in order of occurrence.
#
#     Tokenise "{""a"": 123, ""bcde"": [1,42,30]}"
# ⟨ "{"":0,"":[0,0,0]}" ⟨ 123 1 42 30 ⟩ ⟨ "a" "bcde" ⟩ ⟩
Tokenise ← {
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
Tokenise "{""a"": 123, ""bcde"": [1,42,30]}"
# ⇒ ⟨ "{"":0,"":[0,0,0]}" ⟨ 123 1 42 30 ⟩ ⟨ "a" "bcde" ⟩ ⟩
