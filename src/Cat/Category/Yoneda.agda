{-# OPTIONS --allow-unsolved-metas --cubical #-}

module Cat.Category.Yoneda where

open import Agda.Primitive
open import Data.Product
open import Cubical
open import Cubical.NType.Properties

open import Cat.Category
open import Cat.Category.Functor
open import Cat.Equality

open import Cat.Categories.Fun
open import Cat.Categories.Sets hiding (presheaf)

-- There is no (small) category of categories. So we won't use _⇑_ from
-- `HasExponential`
--
--     open HasExponentials (Cat.hasExponentials ℓ unprovable) using (_⇑_)
--
-- In stead we'll use an ad-hoc definition -- which is definitionally equivalent
-- to that other one - even without mentioning the category of categories.
_⇑_ : {ℓ : Level} → Category ℓ ℓ → Category ℓ ℓ → Category ℓ ℓ
_⇑_ = Fun.Fun

module _ {ℓ : Level} {ℂ : Category ℓ ℓ} where
  private
    𝓢 = Sets ℓ
    open Fun (opposite ℂ) 𝓢
    presheaf = Cat.Categories.Sets.presheaf ℂ
    module ℂ = Category ℂ

    module _ {A B : ℂ.Object} (f : ℂ [ A , B ]) where
      fmap : Transformation (presheaf A) (presheaf B)
      fmap C x = ℂ [ f ∘ x ]

      fmapNatural : Natural (presheaf A) (presheaf B) fmap
      fmapNatural g = funExt λ _ → ℂ.isAssociative

      fmapNT : NaturalTransformation (presheaf A) (presheaf B)
      fmapNT = fmap , fmapNatural

    rawYoneda : RawFunctor ℂ Fun
    RawFunctor.omap rawYoneda = presheaf
    RawFunctor.fmap rawYoneda = fmapNT

    open RawFunctor rawYoneda hiding (fmap)

    isIdentity : IsIdentity
    isIdentity {c} = lemSig (naturalIsProp {F = presheaf c} {presheaf c}) _ _ eq
      where
      eq : (λ C x → ℂ [ ℂ.𝟙 ∘ x ]) ≡ identityTrans (presheaf c)
      eq = funExt λ A → funExt λ B → proj₂ ℂ.isIdentity

    isDistributive : IsDistributive
    isDistributive {A} {B} {C} {f = f} {g}
      = lemSig (propIsNatural (presheaf A) (presheaf C)) _ _ eq
      where
      T[_∘_]' = T[_∘_] {F = presheaf A} {presheaf B} {presheaf C}
      eqq : (X : ℂ.Object) → (x : ℂ [ X , A ])
        → fmap (ℂ [ g ∘ f ]) X x ≡ T[ fmap g ∘ fmap f ]' X x
      eqq X x = begin
        fmap (ℂ [ g ∘ f ]) X x ≡⟨⟩
        ℂ [ ℂ [ g ∘ f ] ∘ x ] ≡⟨ sym ℂ.isAssociative ⟩
        ℂ [ g ∘ ℂ [ f ∘ x ] ] ≡⟨⟩
        ℂ [ g ∘ fmap f X x ]  ≡⟨⟩
        T[ fmap g ∘ fmap f ]' X x ∎
      eq : fmap (ℂ [ g ∘ f ]) ≡ T[ fmap g ∘ fmap f ]'
      eq = begin
        fmap (ℂ [ g ∘ f ])    ≡⟨ funExt (λ X → funExt λ α → eqq X α) ⟩
        T[ fmap g ∘ fmap f ]' ∎

    instance
      isFunctor : IsFunctor ℂ Fun rawYoneda
      IsFunctor.isIdentity     isFunctor = isIdentity
      IsFunctor.isDistributive isFunctor = isDistributive

  yoneda : Functor ℂ Fun
  Functor.raw       yoneda = rawYoneda
  Functor.isFunctor yoneda = isFunctor
