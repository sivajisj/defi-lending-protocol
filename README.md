# Mini Aave — DeFi Lending Protocol

Production-style decentralized lending protocol inspired by Aave.
Built with Solidity, Foundry, Next.js, wagmi, Docker, and modern Web3 best practices.

---

## Overview

Mini Aave allows users to:

* Deposit ERC20 collateral,
* Borrow a stable token against collateral,
* Accrue interest over time,
* Maintain a healthy collateral ratio,
* Face liquidation if health factor drops too low.

This project demonstrates a complete DeFi lending stack:

* Smart contracts (Solidity + Foundry),
* Frontend dApp (Next.js + wagmi + viem),
* Dockerized development environment,
* Automated testing + fuzz testing.

---

## Architecture

### Smart Contracts

Core components:

* LendingPool.sol → main lending logic,
* MockCollateralToken.sol → collateral ERC20 token,
* MockStableToken.sol → borrowable stable token,
* MockPriceOracle.sol → price feed simulation.

Key features:

* Collateral deposit / withdraw,
* Borrow stable tokens,
* Interest accrual,
* Health factor calculation,
* Liquidation mechanism.

---

### Frontend dApp

Built using:

* Next.js 14+,
* wagmi + viem for wallet interaction,
* MetaMask support,
* ABI-driven contract interaction.

Functions:

* Wallet connect,
* Deposit collateral,
* Borrow stable tokens,
* Health factor display.

---

### Infrastructure

Dockerized services:

* Solidity development container,
* Next.js frontend container,
* Consistent reproducible environment.

Benefits:

* Team reproducibility,
* No host dependency conflicts,
* Production-like setup.

---

## Project Structure

```
mini-aave/
  contracts/
    src/
    test/
    script/
    foundry.toml
  frontend/
    app/
    components/
  docker/
  docker-compose.yml
  Makefile
```

---

## Prerequisites

Install:

* Docker + Docker Compose,
* Node.js 20+ (if running frontend locally),
* Foundry (optional outside Docker),
* MetaMask wallet.

---

## Setup Guide

### 1. Clone repository

```
git clone https://github.com/YOUR_USERNAME/mini-aave.git
cd mini-aave
```

---

### 2. Start Docker environment

```
make up
```

or:

```
docker compose up -d --build
```

This starts:

* contracts container,
* frontend container.

---

### 3. Compile contracts

Inside contracts container:

```
make contracts-shell
forge build
```

Run tests:

```
forge test
```

---

### 4. Deploy contracts

Example local deployment:

```
forge script script/Deploy.s.sol:DeployMiniAave \
--rpc-url http://localhost:8545 \
--private-key YOUR_PRIVATE_KEY \
--broadcast
```

Sepolia testnet deployment:

```
forge script script/Deploy.s.sol:DeployMiniAave \
--rpc-url YOUR_SEPOLIA_RPC \
--private-key YOUR_PRIVATE_KEY \
--broadcast
```

---

### 5. Setup frontend

Copy ABI files:

```
contracts/out/*/YourContract.json → frontend/abis/
```

Update addresses:

```
frontend/config/contracts.ts
```

Add:

* LendingPool address,
* Collateral token address,
* Stable token address.

---

### 6. Run frontend

Inside frontend container:

```
npm install
npm run dev
```

App typically runs at:

```
http://localhost:3000
```

---

## Usage Flow

### Step 1 — Mint Collateral

Owner mints collateral token:

```
cast send TOKEN_ADDRESS \
"mint(address,uint256)" \
USER_ADDRESS AMOUNT
```

---

### Step 2 — Approve LendingPool

```
cast send TOKEN_ADDRESS \
"approve(address,uint256)" \
POOL_ADDRESS AMOUNT
```

---

### Step 3 — Deposit Collateral

From frontend or CLI:

```
deposit(amount)
```

Collateral is locked in protocol.

---

### Step 4 — Borrow Stable Tokens

Borrow based on collateral value:

```
borrow(amount)
```

Health factor must remain safe.

---

### Step 5 — Monitor Health Factor

Formula:

```
healthFactor =
(collateral_value × threshold) / debt_value
```

If too low:

* liquidation possible.

---

## Testing

Includes:

* Unit tests,
* Fuzz tests,
* Invariant tests.

Run:

```
forge test
```

---

## Security Considerations

Implemented:

* Reentrancy protection,
* Custom errors,
* Event logging,
* Health factor checks,
* Controlled token minting.

Recommended before production:

* Smart contract audit,
* Oracle security improvements,
* Rate model refinement.

---

## Technologies Used

* Solidity + Foundry,
* Next.js + TypeScript,
* wagmi + viem,
* Docker,
* Ethereum Sepolia testnet.

---

## Future Improvements

* Real price oracle integration,
* Variable interest model,
* Multi-collateral support,
* Governance token,
* Production UI polish.

---

## Disclaimer

Educational DeFi prototype.
Not audited. Do not use with real funds.

---


