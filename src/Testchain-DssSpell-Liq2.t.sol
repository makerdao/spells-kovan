pragma solidity 0.5.12;

import "ds-math/math.sol";
import "ds-test/test.sol";
import "lib/dss-interfaces/src/Interfaces.sol";

import {DssSpellTestchain, SpellAction} from "./Testchain-DssSpell-Liq2.sol";

interface Hevm {
    function warp(uint) external;
    function store(address,bytes32,bytes32) external;
}

interface MedianizerV1Abstract {
    function authority() external view returns (address);
}

contract DssSpellTestTestchain is DSTest, DSMath {
    address constant TESTCHAIN_SPELL = address(0xA8f3E26087859D38bFFc664ca2D7a1C8a13c36C9);

    struct CollateralValues {
        uint256 line;
        uint256 dust;
        uint256 chop;
        uint256 dunk;
        uint256 pct;
        uint256 mat;
        uint256 beg;
        uint48 ttl;
        uint48 tau;
        uint256 liquidations;
    }

    struct SystemValues {
        uint256 dsr_rate;
        uint256 vat_Line;
        uint256 pause_delay;
        uint256 vow_wait;
        uint256 vow_dump;
        uint256 vow_sump;
        uint256 vow_bump;
        uint256 vow_hump;
        uint256 cat_box;
        uint256 ilk_count;
        address osm_mom_authority;
        address flipper_mom_authority;
        mapping (bytes32 => CollateralValues) collaterals;
    }

    SystemValues afterSpell;
    Hevm hevm;

    // KOVAN ADDRESSES
    DSPauseAbstract      pause = DSPauseAbstract(    0xbacD4966540aAF7223CC9DC39a3ea1E4322Aba78);
    address         pauseProxy =                     0xBAfAfffeD9132270493DcfcA9B54915C0E9BDA24;
    DSChiefAbstract      chief = DSChiefAbstract(    0x32fF9398E20e95eE7E5AeA732159C4315553cE00);
    VatAbstract            vat = VatAbstract(        0xb002A319887185e56d787A5c90900e13834a85E3);
    CatAbstract            cat = CatAbstract(        0x9F3CEceFEb8bCCEd859A983cB3A9b4DA65D79bD1);
    VowAbstract            vow = VowAbstract(        0x32fE44E2061A19419C0F112596B6f6ea77EC6511);
    PotAbstract            pot = PotAbstract(        0xe53793CA0F1a3991D6bfBc5929f89A9eDe65da44);
    JugAbstract            jug = JugAbstract(        0x2125C30dA5DcA0819aEC5e4cdbF58Bfe91918e43);
    SpotAbstract          spot = SpotAbstract(       0x970b3b28EBD466f2eC181630D4c3C93DfE280448);

    DSTokenAbstract        gov = DSTokenAbstract(    0x1c3ac7216250eDC5B9DaA5598DA0579688b9dbD5);
    EndAbstract            end = EndAbstract(        0xd34835EaE60dA418abfc538B7b55332fC5F10340);
    IlkRegistryAbstract    reg = IlkRegistryAbstract(0xdEc9C60788E92959bb62848C507170A26C4D692D);

    // Faucet
    FaucetAbstract      faucet = FaucetAbstract(     0xF6bbB12EEE8B45214B2c8A8F9487982a35b7Ae81);

    DssSpellTestchain spell;

    // CHEAT_CODE = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D
    bytes20 constant CHEAT_CODE =
        bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    uint256 constant HUNDRED    = 10 ** 2;
    uint256 constant THOUSAND   = 10 ** 3;
    uint256 constant MILLION    = 10 ** 6;
    uint256 constant BILLION    = 10 ** 9;
    uint256 constant WAD        = 10 ** 18;
    uint256 constant RAY        = 10 ** 27;
    uint256 constant RAD        = 10 ** 45;

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.01)/(60 * 60 * 24 * 365) )'
    //
    // Rates table is in ./test/rates.sol

    // not provided in DSMath
    function rpow(uint x, uint n, uint b) internal pure returns (uint z) {
      assembly {
        switch x case 0 {switch n case 0 {z := b} default {z := 0}}
        default {
          switch mod(n, 2) case 0 { z := b } default { z := x }
          let half := div(b, 2)  // for rounding.
          for { n := div(n, 2) } n { n := div(n,2) } {
            let xx := mul(x, x)
            if iszero(eq(div(xx, x), x)) { revert(0,0) }
            let xxRound := add(xx, half)
            if lt(xxRound, xx) { revert(0,0) }
            x := div(xxRound, b)
            if mod(n,2) {
              let zx := mul(z, x)
              if and(iszero(iszero(x)), iszero(eq(div(zx, x), z))) { revert(0,0) }
              let zxRound := add(zx, half)
              if lt(zxRound, zx) { revert(0,0) }
              z := div(zxRound, b)
            }
          }
        }
      }
    }
    // 10^-5 (tenth of a basis point) as a RAY
    uint256 TOLERANCE = 10 ** 22;

    function yearlyYield(uint256 duty) public pure returns (uint256) {
        return rpow(duty, (365 * 24 * 60 *60), RAY);
    }

    function expectedRate(uint256 percentValue) public pure returns (uint256) {
        return (10000 + percentValue) * (10 ** 23);
    }

    function diffCalc(uint256 expectedRate_, uint256 yearlyYield_) public pure returns (uint256) {
        return (expectedRate_ > yearlyYield_) ? expectedRate_ - yearlyYield_ : yearlyYield_ - expectedRate_;
    }

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));

        spell = TESTCHAIN_SPELL != address(0) ? DssSpellTestchain(TESTCHAIN_SPELL) : new DssSpellTestchain(address(0), address(0), address(0));

    }

    function vote() private {

        gov.approve(address(chief), uint256(-1));
        chief.lock(sub(gov.balanceOf(address(this)), 1 ether));

        assertTrue(!spell.done());

        address[] memory yays = new address[](1);
        yays[0] = address(spell);

        chief.vote(yays);
        chief.lift(address(spell));
        
        assertEq(chief.hat(), address(spell));
    }

    function scheduleWaitAndCast() public {
        spell.schedule();
        hevm.warp(now + pause.delay());
        spell.cast();
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        assembly {
            result := mload(add(source, 32))
        }
    }

    function testchainSpellIsCast() public {
        vote();
        scheduleWaitAndCast();
        assertTrue(spell.done());

    }
}
