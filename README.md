# Hyperclaim

**Welcome to Hyperclaim: a decentralised digital identity and credentialing solution.**

Verifiable digital identities create a powerful resource that enables users to engage broadly across investment, ownership, and governance in the Hypersurface protocol. Identities are persistent, meaning they may only need to be verified once to open an entire network of opportunities. In this sense, an identity account can be thought of as a digital ID card. Not only is it valid across opportunities but with further standardisation, it may be used across the blockchain ecosystem.

## Hyperclaim.sol

Hyperclaim is the central registry where users of the hypersurface protocol can add claims about themselves and others. These claims are then checked in credential-based interactions. Examples of such claims are that a user is an accredited investor or that a citizen of a particular jurisdiction.

## HyperclaimIdentityRegistry.sol

HyperclaimIdentityRegistry records basic fields about user identities on-chain and associates them with their blockchain accounts. 

## HyperclaimVerifiersRegistry.sol

HyperclaimVerifiersRegistry records which accounts are "verifiers" and are trusted by users to provide high-risk claims used in credential-based interactions. These may include KYC agents or regulated broker dealers. The verifiers registry is separate from the other contracts in the protocol so that it may be owned and controlled by a token curated registry. This design choice has been made (yet to be implemented) in order to further decentralise control in the Hypersurface protocol, thereby ensuring that no single group, not even Hypersurface, gets final say in terms of key decisions.  