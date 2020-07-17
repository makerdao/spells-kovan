// Copyright (C) 2020 Maker Ecosystem Growth Holdings, INC.
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

pragma solidity 0.5.12;

import "lib/dss-interfaces/src/dapp/DSPauseAbstract.sol";
import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dss/CatAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipAbstract.sol";
import "lib/dss-interfaces/src/dss/FlapAbstract.sol";
import "lib/dss-interfaces/src/dss/FlopAbstract.sol";
import "lib/dss-interfaces/src/dss/SpotAbstract.sol";
import "lib/dss-interfaces/src/dss/PotAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipperMomAbstract.sol";
import "lib/dss-interfaces/src/dss/VowAbstract.sol";

contract SpellAction {
    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    string constant public description = "2020-07-27 MakerDAO Executive Spell";

    // KOVAN ADDRESSES
    //
    // The contracts in this list should correspond to MCD core contracts, verify
    //  against the current release list at:
    //     https://changelog.makerdao.com/releases/kovan/1.0.8/contracts.json

    address constant public MCD_VAT         = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
    address constant public MCD_VOW         = 0x0F4Cbe6CBA918b7488C26E29d9ECd7368F38EA3b;
    address constant public MCD_CAT         = 0x0511674A67192FE51e86fE55Ed660eB4f995BDd6;
    address constant public MCD_JUG         = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
    address constant public MCD_POT         = 0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb;

    address constant public MCD_SPOT        = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
    address constant public MCD_END         = 0x24728AcF2E2C403F5d2db4Df6834B8998e56aA5F;
    address constant public FLIPPER_MOM     = 0xf3828caDb05E5F22844f6f9314D99516D68a0C84;

    address constant public MCD_FLAP        = 0xc6d3C83A080e2Ef16E4d7d4450A869d0891024F5;
    address constant public MCD_FLOP        = 0x52482a3100F79FC568eb2f38C4a45ba457FBf5fA;
    address constant public MCD_FLAP_OLD    = 0x064cd5f762851b1af81Fd8fcA837227cb3eC84b4;
    address constant public MCD_FLOP_OLD    = 0x145B00b1AC4F01E84594EFa2972Fce1f5Beb5CED;

    address constant public ETH_A_FLIP      = 0xc78EdADA7e8bEa29aCc3a31bBA1D516339deD350;
    address constant public ETH_A_FLIP_OLD  = 0xB40139Ea36D35d0C9F6a2e62601B616F1FfbBD1b;

    address constant public BAT_A_FLIP      = 0xcf4D650679a23ec4027f6675c7245d02fbFc7Da3;
    address constant public BAT_A_FLIP_OLD  = 0xC94014A032cA5fCc01271F4519Add7E87a16b94C;

    address constant public USDC_A_FLIP     = 0x157c2552165fE6e1003981076eAA20F6e0a2B30F;
    address constant public USDC_A_FLIP_OLD = 0x45d5b4A304f554262539cfd167dd05e331Da686E;

    address constant public USDC_B_FLIP     = 0x8ceC95bB1758Ff2126e63a85ffC3C3c0F3717ea1;
    address constant public USDC_B_FLIP_OLD = 0x93AE217b0C6bF52E9FFea6Ab191cCD438d9EC0de;

    address constant public WBTC_A_FLIP     = 0x21926b5aeC6732B87985376cCb9308823E7e377b;
    address constant public WBTC_A_FLIP_OLD = 0xc45A1b76D3316D56a0225fB02Ab6b7637403fF67;

    address constant public ZRX_A_FLIP      = 0xdc181998D4d4aF194a16b59a3a018017F624D5C4;
    address constant public ZRX_A_FLIP_OLD  = 0x1341E0947D03Fd2C24e16aaEDC347bf9D9af002F;

    address constant public KNC_A_FLIP      = 0x675597341Cb21Bdbb69A5Aa18C9638eaa5DC06d6;
    address constant public KNC_A_FLIP_OLD  = 0xf14Ec3538C86A31bBf576979783a8F6dbF16d571;

    address constant public TUSD_A_FLIP     = 0x72bE7125B1CFf0dA9D6AD98e9e14d560F57FaAd2;
    address constant public TUSD_A_FLIP_OLD = 0x51a8fB578E830c932A2D49927584C643Ad08d9eC;

    // decimals & precision
    uint256 constant public THOUSAND = 10 ** 3;
    uint256 constant public MILLION  = 10 ** 6;
    uint256 constant public WAD      = 10 ** 18;
    uint256 constant public RAY      = 10 ** 27;
    uint256 constant public RAD      = 10 ** 45;

    // Are these the right values?
    uint256 constant beg = 1.05E18; // 5% minimum bid increase
    uint48  constant ttl = 3 hours; // 3 hours bid duration
    uint48  constant tau = 2 days;  // 2 days total auction length
    uint256 constant pad = 1.50E18; // 50% lot increase for tick


    function execute() external {

        PotAbstract(MCD_POT).drip();
        JugAbstract(MCD_JUG).drip("ETH-A");
        JugAbstract(MCD_JUG).drip("BAT-A");
        JugAbstract(MCD_JUG).drip("USDC-A");
        JugAbstract(MCD_JUG).drip("USDC-B");
        JugAbstract(MCD_JUG).drip("WBTC-A");
        JugAbstract(MCD_JUG).drip("ZRX-A");
        JugAbstract(MCD_JUG).drip("KNC-A");
        JugAbstract(MCD_JUG).drip("TUSD-A");

        /*** Add new Flip, Flap, Flop contracts ***/
        CatAbstract vat = VatAbstract(MCD_CAT);
        CatAbstract cat = CatAbstract(MCD_CAT);
        VowAbstract vow = VowAbstract(MCD_VOW);

        FlapAbstract newFlap = FlapAbstract(MCD_FLAP);
        FlopAbstract newFlop = FlopAbstract(MCD_FLOP);
        FlapAbstract oldFlap = FlapAbstract(MCD_FLAP_OLD);
        FlopAbstract oldFlop = FlopAbstract(MCD_FLOP_OLD);

        vow.file("flapper", MCD_FLAP);
        newFlap.rely(MCD_VOW);
        newFlap.file("beg", beg);
        newFlap.file("ttl", ttl);
        newFlap.file("tau", tau);
        oldFlap.deny(MCD_VOW);

        vow.file("flopper", MCD_FLOP);
        newFlop.rely(MCD_VOW);
        vat.rely(MCD_FLOP);
        mkrAuthority.rely(MCD_FLOP);
        newFlop.file("beg", beg);
        newFlop.file("pad", pad);
        newFlop.file("ttl", ttl);
        newFlop.file("tau", tau);
        oldFlop.deny(MCD_VOW);
        vat.deny(MCD_FLOP_OLD);
        mkrAuthority.deny(MCD_FLOP_OLD);

        FlipAbstract newFlip;
        FlipAbstract oldFlip;
        bytes32 ilk;
        
        /*** ETH-A ***/
        ilk = "ETH-A";
        newFlip = FlipAbstract(ETH_A_FLIP);
        oldFlip = FlipAbstract(ETH_A_FLIP_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", beg);
        newFlip.file("ttl", ttl);
        newFlip.file("tau", tau);

        
        /*** BAT-A ***/
        ilk = "BAT-A";
        newFlip = FlipAbstract(BAT_A_FLIP);
        oldFlip = FlipAbstract(BAT_A_FLIP_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", beg);
        newFlip.file("ttl", ttl);
        newFlip.file("tau", tau);

        
        /*** USDC-A ***/
        ilk = "USDC-A";
        newFlip = FlipAbstract(USDC_A_FLIP);
        oldFlip = FlipAbstract(USDC_A_FLIP_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", beg);
        newFlip.file("ttl", ttl);
        newFlip.file("tau", tau);

        
        /*** USDC-B ***/
        ilk = "USDC-B";
        newFlip = FlipAbstract(USDC_B_FLIP);
        oldFlip = FlipAbstract(USDC_B_FLIP_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", beg);
        newFlip.file("ttl", ttl);
        newFlip.file("tau", tau);

        
        /*** WBTC-A ***/
        ilk = "WBTC-A";
        newFlip = FlipAbstract(WBTC_A_FLIP);
        oldFlip = FlipAbstract(WBTC_A_FLIP_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", beg);
        newFlip.file("ttl", ttl);
        newFlip.file("tau", tau);

        
        /*** ZRX-A ***/
        ilk = "ZRX-A";
        newFlip = FlipAbstract(ZRX_A_FLIP);
        oldFlip = FlipAbstract(ZRX_A_FLIP_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", beg);
        newFlip.file("ttl", ttl);
        newFlip.file("tau", tau);

        
        /*** KNC-A ***/
        ilk = "KNC-A";
        newFlip = FlipAbstract(KNC_A_FLIP);
        oldFlip = FlipAbstract(KNC_A_FLIP_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", beg);
        newFlip.file("ttl", ttl);
        newFlip.file("tau", tau);

        
        /*** TUSD-A ***/
        ilk = "TUSD-A";
        newFlip = FlipAbstract(TUSD_A_FLIP);
        oldFlip = FlipAbstract(TUSD_A_FLIP_OLD);
        newFlap = FlapAbstract(TUSD_A_FLAP);
        oldFlap = FlapAbstract(TUSD_A_FLAP_OLD);
        newFlop = FlopAbstract(TUSD_A_FLOP);
        oldFlop = FlopAbstract(TUSD_A_FLOP_OLD);

        cat.file(ilk, "flip", address(newFlip));
        newFlip.rely(MCD_CAT);
        newFlip.rely(MCD_END);
        newFlip.rely(FLIPPER_MOM);
        oldFlip.deny(MCD_CAT);
        oldFlip.deny(MCD_END);
        oldFlip.deny(FLIPPER_MOM);
        newFlip.file("beg", beg);
        newFlip.file("ttl", ttl);
        newFlip.file("tau", tau);
    }
}

contract DssSpell {
    DSPauseAbstract  public pause =
        DSPauseAbstract(0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189);
    address          public action;
    bytes32          public tag;
    uint256          public eta;
    bytes            public sig;
    uint256          public expiration;
    bool             public done;

    constructor() public {
        sig = abi.encodeWithSignature("execute()");
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 30 days;
    }

    function description() public view returns (string memory) {
        return SpellAction(action).description();
    }

    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}