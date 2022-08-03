import json
from solana.rpc.async_api import AsyncClient
from solana.keypair import Keypair
from solana.publickey import PublicKey
from anchorpy import Provider, Wallet
from solana.transaction import Transaction
from solana.transaction import TransactionInstruction
from settings import settings

from solana.system_program import SYS_PROGRAM_ID
from solana.sysvar import SYSVAR_RENT_PUBKEY
from metaplex.metadata import METADATA_PROGRAM_ID, TOKEN_PROGRAM_ID


class SolanaAPI:

    def __init__(
        self,
        admin_secret: str = settings.admin_secret,
        endpoint: str = settings.endpoint,
        system_program_id: PublicKey = SYS_PROGRAM_ID,
        sysvar_rent_pubkey: PublicKey = SYSVAR_RENT_PUBKEY,
        metadata_program_id: PublicKey = METADATA_PROGRAM_ID,
        token_program_id: PublicKey = TOKEN_PROGRAM_ID,
    ):
        self.system_program_id = system_program_id
        self.sysvar_rent_pubkey = sysvar_rent_pubkey
        self.metadata_program_id = metadata_program_id
        self.token_program_id = token_program_id

        self.client = AsyncClient(endpoint=endpoint)
        self.admin_secret = json.loads(admin_secret)
        self.admin_account = Keypair.from_secret_key(self.admin_secret)
        self.admin_wallet = Wallet(self.admin_account)
        self.admin_provider = Provider(
            connection=self.client,
            wallet=self.admin_wallet
        )

    async def transact(
        self,
        instruction: TransactionInstruction,
        signer: Keypair = None,
    ):
        """Single instruction transaction"""
        tx = Transaction().add(instruction)
        if signer:
            wallet = Wallet(signer)
            provider = Provider(
                connection=self.client,
                wallet=wallet
            )
            return await provider.send(tx, [signer])
        else:
            provider = self.admin_provider
            return await provider.send(
                tx, [self.admin_wallet])


