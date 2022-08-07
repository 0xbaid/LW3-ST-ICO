//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is Ownable, ERC20 {
    uint256 public constant tokenPrice = 0.001 ether; // Price of one Crypto Dev token
    // ERC20 tokens have the smallest denomination of 10^(-18). This means, having a balance of (1)
    // Owning 1 full token is equivalent to owning (10^18)
    uint256 public constant tokensPerNft = 10 * 10**18;
    uint256 public constant maxTotalSupply = 10000 * 10**18;
    ICryptoDevs CryptoDevsNft; //NFT instance
    mapping(uint256 => bool) public tokenIdsClaimed; // Keep track of which tokenIds have been claimed

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        CryptoDevsNft = ICryptoDevs(_cryptoDevsContract); //NFT Contract
    }

    //  Mints `amount` number of CryptoDevTokens
    function mint(uint256 amount) public payable {
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "Insufficient Ethers");
        uint256 amountWithDecimals = amount * 10**18;
        //check for available tokens, totalSupply() is erc20 function
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Tokens not available."
        );
        _mint(msg.sender, amountWithDecimals);
    }

    //  Mints tokens based on the number of NFT's held by the sender
    function claim() public {
        address sender = msg.sender;
        uint256 balance = CryptoDevsNft.balanceOf(sender); // Get the number of CryptoDev NFT's held by a given sender address
        require(balance > 0, "You dont have any crypto dev NFTs");
        uint256 amount = 0; // amount keeps track of number of unclaimed tokenIds
        //extracting tokenIds of each nfts
        for (uint256 i = 0; i < balance; i++) {
            //tokenOfOwnerByIndex is erc720 function Returns a token ID owned by owner at a given index
            uint256 tokenId = CryptoDevsNft.tokenOfOwnerByIndex(sender, i);
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        require(amount > 0, "Already claimed all the tokens");
        _mint(sender, amount * tokensPerNft);
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}

// deployed: 0xe0c3Ba1B9d662eE59d5fEF1AA54C1C8d8BcA1e72
