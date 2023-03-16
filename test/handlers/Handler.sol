// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {CommonBase} from "@forge-std/Base.sol";
import {StdCheats} from "@forge-std/StdCheats.sol";
import {StdUtils} from "@forge-std/StdUtils.sol";

import {Dex, SwappableToken} from "../../src/Dex.sol";


contract Handler is CommonBase, StdCheats, StdUtils {

    address public actor;

    Dex public dex;

    constructor(Dex _dex, address _actor) {
        dex = _dex;
        actor = _actor;

        deal(address(this), 1 ether);
    }

    receive() external payable {}
}