// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;
import {Script} from "forge-std/Script.sol";
import {FundMe} from "src/FundMe.sol";
//import HelperConfig so you can use it.
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        //Anything before start broadcast will not be sent as a new transaction it will only be simulated
        HelperConfig helperConfig = new HelperConfig(); //We're creating this so we don't have to spend gas deploying this on a new chain.
        // this is a struct , so its meant to be like this (address ethUsdPriceFeed), 
        //provided their are other variables in the struct(address ethUsdPriceFeed, , )
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        //Anything after start will be sent as a real transaction
        FundMe fundme = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundme;
    }
}
