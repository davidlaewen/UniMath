(** Category generated by a preorder *)

Require Import UniMath.Foundations.HLevels.
Require Import UniMath.Foundations.Sets.
Require Import UniMath.Foundations.Propositions.
Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Isos.
Require Import UniMath.CategoryTheory.Core.Univalence.
Local Open Scope cat.

Section po_category_def.
Context {X : UU}.

(** Precategory over a preorder *)
Definition po_precategory_ob_mor (PO : po X) : precategory_ob_mor :=
    make_precategory_ob_mor X (carrierofpo X PO).

Definition po_precategory_data (PO : po X) : precategory_data :=
  make_precategory_data (po_precategory_ob_mor PO)
                        (pr2 (pr2 PO)) (pr1 (pr2 PO)).


Lemma po_homsets_isaprop (PO : po X) (a b : (po_precategory_data PO)) :
  isaprop (po_precategory_data PO ⟦a,b⟧).
Proof.
  apply propproperty.
Defined.

Definition po_precategory_data_is_precategory (PO : po X) :
  is_precategory (po_precategory_data PO).
Proof.
  use make_is_precategory; intros; apply po_homsets_isaprop.
Defined.

Definition po_precategory (PO : po X) : precategory.
Proof.
  use make_precategory.
  - exact (po_precategory_data PO).
  - exact (po_precategory_data_is_precategory PO).
Defined.

(** Category over preorder *)
Definition po_precategory_has_homsets (PO : po X) :
  has_homsets (po_precategory_ob_mor PO).
Proof.
  intros ? ?.
  apply hlevelntosn.
  apply po_homsets_isaprop.
Defined.

Definition po_category (PO : po X) : category
  := make_category (po_precategory PO) (po_precategory_has_homsets PO).

(** If the preorder is antisymmetric and X is a set, the category is univalent *)
Context (xisaset : isaset X).

Lemma antisymm_po_category_isoiseq (PO : po X) {A B : (po_category PO)}
  (poasymm : isantisymm PO) (isoAB : z_iso A B) : A = B.
Proof.
  apply poasymm.
  apply (z_iso_mor isoAB).
  apply (inv_from_z_iso isoAB).
Defined.


Lemma antisymm_po_category_isweq (PO : po X) {A B : po_category PO}
      (poasymm : isantisymm PO) : isweq (λ p : A = B, idtoiso p).
Proof.
  use isweq_iso.
  - apply (antisymm_po_category_isoiseq PO poasymm).
  - intro eq.
    apply proofirrelevance.
    apply xisaset.
  - intro iso.
    use z_iso_eq.
    apply proofirrelevance.
    apply propproperty.
Defined.

Theorem po_category_is_univalent_iff_is_antisymm (PO : po X) :
  is_univalent (po_category PO) <-> isantisymm PO.
Proof.
  split.
  - intros isuni a b relab relba.
    apply (isotoid _ isuni).
    exists relab.
    exists relba.
    apply make_is_inverse_in_precat; apply po_homsets_isaprop.
  - intro poasymm.
    intros ? ?.
    apply (antisymm_po_category_isweq PO poasymm).
Defined.

Definition antisymm_po_univalent_category (PO : po X) (poasymm : isantisymm PO) :
  univalent_category.
  use make_univalent_category.
  - exact (po_category PO).
  - apply po_category_is_univalent_iff_is_antisymm.
    exact poasymm.
Defined.

End po_category_def.
