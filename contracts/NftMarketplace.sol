// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftMarketplace is IERC721Receiver,ReentrancyGuard,Ownable(msg.sender){


    struct NftToList{
        uint itemId;
        uint tokenId;
        address payable seller;
        address payable owner;
        uint price;
        bool isSold;
    }

    mapping (uint => NftToList) public ListOfNfts;

    address payable contractOwner;
    uint listingFee = 0.001 ether;
    ERC721Enumerable nft;

    constructor(ERC721Enumerable _nft){
        contractOwner = payable(msg.sender);
        nft = _nft;
    }
    uint private _itemIds = 0;    
    uint private _itemsSold = 0;    

    function getNftListigs() public view returns(NftToList[] memory){
        uint itemsCount = _itemIds;
        uint unsold = _itemIds - _itemsSold;
        uint totalsupply = nft.totalSupply();
        uint index =0;
        NftToList[] memory lists = new NftToList[](totalsupply);
        for(uint i=0;i<totalsupply;i++){
            if(ListOfNfts[i+1].owner == address(this)){
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

    function buy(uint itemId) public payable nonReentrant{
        uint price = ListOfNfts[itemId].price;
        uint tokenId = ListOfNfts[itemId].tokenId;
        require(msg.value>=price,"Send total amount to perfom buy action");
        ListOfNfts[itemId].seller.transfer(msg.value);
        payable(msg.sender).transfer(listingFee);
        nft.transferFrom(address(this),msg.sender,tokenId);
        ListOfNfts[itemId].isSold = true;
        _itemsSold++;
        delete ListOfNfts[tokenId];
        delete ListOfNfts[itemId];
    }
    event NftListed(
        uint indexed itemId,
        uint indexed tokenId,
        address payable seller,
        address payable owner,
        uint price,
        bool isSold
        );

    function listForSale(uint tokenId,uint price)public payable nonReentrant{
        require(nft.ownerOf(tokenId)==msg.sender , "Owner does'nt match");
        require(ListOfNfts[tokenId].tokenId == 0,"This Nft exists in the list");
        require(price > 0, "Give valid price to list the token");
        require(msg.value == listingFee, "Transfer the listing fee of 0.001 to lis tyour token");
        _itemIds++;
        uint itemId = _itemIds;
        ListOfNfts[tokenId] = NftToList(itemId,tokenId,payable(msg.sender),payable(address(this)),price,false);
        nft.transferFrom(msg.sender,address(this),tokenId);
        emit NftListed(itemId,tokenId,payable(msg.sender),payable(address(this)),price,false);
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
    ) external pure override returns (bytes4){
        require(from == address(0x0),"Cant send");
        return IERC721Receiver.onERC721Received.selector;
    }


    receive() external payable{}

    fallback() external payable{}
    
    function withdraw() public onlyOwner{
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool _sent, ) = _owner.call{ value : amount}("");
        require(_sent, "Failed to withdraw");
    }
    
}