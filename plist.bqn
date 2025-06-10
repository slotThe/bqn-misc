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

### Array approach, still nested

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

### Flat array approach

FATok ← {
  ns ← »⊸< n←𝕩∊'0'+↕10
  ds ← •ParseFloat¨(1-˜n×+`ns)⊔𝕩  # All digits
  f  ← ns∨𝕩∊"[]"                  # First occurrences
  ⟨ '·'¨⌾((f/n)⊸/)(f/𝕩), ds ⟩
}

#     a ← "[1,2,[3,4,[5,6]],7,8,[9,10]]"
# "[1,2,[3,4,[5,6]],7,8,[9,10]]"
#     ns ← »⊸< n←a∊'0'+↕10        # ns is the first occurrence of a number (so "10" gets 1‿0)
# ⟨ 0 1 0 1 0 0 1 0 1 0 0 1 0 1 0 0 0 1 0 1 0 0 1 0 1 0 0 0 ⟩
#     n                           # n is all numbers (so "10" gets 1‿1)
# ⟨ 0 1 0 1 0 0 1 0 1 0 0 1 0 1 0 0 0 1 0 1 0 0 1 0 1 1 0 0 ⟩
#     ds ← •ParseFloat¨(1-˜n×+`ns)⊔a # Number tokens in a separate list
# ⟨ 1 2 3 4 5 6 7 8 9 10 ⟩
#     f  ← ns∨a∊"[]"                 # First occurrences of everything
# ⟨ 1 1 0 1 0 1 1 0 1 0 1 1 0 1 1 1 0 1 0 1 0 1 1 0 1 0 1 1 ⟩
#
# At this point we need to work with the shape of the array we are trying to
# build -- that in which everything is represented by one character only.
#
#     f/a                 # Shape of the new array
# "[12[34[56]]78[91]]"
#     f/n                 # What are the number tokens in the new array?
# ⟨ 0 1 1 0 1 1 0 1 1 0 0 1 1 0 1 1 0 0 ⟩
#     '·'¨⌾((f/n)⊸/)(f/a) # Replace numbers with '·'
# "[··[··[··]]··[··]]"

FAParse ← {
  tok‿num ← FATok 𝕩
  o ← '['=tok
  c ← ']'=tok
  g ← ⍋+`(o-c)          # Grading by depth
  f ← tok∊"·]"          # Numbers and nesting
  k ← ⍋⍋ (f/'·'=tok) + 2×f/c
  l ← (⍋g)⊏ +`'['=g⊏tok # Sublist index
  i ← k ⊏ (↕nv) ∾ (nv←≠num)+ ≠⊸- c/»l
  val ← num             # Mutation is evil
  {val∾↩<𝕩⊏val⋄@}¨ ⌽((+´c)∾˜1-˜f/l)⊔i
  ¯1⊑val
}

# This one is a real doozy. The first few steps are not so complicated:
#
#     tok‿num ← FATok "[1,2,[],[3,4,[5,6]],7,8,[9,10]]"
# ⟨ "[··[][··[··]]··[··]]" ⟨ 1 2 3 4 5 6 7 8 9 10 ⟩ ⟩
#     o ← '['=tok
# ⟨ 1 0 0 1 0 1 0 0 1 0 0 0 0 0 0 1 0 0 0 0 ⟩
#     c ← ']'=tok
# ⟨ 0 0 0 0 1 0 0 0 0 0 0 1 1 0 0 0 0 0 1 1 ⟩
#     g ← ⍋+`(o-c)
# ⟨ 19 0 1 2 4 12 13 14 18 3 5 6 7 11 15 16 17 8 9 10 ⟩
#
# A standard ordering things by depth. We know this. Then we get the numbers
# and additional sublists (nesting) from the original token array.
#
#     tok≍ nn←tok∊"·]"
# ┌─
# ╵ '[' '·' '·' '[' ']' '[' '·' '·' '[' '·' '·' ']' ']' '·' '·' '[' '·' '·' ']' ']'
#    0   1   1   0   1   0   1   1   0   1   1   1   1   1   1   0   1   1   1   1
#                                                                                   ┘
# Now we concentrate on these values and further sublists.
#
#     nn/tok
# "··]····]]····]]"
#     (nn/tok) ≍ (nn/'·'=tok) + 2×nn/c
# ┌─
# ╵ '·' '·' ']' '·' '·' '·' '·' ']' ']' '·' '·' '·' '·' ']' ']'
#    1   1   2   1   1   1   1   2   2   1   1   1   1   2   2
#                                                               ┘
# We can use the ordinals pattern to see where the individual things would end
# up with were we to sort the list.
#
#     k ← ⍋⍋ (nn/'·'=tok) + 2×nn/c
# ⟨ 0 1 10 2 3 4 5 11 12 6 7 8 9 13 14 ⟩
#     (nn/tok)≍k
# ┌─
# ╵ '·' '·' ']' '·' '·' '·' '·' ']' ']' '·' '·' '·' '·' ']' ']'
#    0   1   10  2   3   4   5   11  12  6   7   8   9   13  14
#                                                                ┘
# This at least gets us the right indices for all numbers. However, the
# sublists are not quite right, still, but not unexpected -- so far we haven't
# used the opening brackets at all! This is where things get spicy. We first
# want to order the sublists according to their depth.
#
#
#     g⊏tok              # depth ordering again
# "][··]]··][[··][··[··"
#     +`'['=g⊏tok
# ⟨ 0 1 1 1 1 1 1 1 1 2 3 3 3 3 4 4 4 5 5 5 ⟩
#
# Crucially, however, we don't want this depth index in depth order, but in
# the ordinary order that 'tok' and also 'k' are in. This we can do with the
# observation that we can easily invert permutations with ⍋.
#
#     tok≍ l←(⍋g)⊏+`'['=g⊏tok
# ┌─
# ╵ '[' '·' '·' '[' ']' '[' '·' '·' '[' '·' '·' ']' ']' '·' '·' '[' '·' '·' ']' ']'
#    1   1   1   2   1   3   3   3   5   5   5   3   1   1   1   4   4   4   1   0
#                                                                                   ┘
# With this we can essentially number the sublists of the structure by depth.
#
#     c/»l
# ⟨ 2 5 3 4 1 ⟩
#
# Aligning the indices with the sublists yields something like
#
#     [··[][··[··]]··[··]]
#         2      53     41
#
# This means that, at the end, we shall construct sublist 2 first, then 5,
# then 3, and so on. Since we build the list depth-first, we need to invert
# the current order, and also take into consideration that we have values to
# insert.
#
#     (nv←≠num)+ ≠⊸- c/»l
# ⟨ 13 10 12 11 14 ⟩
#
# We can finally build the full list of indices, and use the value indices to
# index them.
#
#     (↕nv) ∾ (nv←≠num)+ ≠⊸- c/»l
# ⟨ 0 1 2 3 4 5 6 7 8 9 13 10 12 11 14 ⟩
#     i ← k⊏(↕nv) ∾ (nv←≠num)+ ≠⊸- c/»l
# ⟨ 0 1 13 2 3 4 5 10 12 6 7 8 9 11 14 ⟩
#
# Almost done -- all that's left is to build everything up recursively, just
# as we did in the nested array version.
#
#     (+´c)∾˜1-˜nn/l
# ⟨ 0 0 0 2 2 4 4 2 0 0 0 3 3 0 ¯1 5 ⟩
#     ⌽((+´c)∾˜1-˜nn/l)⊔i
# ⟨ ⟨ 4 5 ⟩ ⟨ 8 9 ⟩ ⟨ 2 3 15 ⟩ ⟨⟩ ⟨ 0 1 12 13 6 7 14 ⟩ ⟩
#
#     val ← num             # Mutation is evil
#     {val∾↩<𝕩⊏val⋄@}¨ ⌽((+´c)∾˜1-˜nn/l)⊔i
#     ¯1⊑val
# ┌─
# · 1 2 ⟨⟩ ⟨ 3 4 ⟨ 5 6 ⟩ ⟩ 7 8 ⟨ 9 10 ⟩
#                                       ┘
#     a
# "[1,2,[],[3,4,[5,6]],7,8,[9,10]]"

### Performance

# Some AoC day using exactly this format.
SplitF ⇐ { ((¯1+⊢×·+`»⊸<)¬𝕨⊸≡¨𝕩)⊔𝕩 }
input ← ']'∾˜ '['∾ ¯1↓ ∾ ∾⟜","¨ ∾⟨⟩SplitF •FLines"/home/slot/repos/advent/aoc2022/inputs/day13.txt"

(RDParse input) ≡ AParse input  # ⇒ 1
(FAParse input) ≡ AParse input  # ⇒ 1
100 RDParse•_timed input        # ⇒ 0.00269128438
100 AParse •_timed input        # ⇒ 0.00236296291
100 FAParse•_timed input        # ⇒ 0.00118868171
