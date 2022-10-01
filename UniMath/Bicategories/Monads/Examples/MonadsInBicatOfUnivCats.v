(***********************************************************************

 Monads in the bicategory of univalent categories

 In this file, we relate the concept of monad internal to a bicategory
 to the concept of monad given in category theory

 Contents
 1. Monads internal to `bicat_of_univ_cats` to monads
 2. The inverse
 3. The equivalence

 ***********************************************************************)
Require Import UniMath.Foundations.All.
Require Import UniMath.MoreFoundations.All.
Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Isos.
Require Import UniMath.CategoryTheory.Core.Functors.
Require Import UniMath.CategoryTheory.Core.NaturalTransformations.
Require Import UniMath.CategoryTheory.Core.Univalence.
Require Import UniMath.CategoryTheory.Monads.Monads.
Require Import UniMath.CategoryTheory.DisplayedCats.Core.
Require Import UniMath.Bicategories.Core.Bicat.
Import Bicat.Notations.
Require Import UniMath.Bicategories.Core.Examples.BicatOfUnivCats.
Require Import UniMath.Bicategories.DisplayedBicats.DispBicat.
Import DispBicat.Notations.
Require Import UniMath.Bicategories.DisplayedBicats.Examples.MonadsLax.

Local Open Scope cat.

(**
 1. Monads internal to `bicat_of_univ_cats` to monads
 *)
Definition mnd_bicat_of_univ_cats_to_Monad
           (m : mnd bicat_of_univ_cats)
  : Monad (pr1 (ob_of_mnd m)).
Proof.
  simple refine (((_ ,, _) ,, _) ,, _).
  - exact (endo_of_mnd m).
  - exact (mult_of_mnd m).
  - exact (unit_of_mnd m).
  - repeat split.
    + abstract
        (intro x ; cbn ;
         pose (nat_trans_eq_pointwise (mnd_unit_right m) x) as p ;
         cbn in p ;
         rewrite id_left in p ;
         exact p).
    + abstract
        (intro x ; cbn ;
         pose (nat_trans_eq_pointwise (mnd_unit_left m) x) as p ;
         cbn in p ;
         rewrite id_left in p ;
         exact p).
    + abstract
        (intro x ; cbn ;
         pose (nat_trans_eq_pointwise (mnd_mult_assoc m) x) as p ;
         cbn in p ;
         rewrite id_left in p ;
         exact (!p)).
Defined.

(**
 2. The inverse
 *)
Definition Monad_to_mnd_bicat_of_univ_cats
           {C : univalent_category}
           (m : Monad C)
  : mnd bicat_of_univ_cats.
Proof.
  use make_mnd.
  - use make_mnd_data.
    + exact C.
    + cbn.
      exact m.
    + exact (η m).
    + exact (μ m).
  - repeat split.
    + abstract
        (use nat_trans_eq ; [ apply homset_property | ] ;
         intro x ;
         cbn ;
         rewrite id_left ;
         apply m).
    + abstract
        (use nat_trans_eq ; [ apply homset_property | ] ;
         intro x ;
         cbn ;
         rewrite id_left ;
         apply m).
    + abstract
        (use nat_trans_eq ; [ apply homset_property | ] ;
         intro x ;
         cbn ;
         rewrite id_left ;
         refine (!_) ;
         apply m).
Defined.

(**
 3. The equivalence
 *)
Definition mnd_bicat_of_univ_cats_weq_Monad_inv₁
           (m : mnd bicat_of_univ_cats)
  : Monad_to_mnd_bicat_of_univ_cats (mnd_bicat_of_univ_cats_to_Monad m) = m.
Proof.
  use total2_paths_f.
  - apply idpath.
  - cbn.
    use subtypePath.
    {
      intro.
      apply isaprop_is_mnd.
    }
    apply idpath.
Qed.

Definition mnd_bicat_of_univ_cats_weq_Monad_inv₂
           {C : univalent_category}
           (m : Monad C)
  : mnd_bicat_of_univ_cats_to_Monad (Monad_to_mnd_bicat_of_univ_cats m) = m.
Proof.
  use subtypePath.
  {
    intro.
    apply isaprop_Monad_laws.
  }
  apply idpath.
Qed.

Definition mnd_bicat_of_univ_cats_weq_Monad
  : mnd bicat_of_univ_cats ≃ ∑ (C : univalent_category), Monad C.
Proof.
  use make_weq.
  - exact (λ m, ob_of_mnd m ,, mnd_bicat_of_univ_cats_to_Monad m).
  - use gradth.
    + exact (λ m, Monad_to_mnd_bicat_of_univ_cats (pr2 m)).
    + exact mnd_bicat_of_univ_cats_weq_Monad_inv₁.
    + abstract
        (intro m ;
         refine (maponpaths (λ z, pr1 m ,, z) _) ;
         exact (mnd_bicat_of_univ_cats_weq_Monad_inv₂ (pr2 m))).
Defined.