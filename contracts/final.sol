// SPDX-License-Identifier: GPL-3.0

// Amended by HashLips
/**
    !Disclaimer!
    These contracts have been used to create tutorials,
    and was created for the purpose to teach people
    how to create smart contracts on the blockchain.
    please review this code on your own before using any of
    the following code for production.
    HashLips will not be liable in any way if for the use 
    of the code. That being said, the code has been tested 
    to the best of the developers' knowledge to work as intended.
*/

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string public baseURI;
    string public baseExtension = ".json";
    uint256 public cost = 0.01 ether;
    uint256 public maxSupply = 5;
    uint256 public mintAmount=1;
    bool public paused = false;
    bool public revealed = false;
    string public notRevealedUri;
    bool public PresaleMint = true;


    mapping(address => bool) public whitelisted;
    address[] list;

    address[] public userslist;
    address[] public winners;

    uint256[] ids;

    address winner;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedUri
    ) ERC721(_name, _symbol){
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedUri);
    }

    // internal
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // public
    function mint() public payable {
      uint256 supply = totalSupply();
      require(!paused);
      require(supply + mintAmount <= maxSupply);

        if (msg.sender != owner()) {

            if (PresaleMint == true) {
                require(msg.value >= cost,"insufficient funds");
               require(supply + 1  <= maxSupply);
               require(isWhiteListed(msg.sender), "Youre not whitelisted");
            }
            
            addUsers(msg.sender);
        }
         _safeMint(msg.sender, supply + 1);
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

        if (revealed == false) {
            return notRevealedUri;
        }

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }

    function getOwner() public view returns (bool) {
        if (msg.sender == owner()) {
            return true;
        }
        return false;
    }

    //only owner
    function reveal() public onlyOwner {
        revealed = true;
    }

    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }

    function setPublicMint() public {
        PresaleMint = false;
    }

    function setPresaleMint() public {
        PresaleMint = true;
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

    function addUsers(address _user) internal {
        userslist.push(_user);
    }

    function getUsers() public view returns (address[] memory) {
        return userslist;
    }

    function getRandomNumber() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(owner(), block.timestamp)));
    }

    function pickWinner() public onlyOwner returns (address[] memory) {
        for (uint256 i = 0; i < 3; i++) {
            uint256 index = getRandomNumber() % userslist.length -i;
            ids.push(index);
            winner = userslist[index];
            winners.push(winner);
        }
        list = new address[](0);
        return winners;
    }

    function isWhiteListed(address _user) public view returns (bool) {
        return whitelisted[_user];
    }

    function getWinners() public view  returns (address[] memory) {
        return winners;
    }

    function getIds() public view  returns (uint256[] memory) {
        return ids;
    }
}
