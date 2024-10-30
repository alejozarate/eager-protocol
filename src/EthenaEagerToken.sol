// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {IEACAggregatorProxy} from "src/interfaces/IEACAggregatorProxy.sol";
import {ILRTVault} from "src/interfaces/ILRTVault.sol";
import {IERC20Extended} from "src/interfaces/IERC20Extended.sol";

import {LRTVault} from "src/LRTVault.sol";

contract EthenaEagerToken is ERC4626 {
    IERC20 public immutable underlying;
    IERC20Extended public immutable lrtToken;
    ERC4626 public immutable yieldOracle;
    IEACAggregatorProxy public immutable pegOracle;
    int256 immutable expectedPeg;
    int256 immutable slashThreshold;

    error InvalidSlashCondition();
    error LRTVaultSlashed();

    ILRTVault public immutable lrtVault;
    bool public SLASHED = false;

    uint256 private _lastUnderlyingYieldQuote;

    modifier updateYieldQuote() {
        _;
        _updateQuotes();
    }

    modifier checkSlash() {
        _slash();
        if (SLASHED) revert LRTVaultSlashed();
        _;
    }

    constructor(
        address _underlying,
        string memory _name,
        string memory _symbol,
        address _yieldOracle,
        address _pegOracle,
        address _lrtToken
    ) ERC4626(IERC20(_underlying)) ERC20(_name, _symbol) {
        underlying = IERC20(_underlying);
        lrtToken = IERC20Extended(_lrtToken);
        yieldOracle = ERC4626(_yieldOracle);

        lrtVault = ILRTVault(
            new LRTVault{salt: keccak256(abi.encodePacked(msg.sender, block.timestamp))}(
                _lrtToken,
                string(abi.encodePacked("Eager Insurance ", lrtToken.name())),
                string(abi.encodePacked("ei", lrtToken.symbol()))
            )
        );

        pegOracle = IEACAggregatorProxy(_pegOracle);
        uint8 pegDecimals = pegOracle.decimals();
        int256 pegValue = 10;
        expectedPeg = pegValue ** pegDecimals;
        slashThreshold = pegValue ** (pegDecimals - 2);
    }

    function redeem(uint256 shares, address receiver, address owner)
        public
        override(ERC4626)
        updateYieldQuote
        returns (uint256)
    {
        _skim();
        return super.redeem(shares, receiver, owner);
    }

    function withdraw(uint256 assets, address receiver, address owner)
        public
        override(ERC4626)
        updateYieldQuote
        returns (uint256)
    {
        _skim();
        return super.withdraw(assets, receiver, owner);
    }

    function mint(uint256 shares, address receiver)
        public
        override(ERC4626)
        checkSlash
        updateYieldQuote
        returns (uint256)
    {
        _skim();
        return super.mint(shares, receiver);
    }

    function deposit(uint256 assets, address receiver)
        public
        override(ERC4626)
        checkSlash
        updateYieldQuote
        returns (uint256)
    {
        _skim();
        return super.deposit(assets, receiver);
    }

    function slash() external {
        if (SLASHED) revert LRTVaultSlashed();
        _slash();
    }

    function _slash() internal {
        if (_checkSlashCondition()) {
            SLASHED = true;
            lrtVault.slashVault();
        }
    }

    function _skim() internal {
        // Stop distributing yield when slash happened
        if (SLASHED) return;

        uint256 currentYield = _quoteYield();
        uint256 yieldToDistribute = currentYield - _lastUnderlyingYieldQuote;
        uint256 assetsToDistribute = yieldOracle.convertToShares(yieldToDistribute);

        uint256 lrtHoldersAmount = assetsToDistribute * 2_000 / 10_000;
        // TODO: Swap for lrtToken
        underlying.transfer(address(lrtVault), lrtHoldersAmount);
        _updateQuotes();
    }

    function _updateQuotes() internal {
        _lastUnderlyingYieldQuote = _quoteYield();
    }

    function _checkSlashCondition() internal view returns (bool) {
        int256 _lastOracleAnswer = pegOracle.latestAnswer();
        int256 diff =
            _lastOracleAnswer > expectedPeg ? _lastOracleAnswer - expectedPeg : expectedPeg - _lastOracleAnswer;
        if (diff > slashThreshold) return true;

        return false;
    }

    function _quoteYield() internal view returns (uint256) {
        return yieldOracle.convertToAssets(totalAssets());
    }

    function _quoteAssetAmount(uint256 _assetAmount) internal view returns (uint256) {
        return yieldOracle.convertToShares(_assetAmount);
    }
}
