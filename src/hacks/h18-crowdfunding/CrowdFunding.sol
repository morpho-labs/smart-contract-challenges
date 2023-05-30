// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev A contract for managing crowdfunding projects.
contract Crowdfunding {
    struct Project {
        address creator;
        uint256 deadline;
        uint256 targetAmount;
        uint256 totalAmountRaised;
        bool withdrawn;
        mapping(address => uint256) contributions;
    }

    Project[] public projects;

    /// @dev Creates a new crowdfunding project.
    ///      The project creator specifies the deadline and target amount for the project.
    ///      The caller must be able to receive funds, otherwise, the funded amount will be lost.
    /// @param deadline The deadline for the project.
    /// @param targetAmount The target amount of funds to be raised for the project.
    /// @return projectIndex The index of the newly created project in the projects array.
    function createProject(uint256 deadline, uint256 targetAmount) external returns (uint256 projectIndex) {
        require(block.timestamp < deadline, "Deadline must be in the future");

        projectIndex = projects.length;
        projects.push();

        projects[projectIndex].creator = msg.sender;
        projects[projectIndex].deadline = deadline;
        projects[projectIndex].targetAmount = targetAmount;
    }

    /// @dev Contributes an amount of funds to the specified project.
    /// @param projectIndex The index of the project in the projects array.
    function contribute(uint256 projectIndex) external payable {
        Project storage project = projects[projectIndex];

        require(block.timestamp < project.deadline, "Deadline has passed");

        project.contributions[msg.sender] += msg.value;
        project.totalAmountRaised += msg.value;
    }

    /// @dev Withdraws funds from a successfully funded project.
    ///      The project creator can withdraw the funds raised if the target amount is reached before the deadline.
    ///      The caller must be able to receive funds, otherwise, the contributed amount will be lost.
    /// @param projectIndex The index of the project in the projects array.
    function withdrawFunds(uint256 projectIndex) external {
        Project storage project = projects[projectIndex];

        require(block.timestamp >= project.deadline, "Deadline has not passed");
        require(msg.sender == project.creator, "Only the project creator can withdraw funds");
        require(project.totalAmountRaised >= project.targetAmount, "Target amount not reached");
        require(!project.withdrawn, "Funds already withdrawn");

        project.withdrawn = true;
        (bool success,) = msg.sender.call{value: project.totalAmountRaised}("");
        require(success, "Transfer failed");
    }

    /// @dev Withdraws contributed funds if the project is not successfully funded.
    ///      Contributors can withdraw their contributions if the target amount is not reached before the deadline.
    /// @param projectIndex The index of the project in the projects array.
    function withdrawContribution(uint256 projectIndex) external {
        Project storage project = projects[projectIndex];

        require(block.timestamp >= project.deadline, "Deadline has not passed");
        require(project.totalAmountRaised < project.targetAmount, "Target amount reached");

        uint256 contribution = project.contributions[msg.sender];
        project.contributions[msg.sender] = 0;

        (bool success,) = msg.sender.call{value: contribution}("");
        require(success, "Transfer failed");
    }

    /// @dev Performs a series of transactions in a single call.
    /// @param transactions The array of transactions to be executed.
    /// @return results The results of each transaction in the same order as the input transactions.
    function batchTransactions(bytes[] calldata transactions) external payable returns (bytes[] memory results) {
        results = new bytes[](transactions.length);

        bool success;
        for (uint256 i = 0; i < transactions.length; i++) {
            (success, results[i]) = address(this).delegatecall(transactions[i]);
            require(success, "Delegatecall failed");
        }
    }
}
