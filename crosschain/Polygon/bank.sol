// SPDX-License-Identifier: MIT
// compiler 8.1

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "contracts/fee_controller.sol";
import "contracts/sign_controller.sol";


import "hardhat/console.sol";


contract Bank is ERC721URIStorage, ERC721Enumerable, Ownable, FeeController, FullSignController {
    string private _token_base_uri = "https://ipfs.io/ipfs/QmUAh25xFMXH6rTGfeDcexEHvBCdX5wGFFEvKzqNW85nhH/";
    struct tokenInfo {
        uint256 token_id;
        string token_uri;
    }

    constructor () ERC721("Bank", "NFT") {}

    // Sign Id return Event
    event SignId(uint256 sign_id);

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        _requireMinted(tokenId);
        return super.tokenURI(tokenId);
    }

    function getTokenIds(address _owner) public view returns (uint[] memory) {
        uint[] memory _tokensOfOwner = new uint[](ERC721.balanceOf(_owner));
        uint i;

        for (i=0;i<ERC721.balanceOf(_owner);i++){
            _tokensOfOwner[i] = ERC721Enumerable.tokenOfOwnerByIndex(_owner, i);
        }
        return (_tokensOfOwner);
    }

    function withdrawContract(address payable _to) public onlyOwner {
        // 컨트랙트 잔고 출금
        _to.transfer(address(this).balance);
    }

    function BalanceOfContract() public view onlyOwner returns(uint) {
        // 컨트랙트 잔고 확인
        return address(this).balance;
    }

    function getTokenBaseURI() public view returns(string memory) {
        // NFT 베이스 URI
        return _token_base_uri;
    }

    function updateTokenBaseURI(string memory new_uri) public onlyOwner {
        // NFT 베이스 URI 변경
        _token_base_uri = new_uri;
    }

    function _makeTokenURI(uint256 token_id) private view returns (string memory) {
        // TokenURI 생성기 (ex: baseURI + <token_id> + .json)
        return string(
            abi.encodePacked(
                _token_base_uri,
                Strings.toString(token_id),
                ".json"
            )
        );
    }

    function requestMintNFT() public payable {
        /*
        사전 민팅 (무통장 입금, 반쪽짜리 민트)
        반환값: singId
        */

        // Sign 개수 제한 확인
        require(getMintSignTotal() < 25, "sign count exceeded.");

        // 수수료 체크
        require(
            msg.value >= getFee("mint"),
            string(abi.encodePacked(
                "fee must be at least ",
                Strings.toString(getFee("mint")),
                " wei."
            ))
        );

        // 관리자에게 수수료 송금
        address payable owner = payable(owner());
        owner.transfer(msg.value);

        // 사전 민팅 서명 진행 (sing_id 반환)
        emit SignId(createMintSign());
    }

    function approveMintNFT(uint256 sign_id, uint256 token_id) public onlyOwner {
        /*
        사전 민팅 승인
        */
        address target_user = getMintSignUser(sign_id);
        string memory token_uri = _makeTokenURI(token_id);
        _mint(target_user, token_id);
        _setTokenURI(token_id, token_uri);
        approveMintSign(sign_id, token_id);
    }

    function adminMintNFT(uint token_id) public onlyOwner {
        /*
        관리자 전용 일반 민팅 (오너 지갑에 민트)
        */
        _mint(owner(), token_id);
        _setTokenURI(token_id, _makeTokenURI(token_id));
    }

    function requestSwitchNFT(string memory target_chain, address target_address, uint256 token_id) public payable{
        /*
        토큰 스위칭
        */

        // 수수료 체크
        require(
            msg.value >= getFee("switch"),
            string(abi.encodePacked(
                "fee must be at least ",
                Strings.toString(getFee("switch")),
                " wei."
            ))
        );

        // 해당 토큰을, 사용자가 소유하고 있는지 검증
        require(ownerOf(token_id) == msg.sender, "You are not owner.");

        // 관리자에게 수수료 송금
        address payable owner = payable(owner());
        owner.transfer(msg.value);

        // 관리자에게 토큰 송금
        transferFrom(payable(msg.sender), owner, token_id);

        // 스위칭 서명 진행 (sign_id 반환)
        emit SignId(createSwitchSign(target_chain, target_address, token_id));
    }

    function approveSwitchNFT(uint256 sign_id) public onlyOwner {
        /*
        토큰 스위칭 승인
        */
        switchSignInfo memory sign = getSwitchSignAllInfo(sign_id);

        // 해당 토큰이 현재 알로카도스 뱅크 소속인지 확인
        require (ownerOf(sign.token_id) == owner(), "The token does not exist in Bank.");

        // 관리자 서명 승인
        approveSwitchSign(sign_id);
    }
}