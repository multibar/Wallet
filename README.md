# Wallet

Currently, Multi Wallet encrypts secret phrase and store it on user's choice — iCloud Keychain or Local Device's Keychain. If you choose iCloud keychain, you'll be given a private key that is used to decrypt your encrypted phrase. If you choose Device Keychain, both encrypted phrase and private key will be stored locally, since they never leave the device. The iCloud keychain is shared across user's devices that are tied to one Apple ID. Device's keychain content never leaves the device itself.

Building `.xcodeproj` file
```bash
xcodegen generate
```

## Roadmap
 * [ ] Passcode reset functionality
 * [ ] Firebase authorization, 'Cloud' store option to keep encrypted phrase in firebase
 * [ ] TON Wallet full support
 * [ ] Option to add wallet address to show balance, NFT's and transactions
 * [ ] Notifications
 * [ ] Add ScanViewController to scan phrases or operations for wallets
 * [ ] Create App Clip with scanner
 
 ## Off-Roadmap
 
 * [ ] Add more coins and fiats
 * [ ] Custom AlertViewController
 * [ ] Phrases autocomplete
 * [ ] Workstation refactor to async / await
 * [ ] Investigate the possibility of using Passkeys as phrase encoder / decoder
