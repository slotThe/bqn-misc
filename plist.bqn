# Parsing nested lists of the form
#
#     [1, [[2, 5], 3, [4]], 6]
#
# in both an array, and a recursive descent-like style.
#
# For now, mostly following
#
#     https://saltysylvi.github.io/blog/parsing-nested-lists-in-bqn.html

### Recursive descent approach

RDTok ← {
  ds ← »⊸<𝕩∊'0'+↕10         # Digits
  ts ← 𝕩∊"[]"               # Other tokens
  rs ← 1-˜(¬𝕩∊", ")×+`ts∨ds # Sum scan (for group) and eliminate commas and whitespace
  rs⊔𝕩
}
RDNum ← { ⟨•ParseFloat ⊑𝕩, 1↓𝕩⟩ }
RDLst ← {
  "]"≡⊑𝕩? ⟨𝕨, 1↓𝕩⟩;
  v‿rs ← RDVal 𝕩
  (𝕨∾<v) RDLst rs
}
RDVal ← { "["≡⊑𝕩? ⟨⟩ RDLst 1↓𝕩; RDNum 𝕩 }
RDParse ← ⊑∘RDVal∘RDTok

### Array approach

ATok ← RDTok
OB ← "["⊸≡¨     # Opening brackets
CB ← "]"⊸≡¨     # Closing brackets

AParse ← {
  d       ← +`∘(OB-CB) t←ATok𝕩    # Depth reading
  Split   ← { 1↓ 1⊸↓¨(+`OB𝕩)⊔𝕩 }
  Replace ← { 𝕨⌾((CB𝕩)⊸/)𝕩 }
  {⟨⟩≡𝕩?⟨⟩;•ParseFloat𝕩}⚇1 ⊑{(Split 𝕩) Replace 𝕨}´ d⊔t
}

# Going through this line by line:
#
#     t ← ATok"[1,[[2,[],5],3,[4]],6]"
# ⟨ "[" "1" "[" "[" "2" "[" "]" "5" "]" "3" "[" "4" "]" "]" "6" "]" ⟩
#     o ← "["⊸≡¨t
# ⟨ 1 0 1 1 0 1 0 0 0 0 1 0 0 0 0 0 ⟩
#     c ← "]"⊸≡¨t
# ⟨ 0 0 0 0 0 0 1 0 1 0 0 0 1 1 0 1 ⟩
#     d ← +`o-c
# ⟨ 1 1 2 3 3 4 3 3 2 2 3 3 2 1 1 0 ⟩
#     (⍋d)⊏t
# ⟨ "]" "[" "1" "]" "6" "[" "]" "3" "]" "[" "2" "]" "5" "[" "4" "[" ⟩
#
# Closing brackets indicate further nesting and opening brackets signify the
# start of a new sublist. Using these rules, this is just a bfs representation
# of the tree—drawing a tree on a piece of paper very much helps. A different
# Unicode representation, using ↓ for a closing bracket and ∘ for an opening
# one, yields
#
#     ↓
#     ∘ 1 ↓ 6
#         ∘ ↓   3    ↓
#           ∘ 2 ↓ 5  ∘ 4
#               ∘
#
# We can now partition the tokenised input according to the depth, carving out
# exactly the levels depicted above:
#
#     d ⊔ t
# ⟨ ⟨ "]" ⟩ ⟨ "[" "1" "]" "6" ⟩ ⟨ "[" "]" "3" "]" ⟩ ⟨ "[" "2" "]" "5" "[" "4" ⟩ ⟨ "[" ⟩ ⟩
#
# Splitting is standard:
#
#     { 1↓1⊸↓¨(+`"["⊸≡¨𝕩)⊔𝕩 } "["‿"3"‿"4"‿"]"‿"["‿"9"‿"10"
# ⟨ ⟨ "3" "4" "]" ⟩ ⟨ "9" "10" ⟩ ⟩
#
# And Replace should be self-explanatory as well. When folding, we split the
# accumulator on the first opening bracket, and then plug whatever we find
# into the closing bracket of the given element.
#
#     {(Split 𝕩) Replace 𝕨}´ d⊔t
# ┌─
# · ┌─
# · "1" ┌─                             "6"
#      · ⟨ "2" ⟨⟩ "5" ⟩ "3" ⟨ "4" ⟩
#                                   ┘
#                                         ┘
#                                           ┘
#
# The rest is just boilerplate so that a nicely formatted list falls out.

### Performance

# Some AoC day using exactly this format.
SplitF ⇐ { ((¯1+⊢×·+`»⊸<)¬𝕨⊸≡¨𝕩)⊔𝕩 }
input ← ']'∾˜ '['∾ ¯1↓ ∾ ∾⟜","¨ ∾⟨⟩SplitF •FLines"/home/slot/repos/advent/aoc2022/inputs/day13.txt"

(RDParse input) ≡ AParse input # ⇒ 1
100 RDParse•_timed input       # ⇒ 0.00311369804
100 AParse •_timed input       # ⇒ 0.00244539886
