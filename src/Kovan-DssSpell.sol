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

contract DssSpellAction is DssAction {

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/TODO -q -O - 2>/dev/null)"
    string public constant override description = "Optimism test spell casting + housekeeping";

    // Vote delegate proxy factory
    address constant VOTE_DELEGATE_PROXY_FACTORY = 0xB10cf58E08b94480fCb81d341A63295eBb2062C2;

    function actions() public override {

        // Update early RWA tokens names in ilk registry
        IlkRegistryAbstract ILK_REGISTRY = IlkRegistryAbstract(DssExecLib.reg());

        address join;
        address gem;
        uint8   dec;
        uint96  class;
        address pip;
        address xlip;
        string memory name;
        string memory symbol;

        (, join, gem, dec, class, pip, xlip, name, symbol) = ILK_REGISTRY.ilkData("RWA001-A");
        ILK_REGISTRY.put("RWA001-A", join, gem, dec, class, pip, xlip, "RWA001-A: 6S Capital", symbol);

        (, join, gem, dec, class, pip, xlip, name, symbol) = ILK_REGISTRY.ilkData("RWA002-A");
        ILK_REGISTRY.put("RWA002-A", join, gem, dec, class, pip, xlip, "RWA002-A: Centrifuge: New Silver Series 2 DROP", symbol);

        // Add vote delegate factory to changelog
        DssExecLib.setChangelogAddress("VOTE_DELEGATE_PROXY_FACTORY", VOTE_DELEGATE_PROXY_FACTORY);

        // Bump version, assuming 1.9.2 version passes
        DssExecLib.setChangelogVersion("1.9.3");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
