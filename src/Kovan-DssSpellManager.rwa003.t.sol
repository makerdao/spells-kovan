// pragma solidity 0.6.12;

// import "dss-interfaces/Interfaces.sol";
// import "./Kovan-DssSpell.t.sol";

// interface EpochCoordinatorLike {
//     function closeEpoch() external;
//     function currentEpoch() external returns(uint);
// }

// interface Root {
//     function relyContract(address, address) external;
// }

// interface MemberList {
//     function updateMember(address, uint) external;
// }

// interface AssessorLike {
//     function calcSeniorTokenPrice() external returns (uint);
// }

// interface FileLike {
//     function file(bytes32 what, address data) external;
// }

// interface ERC20Like {
//     function mint(address, uint256) external;
// }

// interface TinlakeManagerLike {
//     function gem() external view returns (address);
//     function wards(address) external view returns (uint);
//     function lock(uint256 wad) external;
//     function join(uint256 wad) external;
//     function draw(uint256 wad) external;
//     function wipe(uint256 wad) external;
//     function exit(uint256 wad) external;
// }

// contract KovanManagerRPCRWA003 is DssSpellTest {
//     DSTokenAbstract  public drop;
//     TinlakeManagerLike mgr;

//     // RWA003/CF4
//     bytes32 constant ilk = "RWA003";
//     address constant LIQ = 0x45e17E350279a2f28243983053B634897BA03b64;
//     address constant URN = 0x993c239179D6858769996bcAb5989ab2DF75913F;

//     // tinlake addresses
//     address constant ROOT = 0x792164b3e10a3CE1efafF7728961aD506c433c18;
//     address constant COORDINATOR = 0xb9575aD050263cC0A9E65B8bd6041DbF5e02bf1F;
//     address constant DROP = 0x931C3Ff1F5aC377137d3AaFD80F601BD76cE106e;
//     address constant MEMBERLIST = 0xb7ee04cb62bFD87862e56E2E880b9EeB87aDf20F;
//     address constant MGR = 0x45e17E350279a2f28243983053B634897BA03b64;

//     Root constant root = Root(ROOT);
//     MemberList constant memberlist = MemberList(MEMBERLIST);
//     EpochCoordinatorLike constant coordinator = EpochCoordinatorLike(COORDINATOR);

//     address self = address(this);

//     function setUp() public {
//         super.setUp();
//         self = address(this);
//         hevm = Hevm(address(CHEAT_CODE));

//         mgr = TinlakeManagerLike(MGR);
//         drop = DSTokenAbstract(address(mgr.gem()));

//         // welcome to hevm KYC
//         hevm.store(address(root), keccak256(abi.encode(address(this), uint(0))), bytes32(uint(1)));

//         root.relyContract(address(memberlist), address(this));

//         memberlist.updateMember(self, uint(-1));
//         memberlist.updateMember(address(mgr), uint(-1));

//         // set this contract as ward on the mgr
//         hevm.store(address(mgr), keccak256(abi.encode(self, uint(0))), bytes32(uint(1)));
//         assertEq(mgr.wards(self), 1);

//         // file MIP21 contracts 
//         FileLike(address(mgr)).file("liq", LIQ);
//         FileLike(address(mgr)).file("urn", URN);

//         // give this address 1500 dai and 1000 drop
//         hevm.store(address(dai), keccak256(abi.encode(self, uint(2))), bytes32(uint(1500 ether)));
//         hevm.store(address(drop), keccak256(abi.encode(self, uint(0))), bytes32(uint(1)));
//         ERC20Like(address(drop)).mint(self, 1000 ether);

//         assertEq(mgr.wards(self), 1);

//         assertEq(dai.balanceOf(self), 1500 ether);
//         assertEq(drop.balanceOf(self), 1000 ether);

//         // approve the managers
//         drop.approve(address(mgr), uint(-1));
//         dai.approve(address(mgr), uint(-1));

//         emit log_named_address("mgr", MGR);
//         emit log_named_address("drop", DROP);
//         emit log_named_address("memberlist", MEMBERLIST);
//         emit log_named_address("mgr drop", address(mgr.gem()));

//         // spell is already executed on kovan
//         executeSpell();
//         lock();
//     }

//     function lock() public {
//         uint rwaToken = 1 ether;
//         mgr.lock(rwaToken);
//     }

//     function testJoinAndDraw() public {
//         uint preBal = drop.balanceOf(address(mgr));
//         assertEq(dai.balanceOf(self), 1500 ether);
//         assertEq(drop.balanceOf(self), 1000 ether);

//         mgr.join(400 ether);
//         mgr.draw(200 ether);
//         assertEq(dai.balanceOf(self), 1700 ether);
//         assertEq(drop.balanceOf(self), 600 ether);
//         assertEq(drop.balanceOf(address(mgr)), preBal + 400 ether);
//     }

//     function testWipeAndExit() public {
//         testJoinAndDraw();
//         mgr.wipe(10 ether);
//         mgr.exit(10 ether);
//         assertEq(dai.balanceOf(self), 1690 ether);
//         assertEq(drop.balanceOf(self), 610 ether);
//     }

//     function cdptab() public view returns (uint) {
//         // Calculate DAI cdp debt
//         (, uint art) = vat.urns(ilk, address(mgr));
//         (, uint rate, , ,) = vat.ilks(ilk);
//         return art * rate;
//     }
// }
