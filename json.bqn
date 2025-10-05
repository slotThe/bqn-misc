# Parsing a subset of JSON. The rules are:
#
# + Only positive integers.
# + Only ASCII in strings.
# + No constants.
# + Currently there is no input validation -- it better be valid!
#
# https://tony-zorman.com/posts/bqn-json.html

### Code

# 'Tokenise json' yields 'tokens‿numbers‿strings', where 'tokens' is a string
# of characters each representing a token -- with '"' for strings and '0' for
# numbers --, 'numbers' is a list of numbers in order of occurrence, and
# 'strings' is a list of strings in order of occurrence.
#
#     Tokenise "{""a"": 123, ""bcde"": [1,42,30]}"
# ⟨ "{"":0,"":[0,0,0]}" ⟨ 123 1 42 30 ⟩ ⟨ "a" "bcde" ⟩ ⟩
Tokenise ← {
  e  ← »<`'\'=𝕩                  # Escapes
  sb ← »⊸< s← ≠`(¬e)∧ '"'=𝕩      # String beginnings
  sr ← (1-˜(s>sb)×+`sb)⊔𝕩        # Strings to return

  ex ← s∨ 𝕩∊@+9‿10‿13‿32         # Exclude whitespace and strings
  nb ← »⊸< n← (¬ex)∧ 𝕩∊'0'+↕10   # Number beginnings
  nr ← •ParseFloat¨(1-˜n×+`nb)⊔𝕩 # Numbers to return

  ts ← sb∨(¬ex)∧nb∨𝕩∊"[]{},:"    # Tokens
  ⟨ts/ '0'¨⌾(nb⊸/) 𝕩, nr, sr⟩
}

Parse ← {
  ts‿nums‿strs ← Tokenise 𝕩
  d  ← ⍋+`(o←ts∊"{[")-(c←ts∊"]}") # Closing, opening, depth
  td ← d⊏ts                       # Tokens by depth
  s  ← td∊"[{"                    # Sublist starts
  n  ← (⍋d)⊏+`s                   # Nesting

  of ← s/'{'=td                   # Filter of subsists that are objects
  on ← +`⊸× of                    # Object nesting
  cl ← ':'=ts                     # Colon
  ks ← ((1+´of)∾˜ ('"'=ts)/(«cl)×n⊏0∾on)⊔strs    # Keys

  vs ← nums ∾ ⊑ks                 # Initial values
  ln ← ¬(«⊸∨cl)∨o∨','=ts          # Literals and nesting
  vi ← ⍋⍋ (ln/ts='0') + (2×ln/ts='"') + 3×ln/c   # Value indices
  vi ⊏↩ (↕≠vs)∾(≠vs)+ ≠⊸- c/»n                   # Fix value indices

  Sel ← {(𝕨⊑ks)≍𝕩}⍟(0<⊣)          # Select
  on {vs ∾↩ <𝕨Sel𝕩⊏vs ⋄@}¨○⌽ ((≠on)∾˜1-˜ln/n)⊔vi # Build result
  ¯1⊑vs
}

### Tests

O ← (⊑≍1⊸⊑) ≠⊸⥊⟜0‿1⊸⊔ # Build an object

!(O⟨"a",123,"bcde",1‿42‿30⟩)≡ Parse"{""a"": 123, ""bcde"": [1,42,30]}"
!(O⟨"a", 2⟩) ≡ Parse "{""a"": 2}"
!⟨1, O⟨"a",2⟩, 2⟩≡ Parse "[1, {""a"": 2}, 2]"
!⟨⟩≡ Parse "[ ]"
!(2‿0⥊@)≡ Parse "{}"
!(O⟨"a",⟨⟩⟩)≡ Parse "{""a"": []}"
!⟨1,2,3⟩≡ Parse " [ 1 , 2 , 3 ] "
!⟨1,⟨42,⟨⟨0⟩,2,3⟩⟩,30⟩≡ Parse "[1, [42, [[0 ], 2, 3]], 30]"
!⟨1,2,⟨⟩,⟨3,4,⟨5,6⟩⟩,7,8,⟨9,⟨⟩,10⟩⟩≡ Parse "[1,2,[ ],[3,4,[5,6]],7,8,[9,[],10]]"
!⟨1,"a",⟨⟩,⟨3,4,⟨5,"b"⟩⟩,7,8,⟨9,⟨⟩,"foo"⟩⟩≡ Parse "[1,""a"",[ ],[3,4,[5,""b""]],7,8,[9,[],""foo""]]"
