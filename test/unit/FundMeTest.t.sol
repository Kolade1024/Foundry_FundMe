// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    DeployFundMe deployFundme;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; //10000000
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        deployFundme = new DeployFundMe();
        fundme = deployFundme.run();
        vm.deal(USER, STARTING_BALANCE); //Helps to send funds to the new address we instantiated vm.prank(USER)
    }

    function testcheckOwner() public view {
        console.log(fundme.getOwner());
        console.log(msg.sender);
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testMinUsd() public view {
        console.log(fundme.MINIMUM_USD());
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testVersion() public view {
        uint256 version = fundme.getVersion();
        console.log(version);
        assertEq(version, 4);
    }

    function testIfFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); //Hey,the next line should revert
        fundme.fund{value: 2e15}();
    }

    function testFundUpdatesFundedDataStructures() public {
        vm.prank(USER); //This implies that the next transacion will be sent by address USER
        fundme.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFunderToArrayOfFunders() public {
        vm.prank(USER); //This implies that the next transacion will be sent by the user address
        fundme.fund{value: SEND_VALUE}();
        address funderAddress = fundme.getFunder(0);
        assertEq(funderAddress, USER);
    }

    //Solidity best Practices : make a funded modifier so you don't have to rewrite code always
    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    function testIfOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundme.withdraw();
    }

    function testWithdrawalWithASingleFunder() public funded {
        //Arrange
        uint256 startingOwnerBalance = fundme.getOwner().balance; //This is to compare the total amount deposited to the
        uint256 startingFundmeBalance = address(fundme).balance;
        //balance of the owner address that only has the access to withdrawal

        //Act
        //This where the withdrawal ACTION is tested.
        vm.prank(fundme.getOwner()); //Only the owner has access to withdrawal
        fundme.withdraw();

        //Assert
        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundmeBalance = address(fundme).balance;
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundmeBalance
        );
        assertEq(endingFundmeBalance, 0);
    }

    function testFromMultipleFundersCheaper() public funded {
        uint160 numbersOfFunders = 10; //if we're going to be using numbers to generate addresses those numbers have to be uin160 defined
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numbersOfFunders; i++) {
            ///prank(newAddress)
            //vm.deal(account, newBalance);

            //instead we can use hoax(someaddress, value) to combine the two foundry cheatcodes prank and deal

            hoax(address(i), SEND_VALUE);

            //fundme.fund()
            fundme.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundmeBalance = address(fundme).balance;

        vm.startPrank(fundme.getOwner());
        fundme.cheaperWithdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundmeBalance = address(fundme).balance;
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundmeBalance
        );
        assertEq(endingFundmeBalance, 0);
    }

    function testFromMultipleFunders() public funded {
        uint160 numbersOfFunders = 10; //if we're going to be using numbers to generate addresses those numbers have to be uin160 defined
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numbersOfFunders; i++) {
            ///prank(newAddress)
            //vm.deal(account, newBalance);

            //instead we can use hoax(someaddress, value) to combine the two foundry cheatcodes prank and deal

            hoax(address(i), SEND_VALUE);

            //fundme.fund()
            fundme.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundme.getOwner().balance;
        uint256 startingFundmeBalance = address(fundme).balance;

        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingFundmeBalance = address(fundme).balance;
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundmeBalance
        );
        assertEq(endingFundmeBalance, 0);
    }
}
