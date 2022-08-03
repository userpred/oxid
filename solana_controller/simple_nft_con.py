import asyncio
from anchorpy import Provider, Wallet
from solana.keypair import Keypair
from solana.publickey import PublicKey
from solana.transaction import Transaction
from solana.rpc.async_api import AsyncClient
from solana.rpc.core import RPCException
from pprint import pprint
from metaplex.metadata import get_metadata_account, get_edition

from simple_nft.instructions import mint_nft, MintNftArgs, MintNftAccounts

from solana.system_program import SYS_PROGRAM_ID
from solana.sysvar import SYSVAR_RENT_PUBKEY
from metaplex.metadata import METADATA_PROGRAM_ID, TOKEN_PROGRAM_ID


ADDR1 = "XXX"

ADDR2 = "XXX"

URL = ""


def main():
    user_acc = Keypair.from_secret_key(ADDR2)
    token_acc = PublicKey("XXX")
    token = PublicKey("XXX")
    metadata_acc = get_metadata_account(token)
    master_edition_acc = get_edition(token)
    
    print("User:", user_acc.public_key)
    print("Token Acc:", token_acc)
    print("Token:", token)
    print("Metdata Acc:", metadata_acc)
    print("Master Edition Acc:", master_edition_acc)

    ix = mint_nft(
        MintNftArgs(
            uri=URL,
            title="Simple NFT #1",
            symbol="SIMPLE",
        ),
        MintNftAccounts(
            mint_authority=user_acc.public_key,
            system_program=SYS_PROGRAM_ID,
            token_program=TOKEN_PROGRAM_ID,
            mint=token,
            metadata=metadata_acc,
            payer=user_acc.public_key,
            token_account=token_acc, 
            master_edition=master_edition_acc,
            token_metadata_program=METADATA_PROGRAM_ID,
            rent=SYSVAR_RENT_PUBKEY,
        )
    )
    tx = Transaction().add(ix)
    client = AsyncClient(endpoint='https://api.devnet.solana.com')
    wallet = Wallet(payer=user_acc)
    provider = Provider(
        connection=client,
        wallet=wallet,
    )
    try:
        res = asyncio.run(provider.send(tx, [user_acc]))
    except RPCException as e:
        error = e.args[0]
        pprint(error)
    else:
        print(res)



if __name__ == '__main__':
    main()