{-# OPTIONS --allow-unsolved-metas #-}
module Cat.Categories.Fun where

open import Agda.Primitive
open import Cubical
open import Function
open import Data.Product

open import Cat.Category
open import Cat.Category.Functor

module _ {ℓc ℓc' ℓd ℓd' : Level} {ℂ : Category ℓc ℓc'} {𝔻 : Category ℓd ℓd'} where
  open Category hiding ( _∘_ ; Arrow )
  open Functor

  module _ (F G : Functor ℂ 𝔻) where
    -- What do you call a non-natural tranformation?
    Transformation : Set (ℓc ⊔ ℓd')
    Transformation = (C : Object ℂ) → 𝔻 [ F .func* C , G .func* C ]

    Natural : Transformation → Set (ℓc ⊔ (ℓc' ⊔ ℓd'))
    Natural θ
      = {A B : Object ℂ}
      → (f : ℂ [ A , B ])
      → 𝔻 [ θ B ∘ F .func→ f ] ≡ 𝔻 [ G .func→ f ∘ θ A ]

    NaturalTransformation : Set (ℓc ⊔ ℓc' ⊔ ℓd')
    NaturalTransformation = Σ Transformation Natural

    -- NaturalTranformation : Set (ℓc ⊔ (ℓc' ⊔ ℓd'))
    -- NaturalTranformation = ∀ (θ : Transformation) {A B : ℂ .Object} → (f : ℂ .Arrow A B) → 𝔻 ._⊕_ (θ B) (F .func→ f) ≡ 𝔻 ._⊕_ (G .func→ f) (θ A)

  module _ {F G : Functor ℂ 𝔻} where
    NaturalTransformation≡ : {α β : NaturalTransformation F G}
      → (eq₁ : α .proj₁ ≡ β .proj₁)
      → (eq₂ : PathP
          (λ i → {A B : Object ℂ} (f : ℂ [ A , B ])
            → 𝔻 [ eq₁ i B ∘ F .func→ f ]
            ≡ 𝔻 [ G .func→ f ∘ eq₁ i A ])
        (α .proj₂) (β .proj₂))
      → α ≡ β
    NaturalTransformation≡ eq₁ eq₂ i = eq₁ i , eq₂ i

  identityTrans : (F : Functor ℂ 𝔻) → Transformation F F
  identityTrans F C = 𝟙 𝔻

  identityNatural : (F : Functor ℂ 𝔻) → Natural F F (identityTrans F)
  identityNatural F {A = A} {B = B} f = begin
    𝔻 [ identityTrans F B ∘ F→ f ]  ≡⟨⟩
    𝔻 [ 𝟙 𝔻 ∘  F→ f ]              ≡⟨ proj₂ 𝔻.ident ⟩
    F→ f                            ≡⟨ sym (proj₁ 𝔻.ident) ⟩
    𝔻 [ F→ f ∘ 𝟙 𝔻 ]               ≡⟨⟩
    𝔻 [ F→ f ∘ identityTrans F A ]  ∎
    where
      F→ = F .func→
      module 𝔻 = IsCategory (isCategory 𝔻)

  identityNat : (F : Functor ℂ 𝔻) → NaturalTransformation F F
  identityNat F = identityTrans F , identityNatural F

  module _ {F G H : Functor ℂ 𝔻} where
    private
      _∘nt_ : Transformation G H → Transformation F G → Transformation F H
      (θ ∘nt η) C = 𝔻 [ θ C ∘ η C ]

    NatComp _:⊕:_ : NaturalTransformation G H → NaturalTransformation F G → NaturalTransformation F H
    proj₁ ((θ , _) :⊕: (η , _)) = θ ∘nt η
    proj₂ ((θ , θNat) :⊕: (η , ηNat)) {A} {B} f = begin
      𝔻 [ (θ ∘nt η) B ∘ F .func→ f ]     ≡⟨⟩
      𝔻 [ 𝔻 [ θ B ∘ η B ] ∘ F .func→ f ] ≡⟨ sym assoc ⟩
      𝔻 [ θ B ∘ 𝔻 [ η B ∘ F .func→ f ] ] ≡⟨ cong (λ φ → 𝔻 [ θ B ∘ φ ]) (ηNat f) ⟩
      𝔻 [ θ B ∘ 𝔻 [ G .func→ f ∘ η A ] ] ≡⟨ assoc ⟩
      𝔻 [ 𝔻 [ θ B ∘ G .func→ f ] ∘ η A ] ≡⟨ cong (λ φ → 𝔻 [ φ ∘ η A ]) (θNat f) ⟩
      𝔻 [ 𝔻 [ H .func→ f ∘ θ A ] ∘ η A ] ≡⟨ sym assoc ⟩
      𝔻 [ H .func→ f ∘ 𝔻 [ θ A ∘ η A ] ] ≡⟨⟩
      𝔻 [ H .func→ f ∘ (θ ∘nt η) A ]     ∎
      where
        open IsCategory (isCategory 𝔻)

    NatComp = _:⊕:_

  private
    module _ {A B C D : Functor ℂ 𝔻} {f : NaturalTransformation A B}
      {g : NaturalTransformation B C} {h : NaturalTransformation C D} where
      _g⊕f_ = _:⊕:_ {A} {B} {C}
      _h⊕g_ = _:⊕:_ {B} {C} {D}
      :assoc: : (_:⊕:_ {A} {C} {D} h (_:⊕:_ {A} {B} {C} g f)) ≡ (_:⊕:_ {A} {B} {D} (_:⊕:_ {B} {C} {D} h g) f)
      :assoc: = {!!}
    module _ {A B : Functor ℂ 𝔻} {f : NaturalTransformation A B} where
      ident-r : (_:⊕:_ {A} {A} {B} f (identityNat A)) ≡ f
      ident-r = {!!}
      ident-l : (_:⊕:_ {A} {B} {B} (identityNat B) f) ≡ f
      ident-l = {!!}
      :ident:
        : (_:⊕:_ {A} {A} {B} f (identityNat A)) ≡ f
        × (_:⊕:_ {A} {B} {B} (identityNat B) f) ≡ f
      :ident: = ident-r , ident-l

  -- Functor categories. Objects are functors, arrows are natural transformations.
  RawFun : RawCategory (ℓc ⊔ ℓc' ⊔ ℓd ⊔ ℓd') (ℓc ⊔ ℓc' ⊔ ℓd')
  RawFun = record
    { Object = Functor ℂ 𝔻
    ; Arrow = NaturalTransformation
    ; 𝟙 = λ {F} → identityNat F
    ; _∘_ = λ {F G H} → _:⊕:_ {F} {G} {H}
    }

  instance
    :isCategory: : IsCategory RawFun
    :isCategory: = record
      { assoc = λ {A B C D} → :assoc: {A} {B} {C} {D}
      ; ident = λ {A B} → :ident: {A} {B}
      ; arrowIsSet = {!!}
      ; univalent = {!!}
      }

  Fun : Category (ℓc ⊔ ℓc' ⊔ ℓd ⊔ ℓd') (ℓc ⊔ ℓc' ⊔ ℓd')
  raw Fun = RawFun

module _ {ℓ ℓ' : Level} (ℂ : Category ℓ ℓ') where
  open import Cat.Categories.Sets

  -- Restrict the functors to Presheafs.
  RawPresh : RawCategory (ℓ ⊔ lsuc ℓ') (ℓ ⊔ ℓ')
  RawPresh = record
    { Object = Presheaf ℂ
    ; Arrow = NaturalTransformation
    ; 𝟙 = λ {F} → identityNat F
    ; _∘_ = λ {F G H} → NatComp {F = F} {G = G} {H = H}
    }
