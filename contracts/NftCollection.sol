// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NftColletction is ERC721Enumerable,Ownable(msg.sender){

    using Strings for uint256;
    bool public paused = false;
    string public baseURI;
    string  public _baseExtension = ".json";
    uint public maxMintAmount = 5;
    uint public maxSupply = 1000;
    uint public cost = 0.05 ether;

    constructor() ERC721("DevNft","DNFT"){}

    function _baseURI() internal view virtual override returns (string memory) {
        return "ipfs://QmPUgpTYTzGM5MZezUfBmbx2h3PmPFSJsjivC3drALcRKe/";
    }


    function mint(address _to, uint256 _mintAmount) public payable {
            require(!paused);
            require(_mintAmount > 0);
            require(_mintAmount <= maxMintAmount);
            uint256 supply = totalSupply();
            require(supply + _mintAmount <= maxSupply);
            
            if (msg.sender != owner()) {
            require(msg.value == cost * _mintAmount, "Need to send ether!");
            }
            
            for (uint256 i = 1; i <= _mintAmount; i++) {
                _safeMint(_to, supply + i);
            }
        }

        function tokensOwned(address _owner)
        public
        view
        returns (uint256[] memory)
        {
            uint256 ownerTokenCount = balanceOf(_owner);
            uint256[] memory tokenIds = new uint256[](ownerTokenCount);
            for (uint256 i; i < ownerTokenCount; i++) {
                tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
            }
            return tokenIds;
        }

         function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory) {
            require(
                ownerOf(tokenId) != address(0),
                "ERC721Metadata: token doesnot exist"
                );
                
                string memory currentBaseURI = _baseURI();
                return
                bytes(currentBaseURI).length > 0 
                ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), _baseExtension))
                : "";
        }

         function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner() {
            maxMintAmount = _newmaxMintAmount;
        }
        
        function setBaseURI(string memory _newBaseURI) public onlyOwner() {
            baseURI = _newBaseURI;
        }
        
        function setBaseExtension(string memory _newBaseExtension) public onlyOwner() {
            _baseExtension = _newBaseExtension;
        }
        
        function pause(bool _state) public onlyOwner() {
            paused = _state;
        }
        
        function withdraw() public payable onlyOwner() {
            require(payable(msg.sender).send(address(this).balance));
        }




}