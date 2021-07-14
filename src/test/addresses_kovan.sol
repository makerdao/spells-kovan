
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.6.12;

contract Addresses {

    mapping (bytes32 => address) public addr;

    constructor() public {
        addr["CHANGELOG"]                       = 0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F;
        addr["MULTICALL"]                       = 0xC6D81A2e375Eee15a20E6464b51c5FC6Bb949fdA;
        addr["FAUCET"]                          = 0x57aAeAE905376a4B1899bA81364b4cE2519CBfB3;
        addr["MCD_DEPLOY"]                      = 0x13141b8a5E4A82Ebc6b636849dd6A515185d6236;
        addr["FLIP_FAB"]                        = 0x7c890e1e492FDDA9096353D155eE1B26C1656a62;
        addr["MCD_GOV"]                         = 0xAaF64BFCC32d0F15873a02163e7E500671a4ffcD;
        addr["GOV_GUARD"]                       = 0xE50303C6B67a2d869684EFb09a62F6aaDD06387B;
        addr["MCD_ADM"]                         = 0x27E0c9567729Ea6e3241DE74B3dE499b7ddd3fe6;
        addr["VOTE_PROXY_FACTORY"]              = 0x1400798AA746457E467A1eb9b3F3f72C25314429;
        addr["MCD_VAT"]                         = 0xbA987bDB501d131f766fEe8180Da5d81b34b69d9;
        addr["MCD_JUG"]                         = 0xcbB7718c9F39d05aEEDE1c472ca8Bf804b2f1EaD;
        addr["MCD_CAT"]                         = 0xdDb5F7A3A5558b9a6a1f3382BD75E2268d1c6958;
        addr["MCD_DOG"]                         = 0x121D0953683F74e9a338D40d9b4659C0EBb539a0;
        addr["MCD_VOW"]                         = 0x0F4Cbe6CBA918b7488C26E29d9ECd7368F38EA3b;
        addr["MCD_JOIN_DAI"]                    = 0x5AA71a3ae1C0bd6ac27A1f28e1415fFFB6F15B8c;
        addr["MCD_FLAP"]                        = 0xc6d3C83A080e2Ef16E4d7d4450A869d0891024F5;
        addr["MCD_FLOP"]                        = 0x52482a3100F79FC568eb2f38C4a45ba457FBf5fA;
        addr["MCD_PAUSE"]                       = 0x8754E6ecb4fe68DaA5132c2886aB39297a5c7189;
        addr["MCD_PAUSE_PROXY"]                 = 0x0e4725db88Bb038bBa4C4723e91Ba183BE11eDf3;
        addr["MCD_GOV_ACTIONS"]                 = 0x0Ca17E81073669741714354f16D800af64e95C75;
        addr["MCD_DAI"]                         = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
        addr["MCD_SPOT"]                        = 0x3a042de6413eDB15F2784f2f97cC68C7E9750b2D;
        addr["MCD_POT"]                         = 0xEA190DBDC7adF265260ec4dA6e9675Fd4f5A78bb;
        addr["MCD_END"]                         = 0x3d9603037FF096af03B83725dFdB1CDA9EA02CE4;
        addr["MCD_ESM"]                         = 0xD5D728446275B0A12E4a4038527974b92353B4a9;
        addr["PROXY_ACTIONS"]                   = 0xD8b9702755E91Aa792656966aE6bAF32F4C394Ba;
        addr["PROXY_ACTIONS_END"]               = 0x7c3f28f174F2b0539C202a5307Ff48efa61De982;
        addr["PROXY_ACTIONS_DSR"]               = 0xc5CC1Dfb64A62B9C7Bb6Cbf53C2A579E2856bf92;
        addr["CDP_MANAGER"]                     = 0x1476483dD8C35F25e568113C5f70249D3976ba21;
        addr["DSR_MANAGER"]                     = 0x7f5d60432DE4840a3E7AE7218f7D6b7A2412683a;
        addr["GET_CDPS"]                        = 0x592301a23d37c591C5856f28726AF820AF8e7014;
        addr["ILK_REGISTRY"]                    = 0xc3F42deABc0C506e8Ae9356F2d4fc1505196DCDB;
        addr["OSM_MOM"]                         = 0x5dA9D1C3d4f1197E5c52Ff963916Fe84D2F5d8f3;
        addr["FLIPPER_MOM"]                     = 0x50dC6120c67E456AdA2059cfADFF0601499cf681;
        addr["CLIPPER_MOM"]                     = 0x96E9a19Be6EA91d1C0908e5E207f944dc2E7B878;
        addr["MCD_IAM_AUTO_LINE"]               = 0xe7D7d61c0ed9306B6c93E7C65F6C9DDF38b9320b;
        addr["PROXY_FACTORY"]                   = 0xe11E3b391F7E8bC47247866aF32AF67Dd58Dc800;
        addr["PROXY_REGISTRY"]                  = 0x64A436ae831C1672AE81F674CAb8B6775df3475C;
        addr["ETH"]                             = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
        addr["PIP_ETH"]                         = 0x75dD74e8afE8110C8320eD397CcCff3B8134d981;
        addr["MCD_JOIN_ETH_A"]                  = 0x775787933e92b709f2a3C70aa87999696e74A9F8;
        addr["MCD_FLIP_ETH_A"]                  = 0x750295A8db0580F32355f97de7918fF538c818F1;
        addr["MCD_CLIP_ETH_A"]                  = 0x7dD1Fb6b9aFdBA9F28DB89c81723b8c6B27A2Fbe;
        addr["MCD_CLIP_CALC_ETH_A"]             = 0x46bE29C1993d64f0C93e81D69FfAFDF4881806f2;
        addr["MCD_JOIN_ETH_B"]                  = 0xd19A770F00F89e6Dd1F12E6D6E6839b95C084D85;
        addr["MCD_FLIP_ETH_B"]                  = 0x360e15d419c14f6060c88Ac0741323C37fBfDa2D;
        addr["MCD_CLIP_ETH_B"]                  = 0x004676c737FC75A2799dFe745d23F5597620Ad43;
        addr["MCD_CLIP_CALC_ETH_B"]             = 0x4672215ADF0556Af60261e97E221c875ce9F0863;
        addr["MCD_JOIN_ETH_C"]                  = 0xD166b57355BaCE25e5dEa5995009E68584f60767;
        addr["MCD_FLIP_ETH_C"]                  = 0x6EB1922EbfC357bAe88B4aa5aB377A8C4DFfB4e9;
        addr["MCD_CLIP_ETH_C"]                  = 0x86D5eA244cf6c79227CA73004C963b72431f23ac;
        addr["MCD_CLIP_CALC_ETH_C"]             = 0xa8AfB2680cced6de0E1dfe5C35F0FEdFB8E95720;
        addr["BAT"]                             = 0x9f8cFB61D3B2aF62864408DD703F9C3BEB55dff7;
        addr["PIP_BAT"]                         = 0x5C40C9Eb35c76069fA4C3A00EA59fAc6fFA9c113;
        addr["MCD_JOIN_BAT_A"]                  = 0x2a4C485B1B8dFb46acCfbeCaF75b6188A59dBd0a;
        addr["MCD_FLIP_BAT_A"]                  = 0x44Acf0eb2C7b9F0B55723e5289437AefE8ef7a1c;
        addr["MCD_CLIP_BAT_A"]                  = 0x332B44A24e2CF8A258E8A1932b13296b9316a74c;
        addr["MCD_CLIP_CALC_BAT_A"]             = 0x4AB9058A9cAB0B18B4b40621Fa44B2131836Ad32;
        addr["USDC"]                            = 0xBD84be3C303f6821ab297b840a99Bd0d4c4da6b5;
        addr["PIP_USDC"]                        = 0x4c51c2584309b7BF328F89609FDd03B3b95fC677;
        addr["MCD_JOIN_USDC_A"]                 = 0x4c514656E7dB7B859E994322D2b511d99105C1Eb;
        addr["MCD_FLIP_USDC_A"]                 = 0x17C144eaC1B3D6777eF2C3fA1F98e3BC3c18DB4F;
        addr["MCD_CLIP_USDC_A"]                 = 0x09D45087c035DbcD8d6fB5e9d4c5341b9101E626;
        addr["MCD_CLIP_CALC_USDC_A"]            = 0xF8D26c26Ac481794E4Aebf4F35B10d8E9748086a;
        addr["MCD_JOIN_USDC_B"]                 = 0xaca10483e7248453BB6C5afc3e403e8b7EeDF314;
        addr["MCD_FLIP_USDC_B"]                 = 0x6DCd745D91AB422e962d08Ed1a9242adB47D8d0C;
        addr["MCD_CLIP_USDC_B"]                 = 0xedFc36f75faafa80e39cd4623def15da6CF2B5C0;
        addr["MCD_CLIP_CALC_USDC_B"]            = 0x275076c9c101AF880BD944991258d564FA31D61B;
        addr["MCD_JOIN_PSM_USDC_A"]             = 0x4BA159Ad37FD80D235b4a948A8682747c74fDc0E;
        addr["MCD_FLIP_PSM_USDC_A"]             = 0xe9eef655494F63802e9C7A7F1006547c4De3e713;
        addr["MCD_CLIP_PSM_USDC_A"]             = 0xC8Ca47D0AE4193b3f7F813E95669cfB15d922D56;
        addr["MCD_CLIP_CALC_PSM_USDC_A"]        = 0x22C3286711bD63D04Da2Ea95C4d7B556B9502a70;
        addr["MCD_PSM_USDC_A"]                  = 0xe4dC42e438879987e287A6d9519379936d7b065A;
        addr["WBTC"]                            = 0x7419f744bBF35956020C1687fF68911cD777f865;
        addr["PIP_WBTC"]                        = 0x2f38a1bD385A9B395D01f2Cbf767b4527663edDB;
        addr["MCD_JOIN_WBTC_A"]                 = 0xB879c7d51439F8e7AC6b2f82583746A0d336e63F;
        addr["MCD_FLIP_WBTC_A"]                 = 0x80Fb08f2EF268f491D6B58438326a3006C1a0e09;
        addr["MCD_CLIP_WBTC_A"]                 = 0x5518C2f409Bed4bD5FF3542d9D5002251EEDA892;
        addr["MCD_CLIP_CALC_WBTC_A"]            = 0x2c39F8C9aE16B84076D7fEA15CE5855925a09DA6;
        addr["TUSD"]                            = 0xD6CE59F06Ff2070Dd5DcAd0866A7D8cd9270041a;
        addr["PIP_TUSD"]                        = 0xE4bAECdba7A8Ff791E14c6BF7e8089Dfdf75C7E7;
        addr["MCD_JOIN_TUSD_A"]                 = 0xe53f6755A031708c87d80f5B1B43c43892551c17;
        addr["MCD_FLIP_TUSD_A"]                 = 0x867711f695e11663eC8adCFAAD2a152eFBA56dfD;
        addr["MCD_CLIP_TUSD_A"]                 = 0x9D547d599489B3950485cBa119FC37Bba9c15c13;
        addr["MCD_CLIP_CALC_TUSD_A"]            = 0x4AE93701287b8C86f17E5a0Cb4D0732b5ae6EFBD;
        addr["ZRX"]                             = 0xC2C08A566aD44129E69f8FC98684EAA28B01a6e7;
        addr["PIP_ZRX"]                         = 0x218037a42947E634191A231fcBAEAE8b16a39b3f;
        addr["MCD_JOIN_ZRX_A"]                  = 0x85D38fF6a6FCf98bD034FB5F9D72cF15e38543f2;
        addr["MCD_FLIP_ZRX_A"]                  = 0x798eB3126f1d5cb54743E3e93D3512C58f461084;
        addr["MCD_CLIP_ZRX_A"]                  = 0x9072C477FEb67eEFd8865737206e87570444885E;
        addr["MCD_CLIP_CALC_ZRX_A"]             = 0xCd8Aa54176A333C3B668f65Ff8F11ee909f9A698;
        addr["KNC"]                             = 0x9800a0a3c7e9682e1AEb7CAA3200854eFD4E9327;
        addr["PIP_KNC"]                         = 0x10799280EF9d7e2d037614F5165eFF2cB8522651;
        addr["MCD_JOIN_KNC_A"]                  = 0xE42427325A0e4c8e194692FfbcACD92C2C381598;
        addr["MCD_FLIP_KNC_A"]                  = 0xF2c21882Bd14A5F7Cb46291cf3c86E53057FaD06;
        addr["MCD_CLIP_KNC_A"]                  = 0x09EA13E49885C29dD270B5c3F557D71A30479333;
        addr["MCD_CLIP_CALC_KNC_A"]             = 0x8D11DC42F5Cc6fE19FeE799e3e24b506cEadAB4b;
        addr["MANA"]                            = 0x221F4D62636b7B51b99e36444ea47Dc7831c2B2f;
        addr["PIP_MANA"]                        = 0xE97D2b077Fe19c80929718d377981d9F754BF36e;
        addr["MCD_JOIN_MANA_A"]                 = 0xdC9Fe394B27525e0D9C827EE356303b49F607aaF;
        addr["MCD_FLIP_MANA_A"]                 = 0xb2B7430D49D2D2e7abb6a6B4699B2659c141A2a6;
        addr["MCD_CLIP_MANA_A"]                 = 0xFd79e5881CC59F4637ddb3799D302BF089dEE832;
        addr["MCD_CLIP_CALC_MANA_A"]            = 0x14cd62bB700d3cDe2bC45Db2875b58200DDD2503;
        addr["USDT"]                            = 0x9245BD36FA20fcD292F4765c4b5dF83Dc3fD5e86;
        addr["PIP_USDT"]                        = 0x3588A7973D41AaeA7B203549553C991C4311951e;
        addr["MCD_JOIN_USDT_A"]                 = 0x9B011a74a690dFd9a1e4996168d3EcBDE73c2226;
        addr["MCD_FLIP_USDT_A"]                 = 0x113733e00804e61D5fd8b107Ca11b4569B6DA95D;
        addr["MCD_CLIP_USDT_A"]                 = 0xBDd2d10dAF8D86dA1f02bB7c7C7841bC9A4F62D4;
        addr["MCD_CLIP_CALC_USDT_A"]            = 0xa3a5163Fa4d46D799fE4B036349f0289D69A4445;
        addr["PAXUSD"]                          = 0xa6383AF46c36219a472b9549d70E4768dfA8894c;
        addr["PIP_PAXUSD"]                      = 0xD01fefed46eb21cd057bAa14Ff466842C31a0Cd9;
        addr["MCD_JOIN_PAXUSD_A"]               = 0x3d6a14C9542B429a4e3d255F6687754d4898D897;
        addr["MCD_FLIP_PAXUSD_A"]               = 0x88001b9C8192cbf43e14323B809Ae6C4e815E12E;
        addr["MCD_CLIP_PAXUSD_A"]               = 0x3939B686a0A7265512D38Ea3fe700812A703BF31;
        addr["MCD_CLIP_CALC_PAXUSD_A"]          = 0x784863edC4C28D73192bf56944D8803c0b5E0CbF;
        addr["COMP"]                            = 0x1dDe24ACE93F9F638Bfd6fCE1B38b842703Ea1Aa;
        addr["PIP_COMP"]                        = 0xcc10b1C53f4BFFEE19d0Ad00C40D7E36a454D5c4;
        addr["MCD_JOIN_COMP_A"]                 = 0x16D567c1F6824ffFC460A11d48F61E010ae43766;
        addr["MCD_FLIP_COMP_A"]                 = 0x2917a962BC45ED48497de85821bddD065794DF6C;
        addr["MCD_CLIP_COMP_A"]                 = 0xCDe79465D0B98775c1831957b88BFa12b8A3f020;
        addr["MCD_CLIP_CALC_COMP_A"]            = 0x3e41fCB2DC5370F8612884CB2928E74FED77Cb4B;
        addr["LRC"]                             = 0xF070662e48843934b5415f150a18C250d4D7B8aB;
        addr["PIP_LRC"]                         = 0xcEE47Bb8989f625b5005bC8b9f9A0B0892339721;
        addr["MCD_JOIN_LRC_A"]                  = 0x436286788C5dB198d632F14A20890b0C4D236800;
        addr["MCD_FLIP_LRC_A"]                  = 0xfC9496337538235669F4a19781234122c9455897;
        addr["MCD_CLIP_LRC_A"]                  = 0xaF94A206A3f3948c0BDB6a195a119862F26F5e92;
        addr["MCD_CLIP_CALC_LRC_A"]             = 0xD47DF2Cae1a86fC22e8A8b9B06b22f27860Cb333;
        addr["LINK"]                            = 0xa36085F69e2889c224210F603D836748e7dC0088;
        addr["PIP_LINK"]                        = 0x20D5A457e49D05fac9729983d9701E0C3079Efac;
        addr["MCD_JOIN_LINK_A"]                 = 0xF4Df626aE4fb446e2Dcce461338dEA54d2b9e09b;
        addr["MCD_FLIP_LINK_A"]                 = 0xfbDCDF5Bd98f68cEfc3f37829189b97B602eCFF2;
        addr["MCD_CLIP_LINK_A"]                 = 0x1eB71cC879960606F8ab0E02b3668EEf92CE6D98;
        addr["MCD_CLIP_CALC_LINK_A"]            = 0xbd586d6352Fcf0C45f77FC9348F4Ee7539F6e2bD;
        addr["BAL"]                             = 0x630D82Cbf82089B09F71f8d3aAaff2EBA6f47B15;
        addr["PIP_BAL"]                         = 0x4fd34872F3AbC07ea6C45c7907f87041C0801DdE;
        addr["MCD_JOIN_BAL_A"]                  = 0x8De5EA9251E0576e3726c8766C56E27fAb2B6597;
        addr["MCD_FLIP_BAL_A"]                  = 0xF6d19CC05482Ef7F73f09c1031BA01567EF6ac0f;
        addr["MCD_CLIP_BAL_A"]                  = 0x8F6C48A26ebf4006Ab542d030D4090DfeC39652E;
        addr["MCD_CLIP_CALC_BAL_A"]             = 0xd041ED45EC5e4539BbbCd91B97D36C76F9d678C9;
        addr["YFI"]                             = 0x251F1c3077FEd1770cB248fB897100aaE1269FFC;
        addr["PIP_YFI"]                         = 0x9D8255dc4e25bB85e49c65B21D8e749F2293862a;
        addr["MCD_JOIN_YFI_A"]                  = 0x5b683137481F2FE683E2f2385792B1DeB018050F;
        addr["MCD_FLIP_YFI_A"]                  = 0x5eB5D3B028CD255d79019f7C44a502b31bFFde9d;
        addr["MCD_CLIP_YFI_A"]                  = 0x9020C96B06d2ac59e98A0F35f131D491EEcAa2C2;
        addr["MCD_CLIP_CALC_YFI_A"]             = 0x54A18C6ceEBDf42D8532EBf5e0a67C430a51b2f6;
        addr["GUSD"]                            = 0x31D8EdbF6F33ef858c80d68D06Ec83f33c2aA150;
        addr["PIP_GUSD"]                        = 0xb6630DE6Eda0f3f3d96Db4639914565d6b82CfEF;
        addr["MCD_JOIN_GUSD_A"]                 = 0x0c6B26e6AB583D2e4528034037F74842ea988909;
        addr["MCD_FLIP_GUSD_A"]                 = 0xf6c0e36a76F2B9F7Bd568155F3fDc53ff1be1Aeb;
        addr["MCD_CLIP_GUSD_A"]                 = 0x448eD0ff4e154C1cBefE2c8057906Dd3dA194dA5;
        addr["MCD_CLIP_CALC_GUSD_A"]            = 0x4DD8AaB74a710E7a95937ef1b2618ee76F829Ba6;
        addr["UNI"]                             = 0x0C527850e5D6B2B406F1d65895d5b17c5A29Ce51;
        addr["PIP_UNI"]                         = 0xe573a75BF4827658F6D600FD26C205a3fe34ee28;
        addr["MCD_JOIN_UNI_A"]                  = 0xb6E6EE050B4a74C8cc1DfdE62cAC8C6d9D8F4CAa;
        addr["MCD_FLIP_UNI_A"]                  = 0x6EE8a47eA5d7cF0C951eDc57141Eb9593A36e680;
        addr["MCD_CLIP_UNI_A"]                  = 0xed3D15e390750f0808E64e0Af1F791e6c5b47c2e;
        addr["MCD_CLIP_CALC_UNI_A"]             = 0x1ee2ecD5149F4b46257a37195994337F4a35E5e8;
        addr["RENBTC"]                          = 0xe3dD56821f8C422849AF4816fE9B3c53c6a2F0Bd;
        addr["PIP_RENBTC"]                      = 0x2f38a1bD385A9B395D01f2Cbf767b4527663edDB;
        addr["MCD_JOIN_RENBTC_A"]               = 0x12F1F6c7E5fDF1B671CebFBDE974341847d0Caa4;
        addr["MCD_FLIP_RENBTC_A"]               = 0x2a2E2436370e98505325111A6b98F63d158Fedc4;
        addr["MCD_CLIP_RENBTC_A"]               = 0xEf9EEb37CDB15eaD336440BebC30C4CD37Da1891;
        addr["MCD_CLIP_CALC_RENBTC_A"]          = 0xF47749299BCCe427cFd9d015D543aEF83D3BD4Da;
        addr["AAVE"]                            = 0x7B339a530Eed72683F56868deDa87BbC64fD9a12;
        addr["PIP_AAVE"]                        = 0xd2d9B1355Ea96567E7D6C7A6945f5c7ec8150Cc9;
        addr["MCD_JOIN_AAVE_A"]                 = 0x9f1Ed3219035e6bDb19E0D95d316c7c39ad302EC;
        addr["MCD_FLIP_AAVE_A"]                 = 0x3c84d572749096b67e4899A95430201DF79b8403;
        addr["MCD_CLIP_AAVE_A"]                 = 0xC8D2d6692981abc7DC5Bf4E345ce3Ce462FA90c9;
        addr["MCD_CLIP_CALC_AAVE_A"]            = 0x0FdF9CecFF267a49f4e9f67014AFEc873143677D;
        addr["PROXY_PAUSE_ACTIONS"]             = 0x7c52826c1efEAE3199BDBe68e3916CC3eA222E29;
        addr["UNIV2DAIETH"]                     = 0xB10cf58E08b94480fCb81d341A63295eBb2062C2;
        addr["PIP_UNIV2DAIETH"]                 = 0xED9201cd545F1d2457D2D48981E7832C754959e9;
        addr["MCD_JOIN_UNIV2DAIETH_A"]          = 0x03f18d97D25c13FecB15aBee143276D3bD2742De;
        addr["MCD_FLIP_UNIV2DAIETH_A"]          = 0x0B6C3512C8D4300d566b286FC4a554dAC217AaA6;
        addr["MCD_CLIP_UNIV2DAIETH_A"]          = 0xfcFd4255F67C70Cf5fB534535eBe8152Ba6DC5Cd;
        addr["MCD_CLIP_CALC_UNIV2DAIETH_A"]     = 0x0Aa53A82182dd60a630A49eCc286b295fEC5Ba98;
        addr["PROXY_PAUSE_ACTIONS"]             = 0x7c52826c1efEAE3199BDBe68e3916CC3eA222E29;
        addr["PROXY_DEPLOYER"]                  = 0xA9fCcB07DD3f774d5b9d02e99DE1a27f47F91189;
        addr["MIP21_LIQUIDATION_ORACLE"]        = 0x2881c5dF65A8D81e38f7636122aFb456514804CC;
        addr["RWA001"]                          = 0x8F9A8cbBdfb93b72d646c8DEd6B4Fe4D86B315cB;
        addr["PIP_RWA001"]                      = 0x09710C9440e5FF5c473efe61d5a2f14cA05A6752;
        addr["MCD_JOIN_RWA001_A"]               = 0x029A554f252373e146f76Fa1a7455f73aBF4d38e;
        addr["RWA001_A_URN"]                    = 0x3Ba90D86f7E3218C48b7E0FCa959EcF43d9A30F4;
        addr["RWA001_A_INPUT_CONDUIT"]          = 0xB944B07EC3B680b2cEA753125667F7663d424DC3;
        addr["RWA001_A_OUTPUT_CONDUIT"]         = 0xc54fEee07421EAB8000AC8c921c0De9DbfbE780B;
        addr["RWA002"]                          = 0xea8a2f6DC9236edb3f53744f5019a444e24F4379;
        addr["PIP_RWA002"]                      = 0xaD6495E5918C5F66650EDf291C97b31aBaf5Cd7B;
        addr["MCD_JOIN_RWA002_A"]               = 0x3B3fAD77D6977a19cc7B156143056a3E9C6Ca329;
        addr["RWA002_A_URN"]                    = 0xc615F4188C255445290fB9E6dB5E021fe4CA8ECf;
        addr["RWA002_A_INPUT_CONDUIT"]          = 0x2CfADbd094a4D650049C53832B15842a3c59Db34;
        addr["RWA002_A_OUTPUT_CONDUIT"]         = 0x2CfADbd094a4D650049C53832B15842a3c59Db34;
        addr["PAXG"]                            = 0x52403FCEfcf3A810e58868fF19c34725B426473A;
        addr["PIP_PAXG"]                        = 0x31CceDBc45179f17CfD34967680C6560b6509C1A;
        addr["MCD_JOIN_PAXG_A"]                 = 0x822248F31bd899DE327A760a78B6C84889aF180D;
        addr["MCD_FLIP_PAXG_A"]                 = 0x0b2e32151041641Fa37a1F54D7eD526989eF9B73;
        addr["LERP_FAB"]                        = 0xa6766Ed3574bAFc6114618E74035C7bb5e9a6aa9;
        addr["MCD_FLASH"]                       = 0x5aA1323f61D679E52a90120DFDA2ed1A76E4475A;
        addr["RWA003"]                          = 0xDBC559F5058E593981C48f4f09fA34323df42d51;
        addr["MCD_JOIN_RWA003_A"]               = 0x4CCc7fED3912A32B6Cf7Db2FdA1554a9FF574099;
        addr["RWA003_A_URN"]                    = 0x993c239179D6858769996bcAb5989ab2DF75913F;
        addr["RWA003_A_INPUT_CONDUIT"]          = 0x45e17E350279a2f28243983053B634897BA03b64;
        addr["RWA003_A_OUTPUT_CONDUIT"]         = 0x45e17E350279a2f28243983053B634897BA03b64;
        addr["RWA004"]                          = 0x146b0abaB80a60Bfa3b4fDDb5056bBcFa4f1fec1;
        addr["MCD_JOIN_RWA004_A"]               = 0xa92D4082BabF785Ba02f9C419509B7d08f2ef271;
        addr["RWA004_A_URN"]                    = 0xf22C7F5A2AecE1E85263e3cec522BDCD3e392B59;
        addr["RWA004_A_INPUT_CONDUIT"]          = 0x303dFE04Be5731207c5213FbB54488B3aD9B9FE3;
        addr["RWA004_A_OUTPUT_CONDUIT"]         = 0x303dFE04Be5731207c5213FbB54488B3aD9B9FE3;
        addr["RWA005"]                          = 0xcB2A48D26970eE7193d66BAc6F1b3090f2E8f82B;
        addr["MCD_JOIN_RWA005_A"]               = 0x1233d0DBb55A4Bb41D711d4B584f8DDB15A2Ff88;
        addr["RWA005_A_URN"]                    = 0xdB9f0700EbBac596CCeF5b14D5e23664Db2A184f;
        addr["RWA005_A_INPUT_CONDUIT"]          = 0x17E5954Cdd3611Dd84e444F0ed555CC3a06cB319;
        addr["RWA005_A_OUTPUT_CONDUIT"]         = 0x17E5954Cdd3611Dd84e444F0ed555CC3a06cB319;
        addr["RWA006"]                          = 0x4E65F06574F1630B4fF756C898Fe02f276D53E86;
        addr["MCD_JOIN_RWA006_A"]               = 0x039B74bD0Adc35046B67E88509900D41b9D95430;
        addr["RWA006_A_URN"]                    = 0x6fa6F9C11f5F129f6ECA4B391D9d32038A9666cD;
        addr["RWA006_A_INPUT_CONDUIT"]          = 0x652A3B3b91459504A8D1d785B0c923A34D638218;
        addr["RWA006_A_OUTPUT_CONDUIT"]         = 0x652A3B3b91459504A8D1d785B0c923A34D638218;
    }
}
