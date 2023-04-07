// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

error SoldOut();
error InvalidQuantity();
error WithdrawFailed();

contract Scrollers is Ownable, ERC721A, ReentrancyGuard {
  using Strings for uint256;

  string public _baseTokenURI;
  
  uint256 public price = 0 ether;
  uint256 public constant maxSupply = 10000;
  uint256 public maxMintAmountPerTx = 5;

  constructor() ERC721A("Scrollers", "SCRlRS") {
    _baseTokenURI = "data:application/json;base64,eyJuYW1lIjogIlNjcm9sbGVycyBORlQiLCAiZGVzY3JpcHRpb24iOiAiU2Nyb2xsZXJzIE5GVCBpcyBhIHRlc3QgTkZUIGNvbGxlY3Rpb24gYXZhaWxhYmxlIG9uIFNjcm9sbCBBbHBoYSBUZXN0bmV0LiBZb3UgbWF5IG1pbnQgaXQgZnJlZWx5LCBhbmQgdXNlIGl0IGZvciB0ZXN0aW5nLCBvciB5b3VyIG93biBzYXRpc2ZhY3Rpb24uIiwgImltYWdlIjogImRhdGE6aW1hZ2Uvc3ZnK3htbDtiYXNlNjQsUEhOMlp5QjRiV3h1Y3owbmFIUjBjRG92TDNkM2R5NTNNeTV2Y21jdk1qQXdNQzl6ZG1jbklIWnBaWGRDYjNnOUp6RXhJREV4SURVd0lEVXdKejQ4Wno0OGNtVmpkQ0I0UFNjeE1pY2dlVDBuTVRJbklIZHBaSFJvUFNjME9DY2dhR1ZwWjJoMFBTYzBPQ2NnWm1sc2JEMG5JMEUxTnprek9TY2djM1J5YjJ0bFBTZHViMjVsSnlCemRISnZhMlV0YkdsdVpXTmhjRDBuY205MWJtUW5JSE4wY205clpTMXNhVzVsYW05cGJqMG5jbTkxYm1RbklITjBjbTlyWlMxdGFYUmxjbXhwYldsMFBTY3hNQ2NnYzNSeWIydGxMWGRwWkhSb1BTY3lKejQ4TDNKbFkzUStQSEpsWTNRZ2VEMG5NVGduSUhrOUp6RTRKeUIzYVdSMGFEMG5NelluSUdobGFXZG9kRDBuTXpZbklHWnBiR3c5SnlNNU1rUXpSalVuSUhOMGNtOXJaVDBuYm05dVpTY2djM1J5YjJ0bExXeHBibVZqWVhBOUozSnZkVzVrSnlCemRISnZhMlV0YkdsdVpXcHZhVzQ5SjNKdmRXNWtKeUJ6ZEhKdmEyVXRiV2wwWlhKc2FXMXBkRDBuTVRBbklITjBjbTlyWlMxM2FXUjBhRDBuTWljK1BDOXlaV04wUGp4amFYSmpiR1VnWTNnOUp6STJKeUJqZVQwbk16QW5JSEk5SnpRbklHWnBiR3c5SnlOR1EwVkJNa0luSUhOMGNtOXJaVDBuYm05dVpTY2djM1J5YjJ0bExXeHBibVZqWVhBOUozSnZkVzVrSnlCemRISnZhMlV0YkdsdVpXcHZhVzQ5SjNKdmRXNWtKeUJ6ZEhKdmEyVXRiV2wwWlhKc2FXMXBkRDBuTVRBbklITjBjbTlyWlMxM2FXUjBhRDBuTWljK1BDOWphWEpqYkdVK1BIQmhkR2dnWm1sc2JEMG5JelZET1VVek1TY2djM1J5YjJ0bFBTY2pOVU01UlRNeEp5QnpkSEp2YTJVdGJHbHVaV05oY0QwbmNtOTFibVFuSUhOMGNtOXJaUzFzYVc1bGFtOXBiajBuY205MWJtUW5JSE4wY205clpTMXRhWFJsY214cGJXbDBQU2N4TUNjZ2MzUnliMnRsTFhkcFpIUm9QU2N5SnlCa1BTZE5OVEFzTXpWakxUSXVPRGsxT0Mwd0xqZzFOREl0Tmk0eU56azFMVGN1T1RnNE5pMDRMVGhqTFRRdU1qQTRMVEF1TURJM09DMDJMakkxTkN3MUxqZ3pOaTB4TVN3NVl5MHpMREl0TXk0ek56UTFMREl1T0RRNU55MDJMRFJqTFRJdU1qZ3lOQ3d4TFRNc015MHpMakkxTERNdU5qUXdOaUJqTFRBdU16QXpNU3d3TGpjM05qWXRNUzQwTnpVeExESXVOVEl4TkMwd0xqazFPRE1zTXk0eE1EazBZekV1TWpBNE15d3hMak0zTlN3eUxqUTFPRE1zTVM0MUxEVXNNQzQzTVRjNVl6SXVNVFEzTFRBdU5qWXdOaXcwTGprM05qa3ROQzQ0TURjMExEWXVPRGMxTFRZdU1qRTNPU0JqTWk0eU56QTRMVEV1TmpnM05TdzBMalkwTlRndE1pNDFMRGd1TURnek15MHlZekl1TkRjNU5Td3dMak0yTURZc05pNDJOaXd6TGpFM01qTXNOeTQ0TVRJMUxETXVNRFl5TldNeExqTXhNalV0TUM0eE1qVXRNUzQxT1RNM0xUSXVOVFl5TlMwd0xqVXpNVEl0TkM0eE9EYzFJR014TGpFek1qY3RNUzQzTXpJMUxESXVPVEV3TWl3d0xqRTFNamtzTXk0Mk16VTBMVEV1TURnek0wTTFNUzQ1T0RRMExETTJMalVzTlRBdU5qTXlMRE0xTGpFNE5qUXNOVEFzTXpWNkp6NDhMM0JoZEdnK1BDOW5QanhuUGp4eVpXTjBJSGc5SnpFeUp5QjVQU2N4TWljZ2QybGtkR2c5SnpRNEp5Qm9aV2xuYUhROUp6UTRKeUJtYVd4c1BTZHViMjVsSnlCemRISnZhMlU5SnlNd01EQXdNREFuSUhOMGNtOXJaUzFzYVc1bFkyRndQU2R5YjNWdVpDY2djM1J5YjJ0bExXeHBibVZxYjJsdVBTZHliM1Z1WkNjZ2MzUnliMnRsTFcxcGRHVnliR2x0YVhROUp6RXdKeUJ6ZEhKdmEyVXRkMmxrZEdnOUp6SW5Qand2Y21WamRENDhjbVZqZENCNFBTY3hPQ2NnZVQwbk1UZ25JSGRwWkhSb1BTY3pOaWNnYUdWcFoyaDBQU2N6TmljZ1ptbHNiRDBuYm05dVpTY2djM1J5YjJ0bFBTY2pNREF3TURBd0p5QnpkSEp2YTJVdGJHbHVaV05oY0QwbmNtOTFibVFuSUhOMGNtOXJaUzFzYVc1bGFtOXBiajBuY205MWJtUW5JSE4wY205clpTMXRhWFJsY214cGJXbDBQU2N4TUNjZ2MzUnliMnRsTFhkcFpIUm9QU2N5Sno0OEwzSmxZM1ErUEdOcGNtTnNaU0JqZUQwbk1qWW5JR041UFNjek1DY2djajBuTkNjZ1ptbHNiRDBuYm05dVpTY2djM1J5YjJ0bFBTY2pNREF3TURBd0p5QnpkSEp2YTJVdGJHbHVaV05oY0QwbmNtOTFibVFuSUhOMGNtOXJaUzFzYVc1bGFtOXBiajBuY205MWJtUW5JSE4wY205clpTMXRhWFJsY214cGJXbDBQU2N4TUNjZ2MzUnliMnRsTFhkcFpIUm9QU2N5Sno0OEwyTnBjbU5zWlQ0OGNtVmpkQ0I0UFNjeE9DY2dlVDBuTVRnbklIZHBaSFJvUFNjek5pY2dhR1ZwWjJoMFBTY3pOaWNnWm1sc2JEMG5ibTl1WlNjZ2MzUnliMnRsUFNjak1EQXdNREF3SnlCemRISnZhMlV0YkdsdVpXTmhjRDBuY205MWJtUW5JSE4wY205clpTMXNhVzVsYW05cGJqMG5jbTkxYm1RbklITjBjbTlyWlMxdGFYUmxjbXhwYldsMFBTY3hNQ2NnYzNSeWIydGxMWGRwWkhSb1BTY3lKejQ4TDNKbFkzUStQSEJoZEdnZ1ptbHNiRDBuYm05dVpTY2djM1J5YjJ0bFBTY2pNREF3TURBd0p5QnpkSEp2YTJVdGJHbHVaV05oY0QwbmNtOTFibVFuSUhOMGNtOXJaUzFzYVc1bGFtOXBiajBuY205MWJtUW5JSE4wY205clpTMXRhWFJsY214cGJXbDBQU2N4TUNjZ2MzUnliMnRsTFhkcFpIUm9QU2N5SnlCa1BTZE5NaklzTkROak1DNDFNalU1TFRFdU1ERTVPQ3d3TGpjeU56VXRNUzQ1TmpjeUxETXRNMk15TGpZd09UWXRNUzR4T0RVNUxETXRNaXcyTFRSak5DNDNORFl0TXk0eE5qUXNOaTQzT1RJdE9TNHdNamM0TERFeExUbGpNUzQzTWpBMUxEQXVNREV4TkN3MUxEY3NPQ3c0Sno0OEwzQmhkR2crUEM5blBqd3ZjM1puUGc9PSJ9";
  }

  function mint(uint256 _quantity) external payable {
    if(_quantity < 1 || _quantity > maxMintAmountPerTx) revert InvalidQuantity();
    if (totalSupply() + _quantity > maxSupply) revert SoldOut();

    _safeMint(msg.sender, _quantity);
  }

  function getOwnershipData(uint256 tokenId)
    external
    view
    returns (TokenOwnership memory)
  {
    return _ownershipOf(tokenId);
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(_tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return currentBaseURI;
  }

  function setPrice(uint256 _price) public onlyOwner {
    price = _price;
  }

  function withdraw() public payable onlyOwner {
    (bool os, ) = payable(owner()).call{value: address(this).balance}("");
    if(!os) revert WithdrawFailed();
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string memory baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }
}