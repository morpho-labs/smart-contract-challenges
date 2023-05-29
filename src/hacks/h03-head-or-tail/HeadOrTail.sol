// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev One party chooses Head or Tail and sends 1 ETH.
///      The next party sends 1 ETH and tries to guess what the first party chose.
///      If they succeed, they get 2 ETH, else the first party gets 2 ETH.
contract HeadOrTail {
    bool public chosen; // True if the choice has been made.
    bool public lastChoiceIsHead; // True if the choice is head.
    address public lastParty; // The last party who chose.

    /// @dev Must be sent 1 ETH.
    ///      Choose Head or Tail to be guessed by the other player.
    /// @param chooseHead True if Head was chosen, false if Tail was chosen.
    function choose(bool chooseHead) external payable {
        require(!chosen, "Choice already made");
        require(msg.value == 1 ether, "Incorrect payment amount");

        chosen = true;
        lastChoiceIsHead = chooseHead;
        lastParty = msg.sender;
    }

    /// @dev Guesses the choice of the first party and resolves the Head or Tail Game.
    /// @param guessHead The guess (Head or Tail) of the opposite party.
    function guess(bool guessHead) external payable {
        require(chosen, "Choice not made yet");
        require(msg.value == 1 ether, "Incorrect payment amount");

        (bool success,) = (guessHead == lastChoiceIsHead ? msg.sender : lastParty).call{value: 2 ether}("");
        require(success, "Transfer failed");
        chosen = false;
    }
}
