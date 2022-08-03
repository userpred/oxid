from controller.chain.web3base import Web3Base
from web3.exceptions import ContractLogicError
from controller.chain.util import word2chain
from config import config, BASEDIR


class EtherController(Web3Base):

    def __init__(
            self,
            entrypoint: str = config.ETHER_DOMAIN,
            contract_addr: str = config.ETHER_CONTRACT,
            admin_public: str = config.ETHER_ADMIN_PUBLIC,
            admin_private: str = config.ETHER_ADMIN_PRIVATE,
            abi_path: str = BASEDIR + '/controller/chain/abi/eth.json'):
        super().__init__(
            entrypoint, contract_addr,
            admin_public, admin_private, abi_path)

    def get_owner(self):
        """해당 컨트랙트 발행자 addr 반환"""
        return self.contract_call('owner')

    def get_mint_sign(self, sign_id: int):
        """Mint Sign 정보 검증 및 반환"""
        try:
            outputs = self.contract_call('getMintSignAllInfo', sign_id)
            return {
                'user_addr': outputs[1],
                'admin_confirm': outputs[2],
            }
        except ContractLogicError as e:
            err_msg = str(e)
            if 'Invalid sign_id' in err_msg:
                # 현재 (아직) 존재하지 않는 Sign인 경우
                return None
            elif 'Signature already processed' in err_msg:
                # 이미 과거에 Admin이 승인한 sign인 경우
                return {'admin_confirm': True}
            raise e

    def get_switch_sign(self, sign_id: int):
        """Switch Sign 정보 검증 및 반환"""
        try:
            outputs = self.contract_call('getSwitchSignAllInfo', sign_id)
            return {
                'tgt_chain': word2chain(outputs[2]),
                'tgt_addr': outputs[3],
                'admin_confirm': outputs[4],
                'token_id': outputs[5],
            }
        except ContractLogicError as e:
            err_msg = str(e)
            if 'Invalid sign_id' in err_msg:
                # 현재 (아직) 존재하지 않는 Sign인 경우
                return None
            elif 'Signature already processed' in err_msg:
                # 이미 과거에 Admin이 승인한 sign인 경우
                return {'admin_confirm': True}
            raise e

    def managed_by(self, token_id: int):
        """해당 토큰이 어드민이 소유하고 있는지 확인"""
        try:
            owner_addr = self.contract_call('ownerOf', token_id)
            return config.POLYGON_ADMIN_PUBLIC == owner_addr
        except ContractLogicError as e:
            err_msg = str(e)
            if 'invalid token ID' in err_msg:
                return None

    def approve_mint_nft(
        self,
        sign_id: int,
        token_id: int,
    ):
        try:
            tx_hash = self.contract_mutable_call(
                'approveMintNFT',
                self.admin_public,
                self.admin_private,
                *(sign_id, token_id),
            ).hex()
            return True, tx_hash
        except ContractLogicError as e:
            raise e

    def approve_switch_nft(self, sign_id: int) -> tuple:
        try:
            tx_hash = self.contract_mutable_call(
                'approveSwitchNFT',
                self.admin_public,
                self.admin_private,
                *(sign_id,),
            ).hex()
            return True, tx_hash
        except ContractLogicError as e:
            err_msg = str(e)
            if 'The token does not exist in Alocados Bank' in err_msg:
                return False, "not_exists"
            raise e

    def admin_mint_nft(
        self,
        token_id: int,
    ):
        try:
            return self.contract_mutable_call(
                'adminMintNFT',
                self.admin_public,
                self.admin_private,
                *(token_id,)
            ).hex()
        except ContractLogicError as e:
            raise e

    def transfer_token(
            self,
            receiver_addr: str,
            token_id: str):
        return self.contract_mutable_call(
            'transferFrom',
            self.admin_public,
            self.admin_private,
            *(
                self.admin_public,
                receiver_addr,
                token_id,
            )
        ).hex()

