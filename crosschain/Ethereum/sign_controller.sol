// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";


contract MintSignController is Ownable {
    /*
    민팅을 위한 멀티 서명 컨트롤러
    */
    using Counters for Counters.Counter;
    Counters.Counter private _mintSignIds;
    struct mintSignInfo {
        uint256 id;  // Sign ID
        address user_address;  // 요청을 한 사용자 주소
        bool admin_confirm;  // 관리자 승인 여부
        uint256 token_id;  // 발행된 토큰 ID
    }
    mapping(uint256 => mintSignInfo) private _mintSigns;

    constructor() {}

    function _validateMintSignId(uint256 sign_id) private view{
        // SingID 검증 함수.

        // 현재 존재하는 Sign 인지 판단
        require(_mintSignIds.current() >= sign_id && sign_id > 0, "Invalid sign_id.");

        // 이미 과거에 처리가 된 Sign 인지 판단
        require(!_mintSigns[sign_id].admin_confirm, "Signature already processed.");
    }

    function createMintSign() internal returns (uint256) {
        // 서명 생성 함수
        _mintSignIds.increment();
        uint256 newSignId = _mintSignIds.current();
        mintSignInfo storage newSign = _mintSigns[newSignId];
        newSign.id = newSignId;
        newSign.user_address = msg.sender;
        newSign.admin_confirm = false;
        return newSignId;
    }

    function approveMintSign(uint256 sign_id, uint256 token_id) internal onlyOwner {
        // 서명 승인 함수
        _validateMintSignId(sign_id);
        _mintSigns[sign_id].admin_confirm = true;
        _mintSigns[sign_id].token_id = token_id;
    }

    function getMintSignTotal() public view returns (uint256) {
        // 총 서명 개수 반환
        return _mintSignIds.current();
    }

    function getMintSignUser(uint256 sign_id) public view returns (address) {
        // 특정 서명을 요청한 사용자 반환
        _validateMintSignId(sign_id);
        return _mintSigns[sign_id].user_address;
    }

    function getMintSignAllInfo(uint256 sign_id) public view returns (mintSignInfo memory) {
        // 특정 서명의 모든 정보를 반환
        _validateMintSignId(sign_id);
        return _mintSigns[sign_id];
    }
}


contract SwitchSignController is Ownable {
    /*
    스위칭을 위한 멀티 서명 컨트롤러
    */
    using Counters for Counters.Counter;
    Counters.Counter private _switchSignIds;
    struct switchSignInfo {
        uint256 id;  // Sing ID
        address user_address;  // 요청을 한 사용자 주소
        string target_chain; // 받을 사용자의 체인 종류
        address target_address;  // 받을 사용자의 주소
        bool admin_confirm;  // 관리자 승인 여부
        uint256 token_id;  // 발행된 토큰 ID
    }
    mapping(uint256 => switchSignInfo) private _switchSigns;

    constructor() {}

    function _validateSwitchSignId(uint256 sign_id) private view {
        // SingID 검증 함수.

        // 현재 존재하는 Sign 인지 판단
        require(_switchSignIds.current() >= sign_id && sign_id > 0, "Invalid sign_id.");

        // 이미 과거에 처리가 된 Sign 인지 판단
        require(!_switchSigns[sign_id].admin_confirm, "Signature already processed.");
    }

    function createSwitchSign(string memory target_chain, address target_address, uint256 token_id) public returns (uint256) {
        // 서명 생성 함수
        _switchSignIds.increment();
        uint256 newSignId = _switchSignIds.current();
        switchSignInfo storage newSign = _switchSigns[newSignId];
        newSign.id = newSignId;
        newSign.user_address = msg.sender;
        newSign.target_chain = target_chain;
        newSign.target_address = target_address;
        newSign.admin_confirm = false;
        newSign.token_id = token_id;
        return newSignId;
    }

    function approveSwitchSign(uint256 sign_id) internal onlyOwner {
        // 서명 승인 함수
        _validateSwitchSignId(sign_id);
        _switchSigns[sign_id].admin_confirm = true;
    }

    function getSwitchSignTotal() public view returns (uint256) {
        // 총 서명 개수 반환
        return _switchSignIds.current();
    }

    function getSwitchSignUser(uint256 sign_id) public view returns (address) {
        // 특정 서명을 요청한 사용자 반환
        _validateSwitchSignId(sign_id);
        return _switchSigns[sign_id].user_address;
    }

    function getSwitchSignTarget(uint256 sign_id) public view returns (address) {
        // 전송할 타겟의 사용자 반환
        _validateSwitchSignId(sign_id);
        return _switchSigns[sign_id].target_address;
    }

    function getSwitchSignAllInfo(uint256 sign_id) public view returns (switchSignInfo memory) {
        // 특정 서명의 모든 정보를 반환
        _validateSwitchSignId(sign_id);
        return _switchSigns[sign_id];
    }
}


contract FullSignController is MintSignController, SwitchSignController {
    constructor() {}
}