// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
//Fund
//Withdraw
import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundme is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundme(address mostRecentlyDeployed) public {
        
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Fundme",
            block.chainid
        );
        vm.startBroadcast();
        fundFundme(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundme is Script {

    function withdrawFundme(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Fundme",
            block.chainid
        );
        vm.startBroadcast();
        withdrawFundme(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}