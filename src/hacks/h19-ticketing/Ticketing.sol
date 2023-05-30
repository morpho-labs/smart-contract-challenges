// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev This contract enables users to buy and sell tokens using the x * y = k formula,
///      where tokens are used to purchase tickets.
///      The price of a ticket is the equivalent of `ticketPriceInEth` Ether in tokens.
///      The objective for users is to purchase tickets, which can be used as an entry pass for an event or to gain access to a service.
contract Ticketing {
    address public immutable owner;
    uint256 public immutable ticketPriceInEth;
    uint256 public immutable virtualReserveEth;
    uint256 public immutable k;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public tickets;

    /// @dev Assumes that the values of the different parameters are big enough to minimize the impact of rounding errors.
    /// @param newTicketPriceInEth The price of a ticket in Ether.
    /// @param newVirtualReserveEth The virtual reserve of Ether in the contract.
    /// @param totalSupply The total supply of tokens.
    constructor(uint256 newTicketPriceInEth, uint256 newVirtualReserveEth, uint256 totalSupply) {
        require(newVirtualReserveEth > newTicketPriceInEth, "Virtual reserve must be greater than ticket price");

        owner = msg.sender;
        ticketPriceInEth = newTicketPriceInEth;
        virtualReserveEth = newVirtualReserveEth;
        k = newVirtualReserveEth * totalSupply;
        balances[address(this)] = totalSupply;
    }

    /// @notice Allows users to buy tokens by sending Ether.
    /// @dev The amount out is determined using the formula: (x + dx) * (y - dy) = k.
    /// @param amountOutMin The minimum amount of tokens expected to be received.
    /// @return amountOut The amount of tokens received.
    function buyTokens(uint256 amountOutMin) external payable returns (uint256 amountOut) {
        amountOut = _reserveToken() - k / (_reserveEth() + msg.value);
        require(amountOut >= amountOutMin, "Insufficient tokens received");
        balances[address(this)] -= amountOut;
        balances[msg.sender] += amountOut;
    }

    /// @notice Allows users to sell tokens in exchange for Ether.
    /// @dev The amount out is determined using the formula: (x - dx) * (y + dy) = k.
    /// @param amountIn The amount of tokens to sell.
    /// @param amountOutMin The minimum amount of Ether expected to be received.
    /// @return amountOut The amount of Ether received.
    function sellToken(uint256 amountIn, uint256 amountOutMin) external returns (uint256 amountOut) {
        amountOut = _reserveEth() - k / (_reserveToken() + amountIn);
        require(amountOut >= amountOutMin, "Insufficient Ether received");
        balances[msg.sender] -= amountIn;
        balances[address(this)] += amountIn;

        (bool success,) = msg.sender.call{value: amountOut}("");
        require(success, "Transfer failed");
    }

    /// @notice Gets the effective Ether balance available for token swaps.
    /// @dev This function calculates the effective Ether balance by subtracting the value sent in the current transaction and adding the virtual reserve.
    /// @return The effective Ether balance available for token swaps.
    function _reserveEth() internal view returns (uint256) {
        return address(this).balance - msg.value + virtualReserveEth;
    }

    /// @notice Gets the effective token balance available for token swaps.
    /// @return The effective token balance available for token swaps.
    function _reserveToken() internal view returns (uint256) {
        return balances[address(this)];
    }

    /// @notice Gets the current ticket price.
    /// @dev The price of a ticket is determined by how much tokens must be sold to obtain `ticketPriceInEth` Ether.
    ///      Like in the function `sellToken`, the following formula is used: (x - dx) * (y + dy) = k.
    /// @return The current ticket price in Ether.
    function ticketPrice() public view returns (uint256) {
        return k / (_reserveEth() - ticketPriceInEth) - _reserveToken();
    }

    /// @notice Allows users to buy a ticket.
    /// @param maxPrice The maximum price the buyer is willing to pay for a ticket.
    function buyTicket(uint256 maxPrice) external {
        uint256 price = ticketPrice();
        require(price <= maxPrice, "Ticket price exceeds the maximum limit");
        balances[msg.sender] -= price;
        balances[owner] += price;
        tickets[msg.sender]++;
    }
}
