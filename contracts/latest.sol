// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string public baseURI;
    string public baseExtension = ".json";
    uint256 public cost = 0.01 ether;
    uint256 public maxSupply = 5;
    uint256 public maxmintAmount=1;
    bool public paused = false;
    bool public winner_revealed = false;
    bool public reveal = false;
    string public notRevealedUri;
    mapping(address => bool) public whitelisted;
    mapping(uint256 => address) public winnerAddress;
    bool public PresaleMint = true;
    address winner;
    address[] public list;
    uint256 public minted =0;
    address[] public winners;



    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        setBaseURI("https://gateway.pinata.cloud/ipfs/Qmbtde8Uusj2u5MFfXpQf35Pm9z3UtGixPnh7XmuuDdgei/");
        setNotRevealedURI("https://gateway.pinata.cloud/ipfs/QmSdSs8RCABmEQ4hsrHEtUfvinJen8ajKy32GH3RehjNUw/watch_latest.json");
        bulkMint();
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }


    function bulkMint() onlyOwner public{
      for(uint i=0; i < maxSupply ; i++){
        _safeMint(msg.sender,i+1);
      }      
    }


    // public
    function mint() public payable {
        require(!paused);     
        require(minted < maxSupply,"Nfts are sold out");
        require(balanceOf(msg.sender) < maxmintAmount ,"Mint limit reached");
        incrementCount();
        if (msg.sender != owner()) {
            if(msg.value > 0){
            require(msg.value >= cost, "insufficient funds");
            }
            if (PresaleMint == true) {
                require(whitelisted[msg.sender], "Youre not whitelisted");
            }
         _transfer(owner(),msg.sender,minted);
         winnerAddress[minted] =msg.sender;
        }
    }

    function incrementCount() public {
       minted +=1;
    }
    


    function walletOfOwner(address _owner)
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

    uint256[] winnerTokens = [1,3,5];
    bool repeat = true;

    function checkWinnerTokenId (uint _tokenId) public view  returns  (bool){
        for (uint256 i = 0; i < 3; i++){
            if (_tokenId == winnerTokens[i]){
                return true;
            }
        } 
        return false;
   } 

   function fetchWinners() public returns(address[] memory){
      for(uint256 i=0;i<3;i++){
        // winners[i] = winnerAddress[winnerTokens[i]];
        winners.push(winnerAddress[winnerTokens[i]]);
      }
      return winners;
   } 
   
   function getWinners()  public view returns(address[] memory){
       return winners;
   }


    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        if(!reveal) {
        return notRevealedUri;
    }else if(!winner_revealed){
      if(checkWinnerTokenId(tokenId)){
        return notRevealedUri;
      }else if(winner_revealed){
        if (checkWinnerTokenId(tokenId)){
          return baseURI;
        }
      }

    }
 
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }


    //only owner
    function revealed() public onlyOwner {
        reveal = true;
    }

    function getWinnersToken () public view returns (uint256[] memory){
        
        // while(repeat){
        //     uint nextN = random();
        //   if(winnerTokens.length != 3 && checkWinnerTokenId(nextN)){
        //     winnerTokens.push(nextN);

        //   }else {
        //     repeat = false;
        //   }
        // }

        return winnerTokens;
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        notRevealedUri = _notRevealedURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function whitelistUser(address _user) public {
        whitelisted[_user] = true;
        list.push(_user);
    }

    function removeWhitelistUser(address _user) external {
        whitelisted[_user] = false;
        for (uint256 i = 0; i < list.length - 1; i++) {
            if (list[i] == _user) {
                for (uint256 y = i; y < list.length - 1; y++) {
                    list[y] = list[y + 1];
                }
            }
        }
        list.pop();
    }

    function getWhitelistUsers() public view returns (address[] memory) {
        return list;
    }

    function getRandomNumber() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(owner(), block.timestamp)));
    }


    function setPublicMint() public {
        PresaleMint = false;
    }

    function setPresaleMint() public {
        PresaleMint = true;
    }

}