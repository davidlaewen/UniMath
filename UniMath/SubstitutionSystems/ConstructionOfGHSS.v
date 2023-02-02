(** construction of generalized heterogeneous substitution systems from arbitrary final coalgebras
   and from initial algebras arising from iteration in omega-cocontinuous functors

authors: Ralph Matthes, Kobe Wullaert, 2023
*)


Require Import UniMath.Foundations.All.
Require Import UniMath.MoreFoundations.All.
Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Functors.
Require Import UniMath.CategoryTheory.Core.NaturalTransformations.
Require Import UniMath.CategoryTheory.Core.Isos.

Require Import UniMath.CategoryTheory.limits.terminal.
Require Import UniMath.CategoryTheory.limits.bincoproducts.
Require Import UniMath.CategoryTheory.FunctorCoalgebras.
Require Import UniMath.CategoryTheory.coslicecat.
Require Import UniMath.CategoryTheory.limits.initial.
Require Import UniMath.CategoryTheory.limits.graphs.colimits.
Require Import UniMath.CategoryTheory.Chains.Chains.
Require Import UniMath.CategoryTheory.Chains.Adamek.
Require Import UniMath.CategoryTheory.FunctorAlgebras.
Require Import UniMath.CategoryTheory.Chains.OmegaCocontFunctors.

Require Import UniMath.CategoryTheory.DisplayedCats.Core.
Require Import UniMath.CategoryTheory.DisplayedCats.Constructions.
Require Import UniMath.CategoryTheory.DisplayedCats.Total.

Require Import UniMath.CategoryTheory.Monoidal.WhiskeredBifunctors.
Require Import UniMath.CategoryTheory.Monoidal.MonoidalCategoriesWhiskered.
Require Import UniMath.CategoryTheory.Monoidal.CategoriesOfMonoidsWhiskered.
Require Import UniMath.CategoryTheory.Monoidal.Actegories.
Require Import UniMath.CategoryTheory.Monoidal.ConstructionOfActegories.
Require Import UniMath.CategoryTheory.Monoidal.MorphismsOfActegories.
Require Import UniMath.CategoryTheory.Monoidal.CoproductsInActegories.
Require Import UniMath.CategoryTheory.Monoidal.Examples.MonoidalPointedObjects.
Require Import UniMath.CategoryTheory.Monoidal.WhiskeredBifunctors.

Require Import UniMath.SubstitutionSystems.GeneralizedSubstitutionSystems.
Require Import UniMath.SubstitutionSystems.ActionScenarioForGenMendlerIteration_alt.
Require Import UniMath.SubstitutionSystems.SigmaMonoids.

Local Open Scope cat.

Import BifunctorNotations.
Import MonoidalNotations.

Section FixTheContext.

  Context {V : category} {Mon_V : monoidal V}
          {H : V ⟶ V} (θ : pointedtensorialstrength Mon_V H).

  Let PtdV : category := GeneralizedSubstitutionSystems.PtdV Mon_V.
  Let Mon_PtdV : monoidal PtdV := GeneralizedSubstitutionSystems.Mon_PtdV Mon_V.
  Let Act : actegory Mon_PtdV V:= GeneralizedSubstitutionSystems.Act Mon_V.

  Context  (CP : BinCoproducts V) (δ : bincoprod_distributor Mon_PtdV CP Act).

  Let Const_plus_H (v : V) : functor V V := GeneralizedSubstitutionSystems.Const_plus_H H CP v.

  Definition I_H : functor V V := Const_plus_H I_{Mon_V}.

Section TerminalCoalgebraToGHSS.

  Context (νH : coalgebra_ob I_H)
          (isTerminalνH : isTerminal (CoAlg_category I_H) νH).

  Let t : V := pr1 νH.
  Let out : t --> I_H t := pr2 νH.
  Let out_z_iso : z_iso t (I_H t) := terminalcoalgebra_z_iso _ I_H νH isTerminalνH.
  Let out_inv : I_H t --> t := inv_from_z_iso out_z_iso.

  Definition terminal_coalg_to_ghss_step_term
             {Z : PtdV} (f : V⟦ pr1 Z, t ⟧)
    : V ⟦ Z ⊗_{Act} t, I_H (CP (Z ⊗_{Act} t) t) ⟧.
  Proof.
    refine (Z ⊗^{Act}_{l} out · _).
    refine (δ _ _ _ · _).
    refine (BinCoproductOfArrows _ (CP _ _) (CP _ _) (ru_{Mon_V} _) (pr1 θ Z t) · _).
    refine (# (Const_plus_H (pr1 Z)) (BinCoproductIn1 (CP _ t)) · _).
    exact (BinCoproductArrow (CP _ _) (f · out · #I_H (BinCoproductIn2 (CP _ _))) (BinCoproductIn2 _)).
  Defined.

  Let η := BinCoproductIn1 (CP I_{Mon_V} (H t)) · out_inv.
  Let τ := BinCoproductIn2 (CP I_{Mon_V} (H t)) · out_inv.

  Lemma ητ_is_out_inv : BinCoproductArrow (CP I_{ Mon_V} (H t)) η τ = out_inv.
  Proof.
    apply pathsinv0, BinCoproductArrowEta.
  Qed.

  Local Definition ϕ {Z : PtdV} (f : V⟦ pr1 Z, t ⟧)
    := terminal_coalg_to_ghss_step_term f.
  Local Definition Corec_ϕ {Z : PtdV} (f : V⟦ pr1 Z, t ⟧)
    := primitive_corecursion CP isTerminalνH (x :=  Z ⊗_{Act} t) (ϕ f).

  Local Lemma changing_the_constant_Const_plus_H (x y v w : V)
    (f : v --> w) (fm : w --> v) (g : x --> Const_plus_H y w) (fmf : fm · f = identity _) :
    # (Const_plus_H x) f · BinCoproductArrow (CP _ _) g (BinCoproductIn2 _) =
      BinCoproductArrow (CP _ _) (g · # (Const_plus_H y) fm) (BinCoproductIn2 _) · # (Const_plus_H y) f.
  Proof.
    use BinCoproductArrowsEq.
    - etrans.
      { rewrite assoc.
        apply cancel_postcomposition.
        apply BinCoproductOfArrowsIn1. }
      etrans.
      { rewrite assoc'.
        apply maponpaths.
        apply BinCoproductIn1Commutes. }
      etrans.
      2: { rewrite assoc.
           apply cancel_postcomposition.
           apply pathsinv0, BinCoproductIn1Commutes. }
      etrans.
      2: { rewrite assoc'.
           apply maponpaths.
           apply functor_comp. }
      rewrite fmf.
      rewrite functor_id.
      rewrite id_right.
      apply id_left.
    - etrans.
      { rewrite assoc.
        apply cancel_postcomposition.
        apply BinCoproductOfArrowsIn2. }
      etrans.
      { rewrite assoc'.
        apply maponpaths.
        apply BinCoproductIn2Commutes. }
      etrans.
      2: { rewrite assoc.
           apply cancel_postcomposition.
           apply pathsinv0, BinCoproductIn2Commutes. }
      etrans.
      2: { apply pathsinv0, BinCoproductOfArrowsIn2. }
      apply idpath.
  Qed.

  Lemma terminal_coalg_to_ghss_has_equivalent_characteristic_formula
    {Z : PtdV} (f : V⟦ pr1 Z, t ⟧) (h : V⟦ Z ⊗_{Act} t, t ⟧) :
    primitive_corecursion_characteristic_formula CP (ϕ f) h <->
      gbracket_property_parts Mon_V H θ t η τ (pr2 Z) f h.
  Proof.
    split.
    - intro Hcorec.
      apply (pr2 (gbracket_property_single_equivalent _ _ _ _ _ _ CP _ _ _)).
      red.
      red in Hcorec.
      fold out t in Hcorec.
      rewrite ητ_is_out_inv.
      apply pathsinv0, (z_iso_inv_on_left _ _ _ _ out_z_iso) in Hcorec.
      etrans.
      { apply maponpaths.
        exact Hcorec. }
      clear Hcorec.
      unfold ϕ, terminal_coalg_to_ghss_step_term.
      etrans.
      { repeat rewrite assoc.
        do 6 apply cancel_postcomposition.
        rewrite assoc'.
        apply maponpaths.
        etrans.
        { apply pathsinv0, (functor_comp (leftwhiskering_functor Act Z)). }
        etrans.
        { apply maponpaths.
          apply (pr222 out_z_iso). }
        apply (functor_id (leftwhiskering_functor Act Z)).
      }
      rewrite id_right.
      etrans.
      { do 5 apply cancel_postcomposition.
        apply (pr2 δ). }
      rewrite id_left.
      repeat rewrite assoc'.
      apply maponpaths.
      etrans.
      { apply maponpaths.
        rewrite assoc.
        apply cancel_postcomposition.
        rewrite (assoc f out).
        apply pathsinv0.
        use changing_the_constant_Const_plus_H.
        apply BinCoproductIn2Commutes.
      }
      etrans.
      { repeat rewrite assoc.
        do 2 apply cancel_postcomposition.
        etrans.
        { apply pathsinv0, (functor_comp (Const_plus_H (pr1 Z))). }
        apply maponpaths.
        apply BinCoproductIn1Commutes.
      }
      repeat rewrite assoc'.
      apply maponpaths.
      etrans.
      { apply postcompWithBinCoproductArrow. }
      rewrite assoc'.
      apply maponpaths_2.
      etrans.
      { apply maponpaths.
        apply (pr122 out_z_iso). }
      apply id_right.
    - intro Hghss.
      apply (pr1 (gbracket_property_single_equivalent _ _ _ _ _ _ CP _ _ _)) in Hghss.
      red.
      red in Hghss.
      fold out t.
      rewrite ητ_is_out_inv in Hghss.
      rewrite assoc' in Hghss.
      apply (z_iso_inv_to_left _ _ _ (_,,bincoprod_functor_lineator_strongly
                                        Mon_PtdV CP Act δ (pr1 Z,, pr2 Z) (I_{ Mon_V},,H t))) in Hghss.
      apply (z_iso_inv_to_left _ _ _ (functor_on_z_iso (leftwhiskering_functor Act (pr1 Z,, pr2 Z)) out_z_iso)) in Hghss.
      etrans.
      { apply cancel_postcomposition.
        exact Hghss. }
      clear Hghss.
      unfold ϕ, terminal_coalg_to_ghss_step_term.
      repeat rewrite assoc'.
      do 2 apply maponpaths.
      etrans.
      2: { do 2 apply maponpaths.
           rewrite (assoc f out).
           use changing_the_constant_Const_plus_H.
           apply BinCoproductIn2Commutes. }
      apply maponpaths.
      etrans.
      2: { repeat rewrite assoc.
           apply cancel_postcomposition.
           etrans.
           2: { apply (functor_comp (Const_plus_H (pr1 Z))). }
           apply maponpaths.
           apply pathsinv0, BinCoproductIn1Commutes.
      }
      apply maponpaths.
      etrans.
      { apply postcompWithBinCoproductArrow. }
      apply maponpaths.
      unfold τ.
      etrans.
      { rewrite assoc'.
        apply maponpaths.
        apply (pr222 out_z_iso). }
      apply id_right.
  Qed.

  Definition terminal_coalg_to_ghss : ghss Mon_V H θ.
  Proof.
    exists t.
    exists η.
    exists τ.
    intros Z f.
    simple refine (iscontrretract _ _ _ (Corec_ϕ f)).
    - intros [h Hyp].
      exists h. apply terminal_coalg_to_ghss_has_equivalent_characteristic_formula. exact Hyp.
    - intros [h Hyp].
      exists h. apply terminal_coalg_to_ghss_has_equivalent_characteristic_formula. exact Hyp.
    - intros [h Hyp].
      use total2_paths_f.
      + apply idpath.
      + apply isaprop_gbracket_property_parts.
  Defined.


End TerminalCoalgebraToGHSS.

Section InitialAlgebraToGHSS.

  Context (IV : Initial V) (CV : Colims_of_shape nat_graph V) (HH : is_omega_cocont H).

  Let AF := FunctorAlg I_H.
  Let chnF := initChain IV I_H.

  Let t_Initial : Initial AF := colimAlgInitial IV (ActionScenarioForGenMendlerIteration_alt.HF CP H HH I_{Mon_V})  (CV chnF).
  Let t : V := alg_carrier _ (InitialObject t_Initial).
  Let α : I_H t --> t := alg_map I_H (pr1 t_Initial).

  Let η := BinCoproductIn1 (CP _ _) · α.
  Let τ := BinCoproductIn2 (CP _ _) · α.

  (** a more comfortable presentation of the standard iteration scheme *)
  Definition Iteration_I_H (av : V) (aη : I_{Mon_V} --> av) (aτ : H av --> av) : ∃! h : V⟦t,av⟧, τ · h = # H h · aτ × η · h = aη.
  Proof.
    transparent assert (aα : (ob AF)).
    { use tpair.
      - exact av.
      - cbn. unfold BinCoproduct_of_functors_ob, constant_functor.
        cbn.
        exact (BinCoproductArrow (CP _ _) aη aτ).
    }
    simple refine (iscontrretract _ _ _ (pr2 t_Initial aα)).
    - intros [h Hyp].
      exists h.
      cbn in Hyp.
      split.
      + apply (maponpaths (fun x => BinCoproductIn2 _ · x)) in Hyp.
        rewrite assoc in Hyp.
        etrans.
        { exact Hyp. }
        etrans.
        { apply maponpaths.
          apply precompWithBinCoproductArrow. }
        apply BinCoproductIn2Commutes.
      + apply (maponpaths (fun x => BinCoproductIn1 _ · x)) in Hyp.
        rewrite assoc in Hyp.
        etrans.
        { exact Hyp. }
        etrans.
        { apply maponpaths.
          apply precompWithBinCoproductArrow. }
        cbn.
        rewrite id_left.
        apply BinCoproductIn1Commutes.
    - intros [h [Hyp1 Hyp2]].
      exists h.
      cbn.
      etrans.
      { apply cancel_postcomposition.
        apply BinCoproductArrowEta. }
      etrans.
      { apply postcompWithBinCoproductArrow. }
      etrans.
      2: { apply pathsinv0, precompWithBinCoproductArrow. }
      apply maponpaths_12.
      + cbn. rewrite id_left. exact Hyp2.
      + cbn. exact Hyp1.
    - intros [h Hyp].
      use total2_paths_f.
      + apply idpath.
      + apply isapropdirprod; apply V.
  Defined.


  Context (initial_annihilates : ∏ (v : V), isInitial V (v ⊗_{Mon_V} (InitialObject IV))).
  Context (left_whiskering_omega_cocont : ∏ (v : V), is_omega_cocont (leftwhiskering_functor Mon_V v)).

  Definition initial_alg_to_ghss : ghss Mon_V H θ.
  Proof.
    exists t.
    exists η.
    exists τ.
    intros Z f.
    red.
    unfold gbracket_property_parts.
    set (Mendler_inst := SpecialGenMendlerIterationWithActegoryAndStrength Mon_PtdV IV CV Act
                           Z CP H HH I_{Mon_V} t θ τ (ru^{Mon_V}_{ pr1 Z} · f)
                           (initial_annihilates (pr1 Z)) (left_whiskering_omega_cocont (pr1 Z)) δ).
    simple refine (iscontrretract _ _ _ Mendler_inst).
    - intros [h [Hyp1 Hyp2]].
      exists h.
      split; apply pathsinv0; assumption.
    - intros [h [Hyp1 Hyp2]].
      exists h.
      split; apply pathsinv0; assumption.
    - intros [h Hyp].
      use total2_paths_f.
      + apply idpath.
      + cbn. do 2 rewrite pathsinv0inv0.
        apply idpath.
  Defined.

  Let σ : SigmaMonoid θ := ghhs_to_sigma_monoid θ initial_alg_to_ghss.
  Let μ : V ⟦ pr1 σ ⊗_{ Mon_V} pr1 σ, pr1 σ ⟧ := pr11 (pr212 σ).

  Theorem SigmaMonoidFromInitialAlgebra_is_initial : isInitial _ σ.
  Proof.
    intro asigma.
    induction asigma as [av [[aτ [[aμ aη] Hμη]] Hτ]].
    red in Hτ. cbn in Hτ.
    set (It_inst := Iteration_I_H av aη aτ).
    set (h := pr11 It_inst).
    use tpair.
    - exists h.
      use tpair.
      2: { exact tt. }
      assert (aux := pr21 It_inst).
      hnf in aux.
      split.
      + exact (pr1 aux).
      + red. split.
        2: { red. exact (pr2 aux). }
        red.
        change (h ⊗^{ Mon_V} h · aμ = μ · h).
        destruct aux as [auxτ auxη].
        fold h in auxτ, auxη.
        (** both sides are identical as unique morphism from the Mendler iteration scheme *)
        set (Mendler_inst := SpecialGenMendlerIterationWithActegoryAndStrength Mon_PtdV IV CV Act
                           (t,,η) CP H HH I_{Mon_V} av θ aτ (ru^{Mon_V}_{t} · h)
                           (initial_annihilates t) (left_whiskering_omega_cocont t) δ).
        intermediate_path (pr11 Mendler_inst).
        * apply path_to_ctr.
          red; split.
          -- change (t ⊗^{Mon_V}_{l} η · (h ⊗^{ Mon_V} h · aμ) = ru^{ Mon_V }_{ t} · h).
             etrans.
             2: { apply monoidal_rightunitornat. }
             etrans.
             2: { apply maponpaths.
                  apply (pr12 Hμη). }
             repeat rewrite assoc.
             apply cancel_postcomposition.
             rewrite bifunctor_equalwhiskers.
             unfold functoronmorphisms2.
             rewrite assoc.
             etrans.
             { apply cancel_postcomposition.
               apply pathsinv0, (functor_comp (leftwhiskering_functor Mon_V t)). }
             rewrite auxη.
             apply pathsinv0, bifunctor_equalwhiskers.
          -- change (t ⊗^{Mon_V}_{l} τ · (h ⊗^{ Mon_V} h · aμ) = θ (t,, η) t · # H (h ⊗^{ Mon_V} h · aμ) · aτ).
             etrans.
             2: { apply cancel_postcomposition.
                  rewrite functor_comp.
                  rewrite assoc.
                  apply cancel_postcomposition.
                  transparent assert (h_ptd : (PtdV⟦(t,,η),(av,,aη)⟧)).
                  { exists h.
                    exact auxη.
                  }
                  apply (lineator_is_nattrans_full Mon_PtdV Act Act H
                           (lineator_linnatleft _ _ _ _ θ) (lineator_linnatright _ _ _ _ θ)_ _ _ _ h_ptd h). }
             etrans.
             2: { repeat rewrite assoc'.
                  apply maponpaths.
                  rewrite assoc.
                  apply pathsinv0, Hτ. }
             repeat rewrite assoc.
             apply cancel_postcomposition.
             change (t ⊗^{Mon_V}_{l} τ · h ⊗^{Mon_V} h = h ⊗^{Mon_V} #H h · av ⊗^{Mon_V}_{l} aτ).
             etrans.
             2: { unfold functoronmorphisms1.
                  rewrite assoc'.
                  apply maponpaths.
                  apply (functor_comp (leftwhiskering_functor Mon_V av)). }
             rewrite <- auxτ.
             etrans.
             { rewrite bifunctor_equalwhiskers.
               unfold functoronmorphisms2.
               rewrite assoc.
               apply cancel_postcomposition.
               apply pathsinv0, (functor_comp (leftwhiskering_functor Mon_V t)). }
             apply pathsinv0, bifunctor_equalwhiskers.
        * apply pathsinv0, path_to_ctr.
          red; split.
          -- change (t ⊗^{Mon_V}_{l} η · (μ · h) = ru^{ Mon_V }_{ t} · h).
             rewrite assoc.
             etrans.
             { apply cancel_postcomposition.
               apply (monoid_to_unit_right_law Mon_V (pr212 σ)). }
             apply idpath.
          -- change (t ⊗^{Mon_V}_{l} τ · (μ · h) = θ (t,, η) t · # H (μ · h) · aτ).
             rewrite assoc.
             etrans.
             { apply cancel_postcomposition.
               apply pathsinv0, (pr22 σ). }
             repeat rewrite assoc'.
             apply maponpaths.
             etrans.
             2: { apply cancel_postcomposition.
                  apply pathsinv0, functor_comp. }
             rewrite assoc'.
             apply maponpaths.
             exact auxτ.
    - hnf.
      intros [ah Hyp].
      use total2_paths_f.
      { apply (path_to_ctr _ _ It_inst).
        cbn in Hyp.
        split.
        + exact (pr11 Hyp).
        + exact (pr221 Hyp).
      }
      show_id_type.
      assert (aux: isaprop TYPE).
      { apply isapropdirprod.
        + apply isapropdirprod.
          * apply V.
          * apply isaprop_is_monoid_mor.
        + apply isapropunit.
      }
      apply aux.
  Qed.

End InitialAlgebraToGHSS.

End FixTheContext.
