// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title DynamicOverlayNFT
 * @dev ERC-721 NFT contract with dynamic overlay functionality
 * Each NFT has a base image and can have dynamic overlays that can be updated
 */
contract DynamicOverlayNFT is ERC721, Ownable {
    uint256 private _tokenIds;
    
    // Mapping from tokenId to base image URI
    mapping(uint256 => string) private _baseURIs;
    
    // Mapping from tokenId to overlay URI
    mapping(uint256 => string) private _overlayURIs;
    
    // Mapping from tokenId to token name
    mapping(uint256 => string) private _tokenNames;
    
    // Mapping from tokenId to token description
    mapping(uint256 => string) private _tokenDescriptions;
    
    // Mapping from tokenId to static attributes
    mapping(uint256 => string) private _staticAttributes;
    
    // Mapping from tokenId to dynamic attributes
    mapping(uint256 => string) private _dynamicAttributes;
    
    // Events
    event NFTMinted(uint256 indexed tokenId, address indexed to, string baseURI);
    event OverlayUpdated(uint256 indexed tokenId, string overlayURI);
    event DynamicAttributesUpdated(uint256 indexed tokenId, string dynamicAttributes);
    
    constructor() ERC721("Ashwin Cyberpunk NFT", "ACNFT") Ownable(msg.sender) {}
    
    /**
     * @dev Mint a new NFT with base image
     * @param to Address to mint the NFT to
     * @param baseURI IPFS URI for the base image
     * @param tokenName Name for the NFT
     * @param tokenDescription Description for the NFT
     * @param staticAttributes JSON string of static attributes
     * @param dynamicAttributes JSON string of dynamic attributes
     * @return tokenId The ID of the newly minted token
     */
    function mintNFT(
        address to,
        string memory baseURI,
        string memory tokenName,
        string memory tokenDescription,
        string memory staticAttributes,
        string memory dynamicAttributes
    ) public onlyOwner returns (uint256) {
        _tokenIds++;
        uint256 newTokenId = _tokenIds;
        
        _mint(to, newTokenId);
        _baseURIs[newTokenId] = baseURI;
        _tokenNames[newTokenId] = tokenName;
        _tokenDescriptions[newTokenId] = tokenDescription;
        _staticAttributes[newTokenId] = staticAttributes;
        _dynamicAttributes[newTokenId] = dynamicAttributes;
        
        emit NFTMinted(newTokenId, to, baseURI);
        
        return newTokenId;
    }
    
    /**
     * @dev Set overlay URI for a specific token
     * @param tokenId The token ID to update
     * @param overlayURI IPFS URI for the overlay image
     */
    function setOverlay(uint256 tokenId, string memory overlayURI) public onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        _overlayURIs[tokenId] = overlayURI;
        
        emit OverlayUpdated(tokenId, overlayURI);
    }
    
    /**
     * @dev Update dynamic attributes for a specific token
     * @param tokenId The token ID to update
     * @param dynamicAttributes JSON string of dynamic attributes
     */
    function setDynamicAttributes(uint256 tokenId, string memory dynamicAttributes) public onlyOwner {
        require(_exists(tokenId), "Token does not exist");
        _dynamicAttributes[tokenId] = dynamicAttributes;
        
        emit DynamicAttributesUpdated(tokenId, dynamicAttributes);
    }
    
    /**
     * @dev Get the base URI for a token
     * @param tokenId The token ID
     * @return The base URI
     */
    function getBaseURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return _baseURIs[tokenId];
    }
    
    /**
     * @dev Get the overlay URI for a token
     * @param tokenId The token ID
     * @return The overlay URI
     */
    function getOverlayURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return _overlayURIs[tokenId];
    }
    
    /**
     * @dev Return the token URI with merged metadata including overlay
     * @param tokenId The token ID
     * @return JSON string containing the complete metadata
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        
        string memory baseURI = _baseURIs[tokenId];
        string memory overlayURI = _overlayURIs[tokenId];
        string memory tokenName = _tokenNames[tokenId];
        string memory tokenDescription = _tokenDescriptions[tokenId];
        string memory staticAttributes = _staticAttributes[tokenId];
        string memory dynamicAttributes = _dynamicAttributes[tokenId];
        
        // Build the JSON metadata
        string memory json = string(abi.encodePacked(
            '{"name": "', tokenName, '",',
            '"description": "', tokenDescription, '",',
            '"image": "', baseURI, '"'
        ));
        
        // Add overlay if it exists
        if (bytes(overlayURI).length > 0) {
            json = string(abi.encodePacked(json, ',"overlay": "', overlayURI, '"'));
        }
        
        // Add attributes
        json = string(abi.encodePacked(json, ',"attributes": ['));
        
        // Add static attributes if they exist
        if (bytes(staticAttributes).length > 0) {
            json = string(abi.encodePacked(json, staticAttributes));
        }
        
        // Add dynamic attributes if they exist
        if (bytes(dynamicAttributes).length > 0) {
            if (bytes(staticAttributes).length > 0) {
                json = string(abi.encodePacked(json, ','));
            }
            json = string(abi.encodePacked(json, dynamicAttributes));
        }
        
        json = string(abi.encodePacked(json, ']}'));
        
        return json;
    }
    
    /**
     * @dev Get the total number of tokens minted
     * @return The total count
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIds;
    }
    
    /**
     * @dev Check if a token exists
     * @param tokenId The token ID to check
     * @return True if the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
}
