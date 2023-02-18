//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

/*
_________                                     .__  __           _________ .__                   __            
\_   ___ \  ____   _____   _____  __ __  ____ |__|/  |_ ___.__. \_   ___ \|  |__   ____   ____ |  | __  ______
/    \  \/ /  _ \ /     \ /     \|  |  \/    \|  \   __<   |  | /    \  \/|  |  \_/ __ \_/ ___\|  |/ / /  ___/
\     \___(  <_> )  Y Y  \  Y Y  \  |  /   |  \  ||  |  \___  | \     \___|   Y  \  ___/\  \___|    <  \___ \ 
 \______  /\____/|__|_|  /__|_|  /____/|___|  /__||__|  / ____|  \______  /___|  /\___  >\___  >__|_ \/____  >
        \/             \/      \/           \/          \/              \/     \/     \/     \/     \/     \/

                                                 /////////////                                 
                                              ///////////////////                              
                                      ////   /////////////////////   ////                      
                                ///////////////////////////////////////////////                
                              ///////////////////////////////////////////////////              
                             /////////////////////////////////////////////////////             
                            ///////////////////////////////////////////////////////            
                            ///////////////////////////////////////////////////////            
                            ////////////////////////////////////// ////////////////            
                           /////////////////////////////////////      //////////////           
                        /////////////////////////////////////         /////////////////        
                      /////////////////////////////////////         /////////////////////      
                      //////////////////// ,/////////////         ///////////////////////      
                     ///////////////////      ////////         ///////////////////////////     
                      /////////////////         ,///         ////////////////////////////      
                      ////////////////////                 //////////////////////////////      
                        ////////////////////            ///////////////////////////////        
                           ////////////////////       //////////////////////////////           
                            /////////////////////   ///////////////////////////////            
                            ///////////////////////////////////////////////////////            
                            ///////////////////////////////////////////////////////            
                             /////////////////////////////////////////////////////             
                              ///////////////////////////////////////////////////              
                                ///////////////////////////////////////////////                
                                      ,//,   /////////////////////   ,//,                      
                                              //////////////////                               
                                                ,///////////,                                 
                                                                                       
*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "erc721a/contracts/ERC721A.sol";

contract CommunityChecks is ERC721A, Ownable, Pausable {
    using SafeMath for uint256;

    event PermanentURI(string _value, uint256 indexed _id);

    uint public constant MAX_SUPPLY = 512;
    uint public constant PRICE = 0.05 ether;
    uint public constant MAX_PER_MINT = 2;
    uint public constant MAX_RESERVE_SUPPLY = 51;

    string public _contractBaseURI;

    constructor(string memory baseURI) ERC721A("Community Checks", "COMMCHECK") {
        _contractBaseURI = baseURI;
        _pause();
    }

    // reserve MAX_RESERVE_SUPPLY for friends and promo
    function reserveNFTs(address to, uint256 quantity) external onlyOwner {
        require(quantity > 0, "Quantity cannot be zero");
        uint totalMinted = totalSupply();
        require(totalMinted.add(quantity) <= MAX_RESERVE_SUPPLY, "No more promo NFTs left");
        _mint(to, quantity);
        lockMetadata(quantity);
    }

    function mint(uint256 quantity) external payable whenNotPaused {
        require(quantity > 0, "Quantity cannot be zero");
        uint totalMinted = totalSupply();
        require(quantity <= MAX_PER_MINT, "Cannot mint that many at once");
        require(totalMinted.add(quantity) < MAX_SUPPLY, "Not enough NFTs left to mint");
        require(PRICE * quantity <= msg.value, "Insufficient funds sent");

        _mint(msg.sender, quantity);
        lockMetadata(quantity);
    }

    function lockMetadata(uint256 quantity) internal {
        for (uint256 i = quantity; i > 0; i--) {
            uint256 tid = totalSupply() - i;
            emit PermanentURI(tokenURI(tid), tid);
        }
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    // OpenSea metadata initialization
    function contractURI() public pure returns (string memory) {
        return "https://communitychecks.wtf/metadata.json";
    }

    function _baseURI() internal view override returns (string memory) {
        return _contractBaseURI;
    }
}
