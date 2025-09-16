;; fractional_real_estate.clar
;; A simplified Fractional Real Estate contract in Clarity
;; Features:
;; - Property NFT registry
;; - Fractional share bookkeeping per property (custom FT-like behavior)
;; - Transfer of shares between principals
;; - Deposit revenue (STX) into contract
;; - Distribute revenue proportionally to shareholders
;; - Basic admin (initialize) and access control

(define-non-fungible-token property-nft uint)

;; Admin must call `initialize` once after deployment to claim adminship
(define-data-var admin principal 'SP000000000000000000002Q6VF78)
(define-data-var initialized bool false)

;; Error constants
(define-constant ERR_NOT_ADMIN (err u100))
(define-constant ERR_ALREADY_INIT (err u101))
(define-constant ERR_INVALID_PROP (err u102))
(define-constant ERR_NOT_MANAGER (err u103))
(define-constant ERR_INSUFFICIENT_BALANCE (err u104))
(define-constant ERR_NO_SHARES (err u105))
(define-constant ERR_INSUFFICIENT_STX (err u106))
(define-constant ERR_ALREADY_REGISTERED (err u107))

;; Map definitions
(define-map property-meta
  {property-id: uint}
  {doc-hash: (buff 32), valuation: uint, manager: principal})

(define-map property-total-shares
  {property-id: uint}
  {total: uint})

(define-map property-shareholder-count
  {property-id: uint}
  {count: uint})

(define-map property-shareholder-at
  {property-id: uint, index: uint}
  {holder: principal})

(define-map property-share-balance
  {property-id: uint, owner: principal}
  {balance: uint})

;; Helper functions
(define-private (is-admin (p principal))
  (is-eq p (var-get admin)))

(define-private (get-total-shares (pid uint))
  (match (map-get? property-total-shares {property-id: pid})
         shares (get total shares)
         u0))

(define-private (get-balance (pid uint) (owner principal))
  (match (map-get? property-share-balance {property-id: pid, owner: owner})
         shares (get balance shares)
         u0))

(define-private (add-holder-if-new (pid uint) (owner principal))
  (let ((bal (get-balance pid owner)))
    (if (is-eq bal u0)
        (let ((cnt-entry (map-get? property-shareholder-count {property-id: pid})))
          (let ((idx (match cnt-entry
                           cnt (get count cnt)
                           u0)))
            (map-set property-shareholder-at 
              {property-id: pid, index: idx} 
              {holder: owner})
            (map-set property-shareholder-count 
              {property-id: pid} 
              {count: (+ idx u1)})
            true))
        false)))

(define-private (remove-holder-if-zero (pid uint) (owner principal))
  true)

;; Public functions
(define-public (initialize)
  (begin
    (asserts! (is-eq (var-get initialized) false) ERR_ALREADY_INIT)
    (var-set admin tx-sender)
    (var-set initialized true)
    (ok true)))

(define-private (check-property-params (pid uint) (doc-hash (buff 32)) (valuation uint) (mgr principal))
  (begin
    (asserts! (is-admin tx-sender) ERR_NOT_ADMIN)
    (asserts! (> valuation u0) ERR_INVALID_PROP)
    (asserts! (is-none (nft-get-owner? property-nft pid)) ERR_ALREADY_REGISTERED)
    (ok {
      property-id: pid,
      doc-hash: doc-hash,
      valuation: valuation,
      manager: mgr
    })))

(define-public (register-property (pid uint) (doc-hash (buff 32)) (valuation uint) (mgr principal))
  (let ((params (try! (check-property-params pid doc-hash valuation mgr))))
    (begin
      (try! (nft-mint? property-nft pid tx-sender))
      (map-set property-meta 
        {property-id: (get property-id params)}
        {doc-hash: (get doc-hash params), 
         valuation: (get valuation params), 
         manager: (get manager params)})
      (map-set property-total-shares 
        {property-id: pid}
        {total: u0})
      (map-set property-shareholder-count 
        {property-id: pid}
        {count: u0})
      (ok true))))
