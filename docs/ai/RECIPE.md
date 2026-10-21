# iOS Live Shopping Reference App

## Overview

Build an iOS live shopping experience with host video, audience viewing, and commerce-oriented live interaction.

Repository: [AgoraIO-Community/referenceapp-liveshopping-ios](https://github.com/AgoraIO-Community/referenceapp-liveshopping-ios)

## Prerequisites and Setup

1. Review the app structure and user-flow documents before selecting the merchant and customer paths to implement.
2. Use the iOS project under `LiveCommerce/` and its `Podfile` to install the checked-in dependencies with CocoaPods, then configure Xcode signing.
3. Provision your own Agora project and the integrations used by the app: Firebase, Sign in with Apple, Apple Pay and Banuba where those features are enabled. Inspect the app's source to supply each service's configuration.
4. Run merchant and customer clients with test accounts and sandbox payment configuration. Start a merchant broadcast and join as a customer.

## What To Check

- Verify the customer can see the merchant stream and selected product.
- Test the product/cart/order flow with sandbox services, including cancellation and failure.
- End the broadcast and confirm both media and storefront state update.

## Integration Notes

The upstream README explicitly describes this as a reference with known bugs and no promise of fixes. It requires several external integrations; a single Agora App ID does not make it runnable. Use sandbox payment flows during validation.

Keep App Certificates, customer secrets and privileged token generation on a trusted backend for production. Use only your own test credentials while configuring historical demos; do not commit them. Preserve the sample's existing dependency versions and lifecycle until a separate migration is tested.

## Source References

- [README.md](../../README.md)
- [LiveCommerce/Podfile](../../LiveCommerce/Podfile)
- [documents/Reference-App-Structure.md](../../documents/Reference-App-Structure.md)
- [documents/User-Flow-Description.md](../../documents/User-Flow-Description.md)

## Validation Status

This recipe was checked against the repository's source and setup documents. The platform build and live service/device flow have not been run as part of this documentation change. Complete the checks above in an environment with the required SDKs, hardware and service access before treating it as a validated deployment.

## Implementation Prompt

```text
You are working in AgoraIO-Community/referenceapp-liveshopping-ios. Use docs/ai/RECIPE.md and its linked source files to adapt the iOS Live Shopping Reference App reference to this project.

Start by inspecting the actual sample directory and configuration described above. Resolve its listed missing prerequisites before claiming it is runnable. Preserve the existing architecture and compatible dependency versions. Implement the recipe's feature-specific flow, permissions and resource cleanup. Use a trusted backend for privileged credentials and tokens in production.

Run the repository-specific build or launch flow, then perform each What To Check item. Report the commands run, the observed results and anything blocked by service access, hardware or incomplete sample code. Do not claim live validation from a documentation or catalog build alone.
```
