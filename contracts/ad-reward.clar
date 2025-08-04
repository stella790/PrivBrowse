;; Ad Reward Contract
;; Allows opt-in users to earn token rewards by interacting with ad campaigns

(define-constant ERR-NOT-ADMIN u100)
(define-constant ERR-ALREADY-OPTED-IN u101)
(define-constant ERR-NOT-OPTED-IN u102)
(define-constant ERR-CAMPAIGN-NOT-FOUND u103)
(define-constant ERR-INSUFFICIENT-BUDGET u104)
(define-constant ERR-REWARD-ALREADY-CLAIMED u105)
(define-constant ERR-NOT-CREATOR u106)
(define-constant ERR-CAMPAIGN-ALREADY-SETTLED u107)
(define-constant ERR-NOT-ENABLED u108)

(define-data-var admin principal tx-sender)
(define-data-var paused bool false)

;; Map of opted-in users
(define-map opted-in principal bool)

;; Map of reward balances
(define-map reward-balance principal uint)

;; Map of claimed campaigns by user
(define-map claimed-reward principal (map uint bool))

;; Struct for campaigns
(define-map campaigns uint
  {
    creator: principal,
    budget: uint,
    reward-per-user: uint,
    participants: uint,
    settled: bool
  }
)

;; Utility: only-admin guard
(define-private (only-admin)
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err ERR-NOT-ADMIN))
    true
  )
)

;; Utility: not-paused guard
(define-private (not-paused)
  (asserts! (not (var-get paused)) (err ERR-NOT-ENABLED))
)

;; Admin can pause or unpause the contract
(define-public (pause (status bool))
  (begin
    (only-admin)
    (var-set paused status)
    (ok status)
  )
)

;; Admin can change contract admin
(define-public (set-admin (new-admin principal))
  (begin
    (only-admin)
    (var-set admin new-admin)
    (ok new-admin)
  )
)

;; Users opt in to the reward program
(define-public (opt-in)
  (begin
    (not-paused)
    (asserts! (is-none (map-get? opted-in tx-sender)) (err ERR-ALREADY-OPTED-IN))
    (map-set opted-in tx-sender true)
    (ok true)
  )
)

;; Creator launches a new campaign
(define-public (create-campaign (campaign-id uint) (budget uint) (reward-per-user uint))
  (begin
    (not-paused)
    (asserts! (is-none (map-get? campaigns campaign-id)) (err ERR-CAMPAIGN-NOT-FOUND))
    (asserts! (> budget reward-per-user) (err ERR-INSUFFICIENT-BUDGET))
    (map-set campaigns campaign-id {
      creator: tx-sender,
      budget: budget,
      reward-per-user: reward-per-user,
      participants: u0,
      settled: false
    })
    (ok campaign-id)
  )
)

;; Users claim reward by participating in a campaign
(define-public (participate (campaign-id uint))
  (begin
    (not-paused)
    (asserts! (is-some (map-get? opted-in tx-sender)) (err ERR-NOT-OPTED-IN))

    (match (map-get? campaigns campaign-id)
      campaign
      (begin
        (asserts! (not (get settled campaign)) (err ERR-CAMPAIGN-ALREADY-SETTLED))

        (let (
          (already-claimed (default-to false
            (get campaign-id (default-to {} (map-get? claimed-reward tx-sender)))))
        )
          (asserts! (not already-claimed) (err ERR-REWARD-ALREADY-CLAIMED))

          (let (
            (current-claims (default-to {} (map-get? claimed-reward tx-sender)))
            (new-claims (merge current-claims { campaign-id: true }))
            (reward (get reward-per-user campaign))
            (updated-reward (+ (default-to u0 (map-get? reward-balance tx-sender)) reward))
            (updated-budget (- (get budget campaign) reward))
            (updated-participants (+ (get participants campaign) u1))
          )
            ;; Update user claim + reward
            (map-set claimed-reward tx-sender new-claims)
            (map-set reward-balance tx-sender updated-reward)

            ;; Update campaign
            (map-set campaigns campaign-id {
              creator: (get creator campaign),
              budget: updated-budget,
              reward-per-user: reward,
              participants: updated-participants,
              settled: false
            })

            (ok updated-reward)
          )
        )
      )
      (err ERR-CAMPAIGN-NOT-FOUND)
    )
  )
)

;; Creator can settle a campaign
(define-public (settle-campaign (campaign-id uint))
  (begin
    (match (map-get? campaigns campaign-id)
      campaign
      (begin
        (asserts! (is-eq (get creator campaign) tx-sender) (err ERR-NOT-CREATOR))
        (asserts! (not (get settled campaign)) (err ERR-CAMPAIGN-ALREADY-SETTLED))

        (map-set campaigns campaign-id {
          creator: (get creator campaign),
          budget: (get budget campaign),
          reward-per-user: (get reward-per-user campaign),
          participants: (get participants campaign),
          settled: true
        })

        (ok true)
      )
      (err ERR-CAMPAIGN-NOT-FOUND)
    )
  )
)

;; Read-only: Get campaign details
(define-read-only (get-campaign (id uint))
  (match (map-get? campaigns id)
    some-campaign (ok some-campaign)
    (err ERR-CAMPAIGN-NOT-FOUND)
  )
)

;; Read-only: Check if user is opted-in
(define-read-only (is-opted-in (user principal))
  (ok (is-some (map-get? opted-in user)))
)

;; Read-only: Get user reward balance
(define-read-only (get-reward (user principal))
  (ok (default-to u0 (map-get? reward-balance user)))
)
