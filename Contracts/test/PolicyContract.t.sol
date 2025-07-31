// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PolicyContract.sol";

contract PolicyContractTest is Test {
    PolicyContract public policyContract;
    
    uint256 public constant MINIMUM_PREMIUM = 0.01 ether;
    uint256 public constant COVERAGE_AMOUNT = 1 ether;
    uint256 public constant POLICY_DURATION = 30 days;
    
    address public owner = address(this);
    address public user1 = address(0x1111111111111111111111111111111111111111);
    address public user2 = address(0x2222222222222222222222222222222222222222);

    function setUp() public {
        // Deploy the PolicyContract with owner as the initial owner
        policyContract = new PolicyContract(MINIMUM_PREMIUM, owner);
    }

    function testConstructor() public view {
        assertEq(policyContract.minimumPremium(), MINIMUM_PREMIUM);
        assertEq(policyContract.owner(), owner);
    }

    function testSetMinimumPremium() public {
        uint256 newMinimum = 0.02 ether;
        
        // Only owner should be able to set minimum premium
        vm.prank(owner);
        policyContract.setMinimumPremium(newMinimum);
        
        assertEq(policyContract.minimumPremium(), newMinimum);
    }

    function testSetMinimumPremiumNonOwner() public {
        uint256 newMinimum = 0.02 ether;
        
        // Non-owner should not be able to set minimum premium
        vm.prank(user1);
        vm.expectRevert(); // Newer OpenZeppelin uses a custom error
        policyContract.setMinimumPremium(newMinimum);
    }

    function testCreatePolicy() public {
        // User creates a policy with sufficient premium
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        uint256 premium = 0.02 ether;
        policyContract.createPolicy{value: premium}(COVERAGE_AMOUNT, POLICY_DURATION);
        
        // Check that policy was created
        (uint256 coverage, uint256 policyPremium, uint256 expiry, bool isActive) = policyContract.policies(user1);
        
        assertEq(coverage, COVERAGE_AMOUNT);
        assertEq(policyPremium, premium);
        assertGt(expiry, block.timestamp);
        assertTrue(isActive);
        
        // Check policy counter
        assertEq(policyContract.policyCounter(), 1);
        
        // Check user policy IDs
        uint256[] memory userPolicyIds = policyContract.getUserPolicyIds(user1);
        assertEq(userPolicyIds.length, 1);
        assertEq(userPolicyIds[0], 1);
    }

    function testCreatePolicyInsufficientPremium() public {
        // User tries to create a policy with insufficient premium
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        uint256 premium = 0.005 ether; // Less than minimum
        
        vm.expectRevert("Premium below minimum");
        policyContract.createPolicy{value: premium}(COVERAGE_AMOUNT, POLICY_DURATION);
    }

    function testCreatePolicyZeroCoverage() public {
        // User tries to create a policy with zero coverage
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        uint256 premium = 0.02 ether;
        
        vm.expectRevert("Coverage must be greater than 0");
        policyContract.createPolicy{value: premium}(0, POLICY_DURATION);
    }

    function testCreatePolicyZeroDuration() public {
        // User tries to create a policy with zero duration
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        uint256 premium = 0.02 ether;
        
        vm.expectRevert("Duration must be greater than 0");
        policyContract.createPolicy{value: premium}(COVERAGE_AMOUNT, 0);
    }

    function testGetPolicyDetails() public {
        // User creates a policy
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        uint256 premium = 0.02 ether;
        policyContract.createPolicy{value: premium}(COVERAGE_AMOUNT, POLICY_DURATION);
        
        // Get policy details
        (uint256 coverage, uint256 policyPremium, uint256 expiry, bool isActive) = policyContract.getPolicyDetails(1);
        
        assertEq(coverage, COVERAGE_AMOUNT);
        assertEq(policyPremium, premium);
        assertGt(expiry, block.timestamp);
        assertTrue(isActive);
    }

    function testIsPolicyValid() public {
        // User creates a policy
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        uint256 premium = 0.02 ether;
        policyContract.createPolicy{value: premium}(COVERAGE_AMOUNT, POLICY_DURATION);
        
        // Policy should be valid
        assertTrue(policyContract.isPolicyValid(1));
    }

    function testCancelPolicy() public {
        // User creates a policy
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        uint256 premium = 0.02 ether;
        policyContract.createPolicy{value: premium}(COVERAGE_AMOUNT, POLICY_DURATION);
        
        // Check contract balance after policy creation
        assertEq(address(policyContract).balance, premium);
        
        // Check that user has no pending withdrawals before cancellation
        assertEq(policyContract.getPendingWithdrawal(user1), 0);
        
        // User cancels policy
        vm.prank(user1);
        policyContract.cancelPolicy(1);
        
        // Check that policy is no longer active
        (, , , bool isActive) = policyContract.policies(user1);
        assertFalse(isActive);
        
        // Check that 50% of premium is recorded as pending withdrawal
        uint256 expectedRefund = premium / 2;
        assertEq(policyContract.getPendingWithdrawal(user1), expectedRefund);
        
        // Check that the PolicyCancelled event was emitted
     }
     
    function testWithdraw() public {
        // User creates a policy
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        uint256 premium = 0.02 ether;
        policyContract.createPolicy{value: premium}(COVERAGE_AMOUNT, POLICY_DURATION);
        
        // User cancels policy
        vm.prank(user1);
        policyContract.cancelPolicy(1);
        
        // Check that 50% of premium is recorded as pending withdrawal
        uint256 expectedRefund = premium / 2;
        assertEq(policyContract.getPendingWithdrawal(user1), expectedRefund);
        
        // User withdraws funds
        vm.prank(user1);
        policyContract.withdraw();
        
        // Check that pending withdrawal is now zero
        assertEq(policyContract.getPendingWithdrawal(user1), 0);
        
        // Check that contract balance decreased by the refund amount
        assertEq(address(policyContract).balance, premium - expectedRefund);
    }
    
    function testWithdrawNoPendingFunds() public {
        // User with no pending funds tries to withdraw
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        // Expect revert when trying to withdraw with no pending funds
        vm.expectRevert("No pending withdrawals");
        policyContract.withdraw();
    }
    
    function testMultiplePoliciesAndWithdrawals() public {
        // User creates first policy
        vm.deal(user1, 2 ether);
        vm.prank(user1);
        policyContract.createPolicy{value: 0.02 ether}(COVERAGE_AMOUNT, POLICY_DURATION);
        
        // User creates second policy
        vm.prank(user1);
        policyContract.createPolicy{value: 0.03 ether}(2 * COVERAGE_AMOUNT, 2 * POLICY_DURATION);
        
        // User cancels first policy
        vm.prank(user1);
        policyContract.cancelPolicy(1);
        
        // User cancels second policy
        vm.prank(user1);
        policyContract.cancelPolicy(2);
        
        // Check that pending withdrawal is sum of both refunds
        uint256 expectedRefund = (0.02 ether / 2) + (0.03 ether / 2);
        assertEq(policyContract.getPendingWithdrawal(user1), expectedRefund);
        
        // Check contract balance
        assertEq(address(policyContract).balance, 0.05 ether);
        
        // User withdraws funds
        vm.prank(user1);
        policyContract.withdraw();
        
        // Check that pending withdrawal is now zero
        assertEq(policyContract.getPendingWithdrawal(user1), 0);
        
        // Check that contract balance decreased by the refund amount
        assertEq(address(policyContract).balance, 0.05 ether - expectedRefund);
    }

    function testCancelPolicyNotOwner() public {
        // User creates a policy
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        uint256 premium = 0.02 ether;
        policyContract.createPolicy{value: premium}(COVERAGE_AMOUNT, POLICY_DURATION);
        
        // Another user tries to cancel the policy
        vm.prank(user2);
        vm.expectRevert("Not policy owner");
        policyContract.cancelPolicy(1);
    }

    function testCancelPolicyNotActive() public {
        // User creates a policy
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        
        uint256 premium = 0.02 ether;
        policyContract.createPolicy{value: premium}(COVERAGE_AMOUNT, POLICY_DURATION);
        
        // User cancels policy
        vm.prank(user1);
        policyContract.cancelPolicy(1);
        
        // Try to cancel again
        vm.prank(user1);
        vm.expectRevert("Policy not active");
        policyContract.cancelPolicy(1);
    }

    function testMultiplePolicies() public {
        // User1 creates first policy
        vm.deal(user1, 2 ether);
        vm.prank(user1);
        policyContract.createPolicy{value: 0.02 ether}(COVERAGE_AMOUNT, POLICY_DURATION);
        
        // User1 creates second policy
        vm.prank(user1);
        policyContract.createPolicy{value: 0.03 ether}(2 * COVERAGE_AMOUNT, 2 * POLICY_DURATION);
        
        // Check policy counter
        assertEq(policyContract.policyCounter(), 2);
        
        // Check user policy IDs
        uint256[] memory userPolicyIds = policyContract.getUserPolicyIds(user1);
        assertEq(userPolicyIds.length, 2);
        assertEq(userPolicyIds[0], 1);
        assertEq(userPolicyIds[1], 2);
    }

    receive() external payable {}
}
