;; VaultNest Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-authorized (err u100))
(define-constant err-no-vault (err u101))
(define-constant err-timelock-active (err u102))

;; Data structures
(define-map vaults
  { owner: principal }
  {
    balance: uint,
    timelock: uint,
    authorized-users: (list 10 principal)
  }
)

;; Create new vault
(define-public (create-vault)
  (begin
    (map-set vaults
      { owner: tx-sender }
      {
        balance: u0,
        timelock: u0,
        authorized-users: (list tx-sender)
      }
    )
    (ok true)
  )
)

;; Deposit assets
(define-public (deposit (amount uint))
  (let (
    (vault (unwrap! (get-vault tx-sender) err-no-vault))
    (new-balance (+ (get balance vault) amount))
  )
    (map-set vaults
      { owner: tx-sender }
      (merge vault { balance: new-balance })
    )
    (ok true)
  )
)

;; Withdraw assets
(define-public (withdraw (amount uint))
  (let (
    (vault (unwrap! (get-vault tx-sender) err-no-vault))
  )
    (asserts! (is-authorized tx-sender vault) err-not-authorized)
    (asserts! (>= (get balance vault) amount) err-insufficient-funds)
    (asserts! (is-timelock-expired vault) err-timelock-active)
    
    (map-set vaults
      { owner: tx-sender }
      (merge vault { balance: (- (get balance vault) amount) })
    )
    (ok true)
  )
)

;; Helper functions
(define-private (is-authorized (user principal) (vault {balance: uint, timelock: uint, authorized-users: (list 10 principal)}))
  (is-some (index-of (get authorized-users vault) user))
)

(define-private (is-timelock-expired (vault {balance: uint, timelock: uint, authorized-users: (list 10 principal)}))
  (< (get timelock vault) block-height)
)

;; Getter functions
(define-read-only (get-vault (owner principal))
  (map-get? vaults { owner: owner })
)
