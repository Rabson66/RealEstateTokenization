# Real Estate Tokenization Smart Contract

A Clarity smart contract for tokenizing real estate assets on the Stacks blockchain. This contract enables property registration, fractional ownership management, and revenue distribution.

## Features

- 🏠 Property NFT registry
- 📊 Fractional share management per property
- 💱 Transfer of ownership shares between principals
- 💰 Revenue (STX) deposit and distribution
- 🔐 Administrative controls and access management

## Contract Overview

### Core Components

1. **Property NFT Registry**
   - Each property is represented as a unique NFT
   - Properties are identified by unique uint IDs
   - Includes property metadata (document hash, valuation, manager)

2. **Share Management**
   - Tracks total shares per property
   - Maintains shareholder registry
   - Manages individual share balances

3. **Access Control**
   - Admin initialization system
   - Property manager controls
   - Ownership validation

### Error Codes

```clarity
ERR_NOT_ADMIN         (err u100)  // Only admin can perform this action
ERR_ALREADY_INIT      (err u101)  // Contract already initialized
ERR_INVALID_PROP      (err u102)  // Invalid property parameters
ERR_NOT_MANAGER       (err u103)  // Only property manager can perform this action
ERR_INSUFFICIENT_BAL  (err u104)  // Insufficient share balance
ERR_NO_SHARES         (err u105)  // No shares available
ERR_INSUFFICIENT_STX  (err u106)  // Insufficient STX balance
ERR_ALREADY_REG       (err u107)  // Property already registered
```

## Usage

### Initializing the Contract

```clarity
(contract-call? .real-estate-tokenization initialize)
```

### Registering a Property

```clarity
(contract-call? .real-estate-tokenization register-property 
    u1                                  ;; property ID
    0x0123456789abcdef...              ;; document hash (32 bytes)
    u1000000                           ;; valuation in uSTX
    'SP000000000000000000002Q6VF78)    ;; manager principal
```

## Development


### Local Testing

```bash
# Run all tests
clarinet test

# Start local devnet
clarinet integrate
```

