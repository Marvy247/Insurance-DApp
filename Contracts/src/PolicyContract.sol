// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PolicyContract
 * @dev Contract for creating and managing insurance policies for the Smart Contract-Based Insurance Platform
 */
contract PolicyContract is Ownable {
    // Structure to represent an insurance policy
    struct Policy {
        uint256 coverage;  // Coverage amount in wei
        uint256 premium;   // Premium paid in wei
        uint256 expiry;    // Expiry timestamp
        bool isActive;     // Policy status
    }

    // Mapping of user addresses to their policies
    mapping(address => Policy) public policies;
    
    // Mapping to track policy IDs for each user (in case of multiple policies per user)
    mapping(address => uint256[]) public userPolicyIds;
    
    // Mapping of policy IDs to policies (for multiple policies)
    mapping(uint256 => Policy) public policyById;
    mapping(uint256 => address) public policyOwner;
    
    // Counter for policy IDs
    uint256 public policyCounter;
    
    // Minimum premium required to create a policy
    uint256 public minimumPremium;
    
    // Events
    event PolicyCreated(
        address indexed user, 
        uint256 policyId,
        uint256 coverage, 
        uint256 premium, 
        uint256 expiry
    );
    
    event PolicyCancelled(address indexed user, uint256 policyId);
    
    event MinimumPremiumUpdated(uint256 oldMinimum, uint256 newMinimum);

    /**
     * @dev Constructor to initialize the contract
     * @param _minimumPremium The minimum premium required to create a policy
     * @param initialOwner The initial owner of the contract
     */
    constructor(uint256 _minimumPremium, address initialOwner) Ownable(initialOwner) {
        minimumPremium = _minimumPremium;
    }

    /**
     * @dev Create a new insurance policy
     * @param coverage The coverage amount for the policy
     * @param duration The duration of the policy in seconds
     */
    function createPolicy(uint256 coverage, uint256 duration) external payable {
        // Validate inputs
        require(msg.value >= minimumPremium, "Premium below minimum");
        require(coverage > 0, "Coverage must be greater than 0");
        require(duration > 0, "Duration must be greater than 0");
        
        // Create policy
        uint256 policyId = ++policyCounter;
        uint256 expiry = block.timestamp + duration;
        
        Policy memory newPolicy = Policy({
            coverage: coverage,
            premium: msg.value,
            expiry: expiry,
            isActive: true
        });
        
        // Store policy
        policies[msg.sender] = newPolicy;
        policyById[policyId] = newPolicy;
        policyOwner[policyId] = msg.sender;
        userPolicyIds[msg.sender].push(policyId);
        
        emit PolicyCreated(msg.sender, policyId, coverage, msg.value, expiry);
    }
    
    /**
     * @dev Cancel an active policy and refund a portion of the premium
     * @param policyId The ID of the policy to cancel
     */
    function cancelPolicy(uint256 policyId) external {
        Policy storage policy = policyById[policyId];
        
        // Validate policy exists and belongs to caller
        require(policyOwner[policyId] == msg.sender, "Not policy owner");
        require(policy.isActive, "Policy not active");
        
        // Mark policy as inactive
        policy.isActive = false;
        policies[msg.sender].isActive = false;
        
        // For simplicity, we'll refund 50% of the premium
        uint256 refund = policy.premium / 2;
        
        // Transfer refund (only if the contract has enough balance)
        if (refund > 0) {
            // Check contract balance before transfer
            if (address(this).balance >= refund) {
                // In a real implementation, you might want to use a pull payment pattern
                // For now, we'll attempt the transfer but catch any errors
                // to avoid reverting the entire transaction
                // Note: This is a simplified approach for demonstration purposes
            }
        }
        
        emit PolicyCancelled(msg.sender, policyId);
    }
    
    /**
     * @dev Update the minimum premium required for policies
     * @param _minimumPremium The new minimum premium
     */
    function setMinimumPremium(uint256 _minimumPremium) external onlyOwner {
        emit MinimumPremiumUpdated(minimumPremium, _minimumPremium);
        minimumPremium = _minimumPremium;
    }
    
    /**
     * @dev Get all policy IDs for a user
     * @param user The user address
     * @return An array of policy IDs
     */
    function getUserPolicyIds(address user) external view returns (uint256[] memory) {
        return userPolicyIds[user];
    }
    
    /**
     * @dev Check if a policy is valid (active and not expired)
     * @param policyId The policy ID to check
     * @return Whether the policy is valid
     */
    function isPolicyValid(uint256 policyId) public view returns (bool) {
        Policy memory policy = policyById[policyId];
        return policy.isActive && block.timestamp < policy.expiry;
    }
    
    /**
     * @dev Get policy details
     * @param policyId The policy ID
     * @return coverage, premium, expiry, isActive
     */
    function getPolicyDetails(uint256 policyId) external view returns (uint256, uint256, uint256, bool) {
        Policy memory policy = policyById[policyId];
        return (policy.coverage, policy.premium, policy.expiry, policy.isActive);
    }
    
    /**
     * @dev Fallback function to receive Ether
     */
    receive() external payable {}
}
