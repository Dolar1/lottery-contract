// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Raffle} from "./../../src/Raffle.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "./../../script/DeployRaffle.s.sol";
import {HelperConfig} from "./../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    /*  EVENTS   */
    event EnteredRaffle(address indexed player);

    Raffle raffle;
    HelperConfig helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callBackGasLimit;

    address public PLAYER = makeAddr("player");
    uint256 internal STARTING_USER_BALANCE = 10 ether;

    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.run();

        (
            entranceFee,
            interval,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callBackGasLimit
        ) = helperConfig.activeNetworkConfig();
        vm.deal(PLAYER, STARTING_USER_BALANCE);
    }

    function testRaffleIntializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWhenYouDontPayEnough() public {
        //  ARRANGE
        vm.prank(PLAYER);
        //  ACT & ASSERT
        vm.expectRevert(Raffle.Raffle__NotEnoughEthSent.selector); // using function selector here
        raffle.enterRaffle();
        //  ASSERT
        // ....
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        //  ARRANGE
        vm.prank(PLAYER);
        //  ACT
        raffle.enterRaffle{value: entranceFee}();
        //  ASSERT
        address playerRecorded = raffle.getPlayer(0);
        assert(playerRecorded == PLAYER);
    }

    function testEmitsEventOnEntrance() public {
        //  ARRANGE
        vm.prank(PLAYER);
        //  ACT
        vm.expectEmit(true, false, false, false, address(raffle));
        emit EnteredRaffle(PLAYER);
        raffle.enterRaffle{value: entranceFee}();
    }
}
