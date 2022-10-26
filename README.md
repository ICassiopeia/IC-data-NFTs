# Motivation
In the blockchain space, a few projects have tried to tackle the topic of data governance and some of its key pain points: security, audit, monetization, etc.
So far, most projects have relied on blockchains to handle handle ownership and transctions, while datasets would sit in a different environment such as IPFS.

This comes with several weak points:
- datasets are usually static
- it is hard to implement record-level authorization
- logging in insufficient (broken datasets)
- usually not GDPR-compliant, ie. the "right to be forgotten", level of granularity, etc.

This project is Proof-of-Concept that aims to demonstrate that the Internet Computer can solve all of these issues by keeping everything in the same environment in a cost-effective way by levergaing its storage and computation abilities.

# Project structure
- Assets canister: it holds the data as well as the analytical functions

- Fractional NFT: it's simple implementation where each ERC721 spins off a ERC20 canister

- Jupyter notebook: demonstrate some interactions with the canister to load and display data

# Design decisions
- Motoko
We've decided to only use motoke to make the code more succint and demonstrate usability

- standards
We use the EXT standard for ERC721 and ERC20 for readability 

# Known limitations
For most uses cases, the fractional NFT strategy implemented here is probably not optimal and not cost effective.
Analytical function would probably be more efficiently written in Rust.
The asset canister should probably spin off a canister per datasets instead of holding data in a signle one.

## Running the project locally

If you want to test your project locally, you can use the following commands:

```bash
pip3 install notebook
pip3 install ic-py
```

```bash
# Starts the replica, running in the background
dfx start --background

# Deploys your canisters to the replica and generates your candid interface
dfx deploy
```

Once the job completes, your application will be available at `http://localhost:8000?canisterId={asset_canister_id}`.

Additionally, if you are making frontend changes, you can start a development server with

```bash
npm start
```

Which will start a server at `http://localhost:8080`, proxying API requests to the replica at port 8000.
