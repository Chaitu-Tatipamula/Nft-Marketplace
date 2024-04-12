// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftMarketplace is IERC721Receiver,ReentrancyGuard,Ownable(msg.sender){
    

    struct NftToList{
        uint tokenId;
        address payable seller;
        address payable holder;
        uint price;
        bool isSold;
    }

    mapping (uint => NftToList) public ListOfNfts;

    address payable owner;
    uint listingFee = 0.001 ether;
    ERC721Enumerable nft;
    constructor(ERC721Enumerable _nft){
        owner = payable(msg.sender);
        
    }    

    function getNftLisstigs() public view returns(NftToList[] memory){
        uint totalsupply = nft.totalSupply();
        uint index =0;
        NftToList[] memory lists = new NftToList[](totalsupply);
        for(uint i=0;i<totalsupply;i++){
            if(ListOfNfts[i+1].holder == address(this)){
                uint currId = i+1;
                NftToList storage currentItem = ListOfNfts[currId];
                lists[currId] = currentItem;
                index ++;
            }
        }
        return lists;
    }

    function getListingFee() public view returns(uint){
        return listingFee;
    }

    function getPriceOfToken(uint tokenId) public view returns(uint){
        return ListOfNfts[tokenId].price;
    }

    function buy(uint tokenId) public payable nonReentrant{
        uint price = ListOfNfts[tokenId].price;
        require(msg.value>=price,"Send total amount to perfom buy action");
        ListOfNfts[tokenId].seller.transfer(msg.value);
        nft.transferFrom(address(this),msg.sender,tokenId);
        ListOfNfts[tokenId].isSold = true;
        delete ListOfNfts[tokenId];
    }
    event NftListed(
        uint indexed tokenId,
        address payable seller,
        address payable holder,
        uint price,
        bool isSold
        );

    function listForSale(uint tokenId,uint price)public payable nonReentrant{
        require(nft.ownerOf(tokenId)==msg.sender , "Owner does'nt match");
        require(ListOfNfts[tokenId].tokenId == 0,"This Nft exists in the list");
        require(price > 0, "Give valid price to list the token");
        require(msg.value == listingFee, "Transfer the listing fee of 0.001 to lis tyour token");
        ListOfNfts[tokenId] = NftToList(tokenId,payable(msg.sender),payable(address(this)),price,false);
        nft.transferFrom(msg.sender,address(this),tokenId);
        emit NftListed(tokenId,payable(msg.sender),payable(address(this)),price,false);
    }

    function revertListing(uint tokenId) public nonReentrant{
        require(ListOfNfts[tokenId].seller == msg.sender,"Not Authorized to perform this action");
        nft.transferFrom(address(this),msg.sender,tokenId);
        delete ListOfNfts[tokenId];
    }



    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4){

    }


    receive() external payable{}

    fallback() external payable{}
    
    function withdrawEther()  external onlyOwner{ 
        payable(owner).transfer(address(this).balance);

    }
    
}