// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Library {
    mapping(bytes32 author => Shelf) public shelves;

    function newBook(bytes32 author, bytes32 name, bytes32 content) external returns (Book) {
        if (address(shelves[author]) == address(0)) {
            shelves[author] = new Shelf{salt: author}();
        }
        return shelves[author].newBook(name, content);
    }
}

contract Shelf {
    mapping(bytes32 name => Book) public books;

    function newBook(bytes32 name, bytes32 content) external returns (Book) {
        require(address(books[name]) == address(0));
        return books[name] = new Book{salt: name}(content);
    }
}

contract Book {
    bytes32 public immutable _content;

    constructor(bytes32 content) {
        _content = content;
    }
}

interface ISearchEngine {
    function search(Library, bytes32, bytes32) external view returns (bytes32 content);
}
