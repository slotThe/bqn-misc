# https://www.sumsar.net/blog/pandas-feels-clunky-when-coming-from-r/
⟨CSV⟩←•Import"../csv/csv.bqn"
[c,a,d]←•ParseFloat⎊⊢¨⍉>1↓CSV•FChars"./purchases.csv" ⋄ p←⊐c

# “How much do we sell..? Let’s take the total sum!”
+´a

# “Ah, they wanted it by country…”
(⍷c)≍+´¨p⊔a

# “And I guess I should deduct the discount.”
(⍷c)≍+´¨p⊔a-d

# “Oh, and Maria asked me to remove any outliers. Let’s remove everything 10x larger than the median.”
(⍷c)≍+´¨(p⊔a)-○((p⊔{𝕩≤10×(∧⊑˜2⌊∘÷˜≠)𝕩}   a)/¨⊢)(p⊔d)

# “I probably should use the median within each country. Prices are quite different across the globe…”
(⍷c)≍+´¨(p⊔a)-○((  {𝕩≤10×(∧⊑˜2⌊∘÷˜≠)𝕩}¨p⊔a)/¨⊢)(p⊔d)
# ┌─
# ╵ "USA" "Canada" "UK" "France" "Germany" "Australia" "Italy" "Spain" "Japan" "India" "Brazil"
#   8455  270      432  450      513       540         567     594     621     648     414
#                                                                                               ┘
