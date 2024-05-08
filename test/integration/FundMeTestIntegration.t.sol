// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundme, WithdrawFundme} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundme;
    DeployFundMe deployFundme;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; //10000000
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundme = deploy.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUSerCanFundInteractions () public{
        FundFundme fundFundme = new FundFundme();
        fundFundme.fundFundme(address(fundme));

        WithdrawFundme withdrawFundme = new WithdrawFundme();
          withdrawFundme.withdrawFundme(address(fundme));
     
        assert(address(fundme).balance == 0);

    }
}
