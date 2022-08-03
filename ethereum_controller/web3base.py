import json
from web3 import Web3
from web3.middleware import geth_poa_middleware


class Web3Base:

    def __init__(
            self,
            entrypoint: str,
            contract_addr: str,
            admin_public: str,
            admin_private: str,
            abi_path: str):
        self.entrypoint = entrypoint
        self.contract_addr = contract_addr
        self.admin_public = admin_public
        self.admin_private = admin_private
        self.abi = json.load(open(abi_path))
        self._web3 = Web3(Web3.HTTPProvider(entrypoint))
        self._web3.middleware_onion.inject(geth_poa_middleware, layer=0)

        self.is_connected = self._web3.isConnected()
        if not self.is_connected:
            raise RuntimeError(f"{self.__class__.__name__} is not connected!")
        self._contract = self._web3.eth.contract(
            address=self._web3.toChecksumAddress(contract_addr),
            abi=self.abi
        )

    def is_valid_address(self, account_addr: str):
        """유효한 어카운트 주소인지 확인"""
        return self._web3.isAddress(account_addr)

    def get_balance(self, account_addr: str):
        """return Ether"""
        acc_check_sum = self._web3.toChecksumAddress(account_addr)
        wei = self._web3.eth.get_balance(acc_check_sum)
        return self._web3.fromWei(wei, 'ether')

    def contract_call(self, function: str, *args):
        """블록에 기록하지 않는 Read 메소드에 대한 호출"""
        return getattr(self._contract.functions, function)(*args).call()

    def contract_mutable_call(
            self,
            function: str,
            public_key: str,
            private_key: str,
            *args):
        """블록을 기록해야 하는 Writeable 메소드 호출"""
        tx = getattr(
            self._contract.functions,
            function
        )(*args).buildTransaction(
            {
                'from': public_key,
                'nonce': self._web3.eth.getTransactionCount(
                    public_key, 'pending'
                )
            }
        )
        signed_tx = self._web3.eth.account.sign_transaction(
            tx, private_key)
        res = self._web3.eth.send_raw_transaction(
            signed_tx.rawTransaction)
        return res

    def get_transaction_receipt(self, tx_hash: str):
        receipt = self._web3.eth.get_transaction_receipt(tx_hash)
        return dict(receipt)

    def get_transaction(self, tx_hash: str) -> dict:
        """트랜잭션 정보 조회"""
        response = self._web3.eth.get_transaction(tx_hash)
        response = dict(response)

        # parse input fields
        data = response['input']
        response['input_data'] = {
            'method_id': data[:10],
            # 메소드 실행을 위한 각각의 인자
            'data': [],
        }
        data = data[10:]
        data_list = response['input_data']['data']
        while data:
            data_list.append(data[:64])
            data = data[64:]
        return response

