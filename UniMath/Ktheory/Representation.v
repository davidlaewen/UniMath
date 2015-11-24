Require Import UniMath.CategoryTheory.functor_categories.
Require Import UniMath.CategoryTheory.total2_paths.
Require Import UniMath.Foundations.Sets.
Require Import UniMath.Ktheory.Utilities.
Require Import UniMath.CategoryTheory.precategories. (* get its coercions *)
Require Import UniMath.Ktheory.Precategories.
Set Automatic Introduction.
Local Open Scope cat.

Definition isUniversal {C:Precategory} {X:C==>SET} {c:C} (x:X c:hSet)
  := ∀ (c':C), isweq (λ f : c → c', # X f x).

Lemma isaprop_isUniversal {C:Precategory} {X:C==>SET} {c:C} (x:X c:hSet) :
  isaprop (isUniversal x).
Proof.
  intros. apply impred_isaprop; intro c'. apply isapropisweq.
Defined.

Definition Representation {C:Precategory} (X:C==>SET) : UU
  := Σ (c:C) (x:X c:hSet), isUniversal x.

Definition isRepresentable {C:Precategory} (X:C==>SET) := ∥ Representation X ∥.

Lemma isaprop_Representation {C:category} (X:C==>SET) :
  isaprop (@Representation C X).
Proof.

Abort.

(* categories of functors with representations *)

Definition RepresentedFunctor (C:Precategory) : Precategory
  := @categoryWithStructure [C,SET] Representation.

Definition toRepresentation {C:Precategory} (X : RepresentedFunctor C) :
  Representation (pr1 X)
  := pr2 X.

Definition RepresentableFunctor (C:Precategory) : Precategory
  := @categoryWithStructure [C,SET] isRepresentable.

Definition toRepresentableFunctor {C:Precategory} :
  RepresentedFunctor C ==> RepresentableFunctor C :=
  functorWithStructures (λ c, hinhpr).

(* make a representation of a functor *)


Definition makeRepresentation {C:Precategory} {X:C==>SET} {c:C} (x:X c:hSet) :
  (∀ (c':C), bijective (λ f : c → c', # X f x)) -> Representation X.
Proof.
  intros bij. exists c. exists x. intros c'. apply set_bijection_to_weq.
  - exact (bij c').
  - apply setproperty.
Defined.

(* universal aspects of represented functors *)

Definition universalObject {C:Precategory} {X:C==>SET} (r:Representation X) : C
  := pr1 r.

Definition universalElement {C:Precategory} {X:C==>SET} (r:Representation X) :
  X (universalObject r) : hSet
  := pr1 (pr2 r).

Definition universalProperty {C:Precategory} {X:C==>SET} (r:Representation X) (c':C) :
  universalObject r → c' ≃ (X c' : hSet)
  := weqpair _ (pr2 (pr2 r) _).

Definition universalMap {C:Precategory} {X:C==>SET} (r:Representation X) {c':C} :
  (X c' : hSet) -> universalObject r → c'
  := invmap (universalProperty _ _).

Definition mapUniqueness {C:Precategory} (X:C==>SET) (r : Representation X) (c':C)
           (f g:universalObject r → c') :
  # X f (universalElement r) = # X g (universalElement r) -> f = g
  := invmaponpathsweq (universalProperty _ _) _ _.

Definition universalMapUniqueness {C:Precategory} {X:C==>SET} {r:Representation X}
      {c':C} (x' : X c' : hSet) (f : universalObject r → c') :
  # X f (universalElement r) = x' -> f = universalMap r x'
  := pathsweq1 (universalProperty r c') f x'.

Definition universalMapUniqueness' {C:Precategory} {X:C==>SET} {r:Representation X}
      {c':C} (x' : X c' : hSet) (f : universalObject r → c') :
  f = universalMap r x' -> # X f (universalElement r) = x'
  := pathsweq1' (universalProperty r c') f x'.

Lemma universalMapNaturality {C:Precategory} {a:C} {Y Z:C ==> SET}
      (s : Representation Y)
      (t : Representation Z)
      (q : Y ⟶ Z) (f : universalObject s → a) :
  universalMap t (q _ (# Y f (universalElement s)))
  =
  f ∘ universalMap t (q _ (universalElement s)).
Proof.
  (* This lemma says that if the source and target of a natural transformation
  q are represented by objects of C, then q is represented by composition with
  an arrow of C. *)
  set (y := universalElement s).
  apply pathsinv0, universalMapUniqueness, pathsinv0.
  set (z := universalElement t).
  intermediate_path (# Z f (q _ y)).
  { exact (apevalat y (nat_trans_ax q _ _ f)). }
  intermediate_path (# Z f (# Z (universalMap t (q _ y)) z)).
  { apply maponpaths. exact (! homotweqinvweq (universalProperty t _) _). }
  exact (! apevalat z (functor_comp Z _ _ _ (universalMap t (q _ y)) f)).
Defined.

(*  *)

Definition universalObjectFunctor (C:Precategory) : RepresentedFunctor C ==> C^op.
Proof.
  refine (makeFunctor _ _ _ _).
  - intro X. exact (universalObject (pr2 X)).
  - intros X Y p; simpl. apply universalMap. apply p. apply universalElement.
  - intros X; simpl. apply pathsinv0. apply universalMapUniqueness.
    apply identityFunction. apply (functor_id (pr1 X)).
  - intros X Y Z p q; simpl. set (p__ := p : _ ⟶ _).
    (* why did those matches appear in the goal? *)
    refine (_ @ (universalMapNaturality _ _ q
                   (universalMap _ (p__ _ (universalElement _))))).
    apply maponpaths. unfold compose; simpl. apply maponpaths.
    exact (! homotweqinvweq
                (universalProperty _ (universalObject (pr2 X)) )
                (p__ _ (universalElement (pr2 X)))).
Defined.

Definition embeddingRepresentability {C D:Precategory}
           {i:C==>D} (emb:fully_faithful i) {Y:D==>SET} (s:Representation Y) :
           (Σ c, universalObject s = i c) -> Representation (Y □ i).
Proof.
  intros ce. exists (pr1 ce).
  exists (transportf (λ d, Y d : hSet) (pr2 ce) (universalElement s)).
  intro c'. apply (twooutof3c (# i) (λ g, # Y g _)).
  - apply emb.
  - induction (pr2 ce). exact (weqproperty (universalProperty _ _)).
Defined.


(*  *)
