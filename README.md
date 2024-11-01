## View functions to integrate:

    ### EthenaEagerToken.sol
        ERC4626:
            - Quote convert underlying (usde) to shares (eagerToken) -> /** @dev See {IERC4626-previewDeposit}. */
            - Quote convert shares (eagerToken) to underlying (usde) -> /** @dev See {IERC4626-previewRedeem}. */
    ### LRTVault.sol
        ERC4626:
            - Quote convert underlying (LRT) to shares (LRT receipt) -> /** @dev See {IERC4626-previewDeposit}. */
            - Quote convert shares (LRT receipt) to underlying (LRT) -> /** @dev See {IERC4626-previewRedeem}. */

Contracts call to integrate:

- function deposit(uint256 assets, address receiver) public virtual returns (uint256)
- function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256)

### Calculate yield distribution

`yieldOracle` public function of EthenaEagerToken returns the vault for minting (eusde) to (usde), which distribute the yield to ethena holders.
The `function _skim()` of EthenaEagerToken.sol contains the logic for calculating the amount of yield the vault distributes to LRTVault depositors, calculating the amount of assets (usde) equivalent to the amount of underlying deposited in the EthenaEagerToken vault. The diff between the last calculation and the current calculation is the amount of yield to distribute, but the actual APY should be gathered from the ethena vault instead of the EthenaEagerVault.
Knowing that there is N amount of eusde deposited in the vault and the yield ethena provides to the token, one can calculate the amount of yield that will be distribute to LRTDepositors.

### SLASHED condition

Once the LRTVault is slashed, deposits are no longer available and the state variable `SLASHED` contains the slashed status. A new EthernaEagerVault with it's corresponding LRTVault should be create to emit a new insured version (this might change in the future)

### TODO

1. Still need to calculate the depeg amount to trigger LRT slash based on the diff between the expectedPeg of the EthenaEagerToken and the actual oracle value (gathered from Chainlink for the POC).
2. Still need to perform the market buy between the insured token and the LRT underlying to transfer the 20% rewards in the underlying token to the LRTVault instead of plain transferring Ethena to take advantage of the ERC4626 implementation of the LRT vault.

### Deployment Addresses Arbitrum Sepolia

EagerFactory 0xdBCC764ec05c056284d30869a27D94486Fd758F4
EthenaPrimitive usde 0x923588E24D5f4d373c9514ca04E2Fe219C874638
LRTToken 0x0fc8DD69670a17DfBFE3093DEE45332e944aB8b9
Oracle 0xc2A3e236a1920432C0FC9Fc8877D306f36614e13
Ethena Yield eusde (insured token) eusde 0xd730952a12c77ff1dF38950B274c73D3317C6fe6
eToken 0x3aa6129e7112b109b58e4ebe5e55c40fbc8daf7b
LRTVault 0xf20f033fcd9638778c56956365213aa7bc634bac
