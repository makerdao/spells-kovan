// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021 Maker Ecosystem Growth Holdings, INC.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.6.12;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import "lib/dss-interfaces/src/dss/GemJoinAbstract.sol";
import "lib/dss-interfaces/src/dss/IlkRegistryAbstract.sol";
import "lib/dss-interfaces/src/dapp/DSTokenAbstract.sol";

interface Initializable {
    function init(bytes32) external;
}

interface Hopeable {
    function hope(address) external;
}

interface Kissable {
    function kiss(address) external;
}

interface RwaLiquidationLike {
    function ilks(bytes32) external returns (string memory,address,uint48,uint48);
    function init(bytes32, uint256, string calldata, uint48) external;
}

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/2a7a8c915695b7298fe725ee3dc6c613fa9d9bbe/governance/votes/Executive%20vote%20-%20April%2012%2C%202021.md -q -O - 2>/dev/null)"
    string public constant description =
        "";

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmefQMseb3AiTapiAKKexdKHig8wroKuZbmLtPLv4u2YwW
    //
    uint256 constant TWO_PCT            = 1000000000627937192491029810;
    uint256 constant FOUR_PT_FIVE_PCT   = 1000000001395766281313196627;
    uint256 constant SIX_PCT            = 1000000001847694957439350562;
    uint256 constant SEVEN_PCT          = 1000000002145441671308778766;

    // Math
    uint256 constant THOUSAND = 10 ** 3;
    uint256 constant MILLION  = 10 ** 6;
    uint256 constant WAD      = 10 ** 18;
    uint256 constant RAY      = 10 ** 27;
    uint256 constant RAD      = 10 ** 45;

    // Collaterals
    struct TinlakeAddresses {
        address ROOT;
        address DROP;
        address MGR;
        address MEMBERLIST;
        address COORDINATOR; 
        address SENIOR_OPERATOR;
        address TRANCHE;
    }

    struct MIP21Addresses {
        address MCD_JOIN;
        address GEM;
        address OPERATOR; // MGR
        address INPUT_CONDUIT; // MGR
        address OUTPUT_CONDUIT; // MGR
        address URN;
        address LIQ; // MIP21-LIQ-ORACLE
    }

    struct ChangelogIDs{
        bytes32 gemID;
        bytes32 joinID;
        bytes32 urnID;
        bytes32 inputConduitID;
        bytes32 outputConduitID;
        bytes32 pipID;
    }

    struct CentrifugeCollateralValues {
        TinlakeAddresses tinlakeAddresses;
        MIP21Addresses mip21Addresses;
        ChangelogIDs changelogIDs;
        bytes32 ilk;
        string ilkRegistryName;
        uint256 RATE;
        uint256 CEIL;
        uint256 PRICE;
        uint256 MAT;
        uint48 TAU;
        string DOC;
    }

    // TODO: needs to be constant
    CentrifugeCollateralValues RWA003 = CentrifugeCollateralValues({
        tinlakeAddresses: TinlakeAddresses({
            ROOT: 0x792164b3e10a3CE1efafF7728961aD506c433c18,
            DROP: 0x931C3Ff1F5aC377137d3AaFD80F601BD76cE106e,
            MGR: 0x45e17E350279a2f28243983053B634897BA03b64,
            MEMBERLIST: 0xb7ee04cb62bFD87862e56E2E880b9EeB87aDf20F,
            COORDINATOR: 0xb9575aD050263cC0A9E65B8bd6041DbF5e02bf1F, 
            SENIOR_OPERATOR: 0xDeb6eEEF90bbb5be6A771250eb9bA8d0804c3F5D,
            TRANCHE: 0x3bCe1712d1AaC8C9597Bc65F1c1630aF32F918B0
        }),
        mip21Addresses: MIP21Addresses({
            MCD_JOIN: 0x4CCc7fED3912A32B6Cf7Db2FdA1554a9FF574099,
            GEM: 0xDBC559F5058E593981C48f4f09fA34323df42d51,
            OPERATOR: 0x45e17E350279a2f28243983053B634897BA03b64,
            INPUT_CONDUIT: 0x45e17E350279a2f28243983053B634897BA03b64,
            OUTPUT_CONDUIT: 0x45e17E350279a2f28243983053B634897BA03b64,
            URN:  0x993c239179D6858769996bcAb5989ab2DF75913F,
            LIQ: 0x2881c5dF65A8D81e38f7636122aFb456514804CC
        }),
        changelogIDs: ChangelogIDs({
            gemID: "RWA003",
            joinID: "MCD_JOIN_RWA003_A",
            urnID: "RWA003_A_URN",
            inputConduitID: "RWA003_A_INPUT_CONDUIT",
            outputConduitID: "RWA003_A_OUTPUT_CONDUIT",
            pipID: "PIP_RWA003"
        }),
        ilk: "RWA003-A",
        ilkRegistryName: "RWA003-A: Centrifuge: ConsolFreight",
        RATE: SEVEN_PCT,
        CEIL: 2 * MILLION,
        PRICE: 2_247_200 * WAD,
        MAT: 10_500,
        TAU: 0,
        DOC: ""
    });
    // CentrifugeCollateralValues public constant RWA004;
    // CentrifugeCollateralValues public constant RWA005;
    // CentrifugeCollateralValues public constant RWA006;

    // Maker changelog 
    address public constant MAKER_CHANGELOG = 0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F;

    function actions() public override {
        integrateCentrifugeCollateral(RWA003);
        // integrateCentrifugeCollateral(RWA004);
        // integrateCentrifugeCollateral(RWA005);
        // integrateCentrifugeCollateral(RWA006);

        // bump changelog version
        DssExecLib.setChangelogVersion("1.1.x");
    }

    function integrateCentrifugeCollateral(CentrifugeCollateralValues memory collateral) internal {
        address MIP21_LIQUIDATION_ORACLE =
            DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");

        address vat = DssExecLib.vat();

        // Sanity checks
        require(GemJoinAbstract(collateral.mip21Addresses.MCD_JOIN).vat() == vat, "join-vat-not-match");
        require(GemJoinAbstract(collateral.mip21Addresses.MCD_JOIN).ilk() == collateral.ilk, "join-ilk-not-match");
        require(GemJoinAbstract(collateral.mip21Addresses.MCD_JOIN).gem() == collateral.mip21Addresses.GEM, "join-gem-not-match");
        require(GemJoinAbstract(collateral.mip21Addresses.MCD_JOIN).dec() == DSTokenAbstract(collateral.mip21Addresses.GEM).decimals(), "join-dec-not-match");

        RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).init(
            collateral.ilk, collateral.PRICE, collateral.DOC, collateral.TAU
        );
        (,address pip,,) = RwaLiquidationLike(MIP21_LIQUIDATION_ORACLE).ilks(collateral.ilk);

        // Set price feed for RWA003
        // TODO: re-add
        // DssExecLib.setContract(DssExecLib.spotter(), collateral.ilk, "pip", pip);

        // Init RWA-00x in Vat
        Initializable(vat).init(collateral.ilk);
        // Init RWA-00x in Jug
        Initializable(DssExecLib.jug()).init(collateral.ilk);

        // Allow RWA-00x Join to modify Vat registry
        DssExecLib.authorize(vat, collateral.mip21Addresses.MCD_JOIN);

        // Allow RwaLiquidationOracle to modify Vat registry
        // DssExecLib.authorize(vat, MIP21_LIQUIDATION_ORACLE);

        // Increase the global debt ceiling by the ilk ceiling
        DssExecLib.increaseGlobalDebtCeiling(collateral.CEIL);
        // Set the ilk debt ceiling
        DssExecLib.setIlkDebtCeiling(collateral.ilk, collateral.CEIL);

        // No dust
        // DssExecLib.setIlkMinVaultAmount(collateral.ilk, 0);

        // stability fee
        DssExecLib.setIlkStabilityFee(collateral.ilk, SEVEN_PCT, false);

        // collateralization ratio
        DssExecLib.setIlkLiquidationRatio(collateral.ilk, collateral.MAT);

        // poke the spotter to pull in a price
        DssExecLib.updateCollateralPrice(collateral.ilk);

        // give the urn permissions on the join adapter
        // DssExecLib.authorize(collateral.mip21Addresses.MCD_JOIN, collateral.mip21Addresses.URN);

        // set up the urn
        Hopeable(collateral.mip21Addresses.URN).hope(collateral.mip21Addresses.OPERATOR);

        // set up output conduit
        // Hopeable(collateral.mip21Addresses.OUTPUT_CONDUIT).hope(collateral.mip21Addresses.OPERATOR));

        // Authorize the SC Domain team deployer address on the output conduit
        // during introductory phase. This allows the SC team to assist in the
        // testing of a complete circuit. Once a broker dealer arrangement is
        // established the deployer address should be `deny`ed on the conduit.
        // Kissable(collateral.mip21Addresses.OUTPUT_CONDUIT).kiss(SC_DOMAIN_DEPLOYER_07);

        // add RWA-00x contract to the changelog
        DssExecLib.setChangelogAddress(collateral.changelogIDs.gemID, collateral.mip21Addresses.GEM);
        DssExecLib.setChangelogAddress(collateral.changelogIDs.pipID, pip);
        DssExecLib.setChangelogAddress(collateral.changelogIDs.joinID, collateral.mip21Addresses.MCD_JOIN);
        DssExecLib.setChangelogAddress(collateral.changelogIDs.urnID, collateral.mip21Addresses.URN);
        DssExecLib.setChangelogAddress(
            collateral.changelogIDs.inputConduitID, collateral.mip21Addresses.INPUT_CONDUIT
        );
        DssExecLib.setChangelogAddress(
            collateral.changelogIDs.outputConduitID, collateral.mip21Addresses.OUTPUT_CONDUIT
        );

        address ILK_REGISTRY = DssExecLib.getChangelogAddress("ILK_REGISTRY");
        IlkRegistryAbstract(ILK_REGISTRY).put(
            collateral.ilk,
            collateral.mip21Addresses.MCD_JOIN,
            collateral.mip21Addresses.GEM,
            DSTokenAbstract(collateral.mip21Addresses.GEM).decimals(),
            3,
            pip,
            address(0),
            collateral.ilkRegistryName,
            bytes32ToStr(collateral.ilk)
        );
    }

    function bytes32ToStr(bytes32 _bytes32) internal pure returns (string memory) {
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

}

contract DssSpell is DssExec {
    DssSpellAction internal action_ = new DssSpellAction();
    constructor() DssExec(action_.description(), block.timestamp + 30 days, address(action_)) public {}
}