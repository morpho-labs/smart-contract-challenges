// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Library, Shelf, Book, ISearchEngine} from "./Common.sol";

contract SearchEngine is ISearchEngine {
    function search(Library lib, bytes32 author, bytes32 name) external view returns (bytes32) {
        return lib.shelves(author).books(name)._content();
    }
}
