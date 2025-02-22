# Calculate all roots of the given Cartan matrix. The basic idea is as
# follows:
#
# - Given the Cartan matrix (Cᵢⱼ) of size n, we have as many simple root as
#   the diagonal. The simples are thus encoded as the columns of the identity
#   n×n matrix.
#
# - From these, one can calculate all positive roots in a sort of fixed-point
#   process: given a simple root αₖ and a positive one λ = ∑ᵢλᵢαᵢ (where the
#   set of positive roots starts out as the simples), compute r = -∑ᵢλᵢCᵢₖ.
#   If r is positive, then we obtain the αₖ-string through λ of length r as
#   λ, λ+αₖ, …, λ+r·aₖ.
#
# - The whole root system is obtained by simply adding all negative roots.
#
# Sources:
#   - Humphreys Section 11.1, page 56.
#   - https://math.stackexchange.com/questions/3265516/computing-all-the-roots-from-the-cartan-matrix

_fix ← {𝔽∘⊢⍟≢⟜𝔽_𝕣∘⊢⍟≢⟜𝔽𝕩}                              # 𝔽 _fix 𝕩
m ← [[2,¯1,0],[¯1,2,¯2],[0,¯1,2]]                      # B₃
nr ← ≠m                                                # Number of roots
sr ← =⌜˜↕nr                                            # Simple roots

rs ← { 𝕊rs:                                            # Positive roots
  ⍷rs∾ ∾⥊ sr{a𝕊c: {𝕊r: {𝕩>0? {r+𝕩×a}¨1+↕𝕩; ⟨⟩} -+´r×c}¨rs}˘⍉m
}_fix ⥊⋈˘sr
rs ∾↩ -¨¨rs                                            # Negative roots

# Output
s ← @+('α'-@)+↕nr                  # Human readable names for the roots.
((∾⟜"+"⊸∾)´(0⊸<≠)¨⊸/)¨{
  {𝕊·‿0:""; 𝕊i‿1:⋈i⊑s; 𝕊i‿¯1:'¯'∾⋈i⊑s; 𝕊i‿n:(•Fmt n)∾(i⊑s)}¨(↕≠𝕩)⋈¨𝕩
}¨rs
