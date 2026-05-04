# Like p.bqn, but the table is a namespace, with each row a field (keyed by
# the first letter of the header).
⟨CSV⟩←•Import"../csv/csv.bqn"
t←{(•BQN"{["∾(1↓∾(','⊸∾⊑)¨⊑𝕩)∾"]⇐𝕩}"){𝕎𝕩}•ParseFloat⎊⊢¨⍉>1↓𝕩}CSV•FChars"./purchases.csv" ⋄ p←⊐t.c

# “How much do we sell..? Let’s take the total sum!”
+´t.a

# “Ah, they wanted it by country…”
(⍷t.c)≍+´¨p⊔t.a

# “And I guess I should deduct the discount.”
(⍷t.c)≍+´¨p⊔t.a-t.d

# “Oh, and Maria asked me to remove any outliers. Let’s remove everything 10x larger than the median.”
(⍷t.c)≍+´¨(p⊔t.a)-○((p⊔{𝕩≤10×(∧⊑˜2⌊∘÷˜≠)𝕩}   t.a)/¨⊢)(p⊔t.d)

# “I probably should use the median within each country. Prices are quite different across the globe…”
(⍷t.c)≍+´¨(p⊔t.a)-○((  {𝕩≤10×(∧⊑˜2⌊∘÷˜≠)𝕩}¨p⊔t.a)/¨⊢)(p⊔t.d)
# ┌─
# ╵ "USA" "Canada" "UK" "France" "Germany" "Australia" "Italy" "Spain" "Japan" "India" "Brazil"
#   8455  270      432  450      513       540         567     594     621     648     414
#                                                                                               ┘
