
from controller.chain.ether import EtherController as Ether
from config import config, BASEDIR


class PolygonController(Ether):

    def __init__(
            self,
            entrypoint: str = config.POLYGON_DOMAIN,
            contract_addr: str = config.POLYGON_CONTRACT,
            admin_public: str = config.POLYGON_ADMIN_PUBLIC,
            admin_private: str = config.POLYGON_ADMIN_PRIVATE,
            abi_path: str = BASEDIR + '/controller/chain/abi/poly.json',):
        super().__init__(
            entrypoint, contract_addr,
             admin_public, admin_private, abi_path)

