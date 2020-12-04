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
import "lib/dss-interfaces/src/dss/CatAbstract.sol";
import "lib/dss-interfaces/src/dss/EndAbstract.sol";
import "lib/dss-interfaces/src/dss/FlipAbstract.sol";
import "lib/dss-interfaces/src/dss/VatAbstract.sol";
import "lib/dss-interfaces/src/dss/VowAbstract.sol";
import "lib/dss-interfaces/src/dss/JugAbstract.sol";

interface DogAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function Dirt() external view returns (uint256);
    function Hole() external view returns (uint256);
    function ilks(bytes32) external view returns (address, uint256, uint256, uint256, uint256, uint256);
    function live() external view returns (uint256);
    function vat() external view returns (address);
    function vow() external view returns (address);
    function file(bytes32, address) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, bytes32, address) external;
    function chop(bytes32) external view returns (uint256);
    function bark(bytes32, address) external returns (uint256);
    function digs(bytes32, uint256) external;
    function cage() external;
}

interface ClipAbstract {
  function dog() external view returns (address);
  function vat() external view returns (address);
  function vow() external view returns (address);
  function ilk() external view returns (bytes32);
  function wards(address) external view returns (uint256);
  function rely(address) external;
  function deny(address) external;
  function file(bytes32, address) external;
  function file(bytes32, uint256) external;
}

interface AbacusAbstract {
    function file(bytes32, uint256) external;
}

contract SpellAction {

    // Testnet addresses
    //
    // The contracts in this list should correspond to MCD on testchain, which can be verified at
    // https://github.com/makerdao/testchain/blob/a293003c3a68474b12e303f54de6e455cefee82c/out/addresses-mcd.json

    address constant MCD_VAT             = 0x2125C30dA5DcA0819aEC5e4cdbF58Bfe91918e43;
    address constant MCD_VOW             = 0x9F3CEceFEb8bCCEd859A983cB3A9b4DA65D79bD1;
    address constant MCD_FLIP_ETH_A      = 0x970b3b28EBD466f2eC181630D4c3C93DfE280448;
    address constant MCD_JUG             = 0x32fE44E2061A19419C0F112596B6f6ea77EC6511;

    // Decimals & precision
    uint256 constant THOUSAND = 10 ** 3;
    uint256 constant MILLION  = 10 ** 6;
    uint256 constant WAD      = 10 ** 18;
    uint256 constant RAY      = 10 ** 27;
    uint256 constant RAD      = 10 ** 45;


    function execute(DogAbstract dog, ClipAbstract clipper, AbacusAbstract abacus) external {

        // ************************
        // *** Liquidations 2.0 ***
        // *** Initial parameters used from https://github.com/makerdao/dss/blob/liq-2.0/src/test/clip.t.sol ***
        // ************************

        require(dog.vat() == MCD_VAT,              "non-matching-vat");
        require(dog.live() == 1,                   "dog-not-live");

        /// DOG
        dog.file("vow", MCD_VOW);
        VatAbstract(MCD_VAT).rely(address(dog));
        VowAbstract(MCD_VOW).rely(address(dog));

        dog.file("Hole", 1000 * RAD);

        /// ABACUS
        abacus.file("cut",  1 * RAY / 100);   // 1% decrease
        abacus.file("step", 1);            // Decrease every 1 second

        // CLIP
        VatAbstract(MCD_VAT).rely(address(clipper));                // Is this needed?
        _flipToClip(clipper, FlipAbstract(MCD_FLIP_ETH_A), dog, abacus);

        // Super high stability fees to liquidate Vaults
        JugAbstract(MCD_JUG).drip("ETH-A");
        uint256 ETH_FEE = 1020000021979553151239153027;
        JugAbstract(MCD_JUG).file("ETH-A", "duty", ETH_FEE);


    }

    function _flipToClip(ClipAbstract newClip, FlipAbstract oldFlip, DogAbstract dog, AbacusAbstract abacus) internal {
        bytes32 ilk = newClip.ilk();
        require(ilk == oldFlip.ilk(), "non-matching-ilk");
        require(newClip.vat() == oldFlip.vat(), "non-matching-vat");
        require(newClip.dog() == address(dog), "non-matching-dog");
        require(newClip.vat() == MCD_VAT, "non-matching-vat");

        dog.file(ilk, "clip", address(newClip));
        dog.file(ilk, "chop", 1.1 ether); // 10% chop
        dog.file(ilk, "hole", 1000 * RAD); // 1000 DAI
        dog.file(ilk, "chip", 2 * WAD / 100); // linear increase of 2% of tab
        dog.file(ilk, "tip", 2 * RAD); // flat fee of two DAI

        dog.rely(address(newClip));

        newClip.rely(address(dog));

        newClip.file("buf",  5 * RAY / 4);      // 25% Initial price buffer
        newClip.file("calc", address(abacus));  // File price contract
        newClip.file("cusp", 1 * RAY / 3);      // 67.77% drop before reset
        newClip.file("tail", 3600);             // 1 hour before reset
    }
}

contract DssSpellTestchain {
    DSPauseAbstract public pause =
        DSPauseAbstract(0xcB283aD50b70444AEE310288F7aF33D05c1884A2);
    address         public action;
    bytes32         public tag;
    uint256         public eta;
    bytes           public sig;
    uint256         public expiration;
    bool            public done;

    // Provides a descriptive tag for bot consumption
    string constant public description =
        "Auction-Demo-Keeper LIQ2.0 Support";

    constructor(address dog, address clipper, address abacus) public {
        sig = abi.encodeWithSignature("execute(address,address,address)", dog, clipper, abacus);
        action = address(new SpellAction());
        bytes32 _tag;
        address _action = action;
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
        expiration = now + 30 days;
    }

    modifier officeHours {
        uint day = (now / 1 days + 3) % 7;
        require(day < 5, "Can only be cast on a weekday");
        uint hour = now / 1 hours % 24;
        require(hour >= 14 && hour < 21, "Outside office hours");
        _;
    }

    function schedule() public {
        require(now <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = now + DSPauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() public /* officeHours */ {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}

