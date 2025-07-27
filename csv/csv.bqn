# A very simple CSV parser.
#
# This deliberately accepts all kinds of CSV that might not exactly be
# RFC 4180 compliant. For example, lines don't necessarily have to have the
# same number of fields (in which case the corresponding list element just has
# fewer elements), and lines may end with commas (in which case the list will
# have an empty list as its last element). I also pretend that CRLF is just LF
# (and in general that CR does not exist).

CSV ⇐ { 𝕊x: ','𝕊x;
  [q,s,n] ← ('"'∾𝕨∾@+10) =⌜ 𝕩            # Quote, separator, LF
  e  ← ≠`q                               # Escapes
  sp ← (¬e)∧n∨s                          # Where to split
  d  ← sp∨q∧e∨«⊸<q                       # What to drop
  (0∾sp/+`(¬e)∧n) ⊔ (1-˜(¬d)×1+`sp) ⊔ 𝕩  # First split all, then split lines
}
