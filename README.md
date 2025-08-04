# PrivBrowse

A decentralized, privacy-focused Web3 browser ecosystem that empowers users to own their data, monetize their attention, and interact directly with advertisers — all on-chain.

---

## Overview

PrivBrowse comprises ten core Clarity smart contracts working together to create a permissionless, fair, and transparent browsing experience where **users, creators, and advertisers** coexist without intermediaries:

1. **User Registry Contract** – Manages on-chain user identities and opt-in status.
2. **Ad Marketplace Contract** – Facilitates decentralized ad bidding, serving, and tracking.
3. **Reward Distributor Contract** – Automates token distribution for user participation.
4. **Data Vault Contract** – Provides on-chain access control for user data references.
5. **Creator Support Contract** – Enables direct tipping and subscription payments.
6. **Reputation System Contract** – Assigns trust scores to participants in the ecosystem.
7. **Ad Token Contract** – Fungible token used across all reward and ad mechanisms.
8. **Governance DAO Contract** – Decentralized protocol governance and upgrades.
9. **KYC Verification Contract** – Links verified identities to advertisers or users.
10. **Escrow Contract** – Ensures secure ad campaign payments and delivery confirmation.

---

## Features

- **Privacy-first browsing** with full user control  
- **Ad revenue sharing** through opt-in advertising  
- **Decentralized ad platform** without intermediaries  
- **Encrypted data vaults** for off-chain browsing data  
- **Token incentives** for time, attention, and participation  
- **Support creators** via on-chain micropayments  
- **Reputation-based scoring** for Sybil resistance  
- **Governance via DAO** for future upgrades  
- **Optional KYC/attestations** for advertisers  
- **Trustless escrow** for ad campaign funding  

---

## Smart Contracts

### User Registry Contract
- Register and manage user identities
- Opt-in and opt-out flags for ad targeting
- Link to encrypted data vault entries

### Ad Marketplace Contract
- Ad campaign creation and bidding
- Targeting by consented preferences
- Event logs for impressions and clicks

### Reward Distributor Contract
- Calculates and distributes AdTokens to users
- Rewards based on verified interactions
- Batch payout mechanism

### Data Vault Contract
- Stores encrypted URI references to browsing data
- User-controlled permission tokens
- Access logs for transparency

### Creator Support Contract
- On-chain tips and recurring subscriptions
- Route funds directly to content creators
- Event tracking for user engagement

### Reputation System Contract
- Trust scoring based on behavior
- Limits spam and rewards quality interactions
- Role-specific scoring (e.g. advertiser, user)

### Ad Token Contract
- Native fungible token for rewards and ad payments
- Integrated with all other contracts
- Minting, burning, and transfer logic

### Governance DAO Contract
- Voting on fee rates, token emissions, and upgrades
- Proposal creation, voting power via staked AdTokens
- On-chain execution of passed proposals

### KYC Verification Contract
- Links wallet to off-chain verified identity or attestation
- Optional use for advertisers or high-trust roles
- Non-invasive; uses zk or off-chain proofs where possible

### Escrow Contract
- Locks advertiser funds prior to campaign launch
- Only releases after ad performance verified
- Refund logic for underperformance

---

## Installation

1. Install [Clarinet CLI](https://docs.hiro.so/clarinet/getting-started)
2. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/privbrowse.git
   ```
3. Run tests:
    ```bash
    npm test
    ```
4. Deploy contracts:
    ```bash
    clarinet deploy
    ```

---

## Usage

Each contract can function independently, but together they power a robust, decentralized browsing and monetization experience. Interact with contracts through the browser interface or CLI using the provided APIs.

Refer to each .clar file and tests/ folder for specific usage, function definitions, and example calls.

---

## License

MIT License