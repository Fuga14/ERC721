// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IERC721Metadata.sol";
import "./IERC721Receiver.sol";
import "./Strings.sol";

contract ERC721 is IERC721Metadata, IERC721Receiver {
    using Strings for uint;
    string public name;
    string public symbol;

    mapping(address => uint) _balances;
    mapping(uint => address) _owners;
    mapping(uint => address) _tokenApprovals;
    mapping(address => mapping(address => bool)) _operatorApprovals; // can the operator manage all tokens of some address?

    modifier requireMinted(uint tokenId) {
        require(_exists(tokenId), "Token not minted!");
        _;
    }

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function _safeMint(address to, uint tokenId) internal virtual {
        _mint(to, tokenId);

        require(
            _checkOnERC721Received(msg.sender, to, tokenId),
            "Non erc721 receiver!"
        );
    }

    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "Address is not valid");
        require(!_exists(tokenId), "Token already minted");
        _owners[tokenId] = to;
        _balances[to]++;
    }

    function burn(uint tokenId) public virtual {
        require(_exists(tokenId), "Token is not minted!");
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "You are not an owner!"
        );
        address owner = ownerOf(tokenId);
        delete _tokenApprovals[tokenId];
        _balances[owner]--;
        delete _owners[tokenId];
    }

    function saveTransferFrom(address from, address to, uint tokenId) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Not an owner or aproved!"
        );

        _safeTransfer(from, to, tokenId);
        emit Transfer(from, to, tokenId);
    }

    function approve(address to, uint tokenId) public {
        address _owner = ownerOf(tokenId);
        require(
            _owner == msg.sender || isApprovedForAll(_owner, msg.sender),
            "You are not the owner of token"
        );
        require(to != _owner, "Cannot approve to self!");

        _tokenApprovals[tokenId] = to;

        emit Approval(_owner, to, tokenId);
    }

    function transferFrom(address from, address to, uint tokenId) external {
        // Check if sender has permission to send token
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "Not an owner or aproved!"
        );

        _transfer(from, to, tokenId);
    }

    function _isApprovedOrOwner(
        address spender,
        uint tokenId
    ) internal view returns (bool) {
        address owner = ownerOf(tokenId);

        require(
            spender == owner ||
                isApprovedForAll(owner, spender) ||
                getApproved(tokenId) == spender,
            "Not an owner or approved!"
        );
    }

    // Service functions
    /////////////////////////////
    function balanceOf(address owner) public view returns (uint) {
        require(owner != address(0), "Address not valid!");
        return _balances[owner];
    }

    function ownerOf(
        uint tokenId
    ) public view requireMinted(tokenId) returns (address) {
        return _owners[tokenId];
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view returns (bool) {
        return _operatorApprovals[operator][owner];
    }

    function getApproved(
        uint tokenId
    ) public view requireMinted(tokenId) returns (address) {
        return _tokenApprovals[tokenId];
    }

    function _exists(uint tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _safeTransfer(address from, address to, uint tokenId) internal {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId),
            "Non erc721 receiver!"
        );
    }

    function _transfer(address from, address to, uint tokenId) internal {
        require(
            ownerOf(tokenId) == from,
            "You are not the owner of the token!"
        );
        require(to != address(0), "Receiver is not valid address!");

        _beforTokenTransfer(from, to, tokenId);

        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint tokenId
    ) private returns (bool) {
        if (to.code.length > 0) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    bytes("")
                )
            returns (bytes4 ret) {
                ret == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    // if to is not use interface IERC721Receiver
                    // and has no function onERC721Received
                    revert("Non erc721 receiver!");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _baseURI() internal pure virtual returns (string memory) {
        return "";
    }

    function tokenURI(
        uint tokenId
    ) public view requireMinted(tokenId) returns (string memory) {
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function _beforTokenTransfer(
        address from,
        address to,
        uint tokenId
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint tokenId
    ) internal virtual {}
}
