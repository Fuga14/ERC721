// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IERC721 {
    event Transfer(
        address indexed from,
        address indexed to,
        uint indexed tokenId
    );

    // to give permission for someone to sell my NFT
    event Approval(
        address indexed owner,
        address indexed approved,
        uint indexed tokenId
    );

    // to give access for someone to all my NFT
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    // Amount of nft's on address
    function balanceOf(address owner) external view returns (uint);

    // Who is the owner of token
    function ownerOf(uint tokenId) external view returns (address);

    function saveTransferFrom(address from, address to, uint tokenId) external;

    // function saveTransferFrom(
    //     address from,
    //     address to,
    //     uint tokenId,
    //     bytes calldata data
    // ) external;

    function transferFrom(address from, address to, uint tokenId) external;

    // Give permission for someone to have access for NFT
    function approve(address to, uint tokenId) external;

    // Give permission for someone to all NFT
    function setApprovalForAll(address operator, bool approved) external;

    // Who has access to token
    function getApproved(uint tokenId) external view returns (address);

    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}
