use std::collections::HashMap;

use anchor_lang::prelude::*;
use anchor_lang::solana_program::program::invoke;
use anchor_spl::token;
use anchor_spl::token::{MintTo, Token};
use mpl_token_metadata::instruction::{create_master_edition_v3, create_metadata_accounts_v2};

declare_id!("BvbHVPA7Cd5PKdM4waLAjbiXqAAjT3M2pRwqZianPgCX");

#[program]
pub mod interoperable {
    use super::*;

    const _TOKEN_BASE_URI: &str = r"https://ipfs.io/ipfs/";

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        let fee = &mut ctx.accounts.fee;
        fee.mint_fee = 0.0;
        fee.switch_fee = 0.0;
        
        let current_token_id = &mut ctx.accounts.current_token_id;
        current_token_id.val = 0;

        let mint_signs = &mut ctx.accounts.mint_signs;
        mint_signs.map = [MintSignInfo::new(), 26];
        Ok(())
    }

    pub fn set_fee(ctx: Context<SetFee>, target: String, fee: f64) -> Result<()> {
        require!(target == "mint" || target == "switch", FeeError::TargetNotDefined);
        if target == "mint" {
            ctx.accounts.fee.mint_fee = fee;
        } else if target == "switch" {
            ctx.accounts.fee.switch_fee = fee;
        }
        Ok(())
    }

    fn validate_mint_sign_id(mint_sign_ids: CurrentTokenId, sign_id: u64) -> Result<()> {
        require!(ctx.accounts.mint_sign_ids.current >= sign_id && sign_id > 0, SignIdError::InvalidSignId);
        require!(!ctx.accounts.mint_signs[sign_id].admin_confirm, SignIdError::AlreadySigned);
        Ok(())
    }

    pub fn request_mint_nft(ctx: Context<RequestMintNft>, mint_fee: u64) -> Result<()> {
        let current_token_id = &mut ctx.accounts.current_token_id;
        let mint_signs = &mut ctx.accounts.mint_signs;
        let mint = &mut ctx.account.mint;

        // validate
        require(current_token_id.val < 25, RequestMintNftError::MaxSignCountExceeded);
        require(ctx.accounts.fee.mint_fee <= mint_fee, RequestMintNftError::NotEnoughFee)

        // transfer
        let cpi_program = ctx.accounts.token_program.to_account_info();
        let token_account = ctx.accounts.token_account;
        let mint_authority = ctx.accounts.mint_authority; 
        transfer(
            CpiContext::new(
                cpi_program,
                Transfer {
                    from: token_account.to_account_info(),
                    to: mint_authority.to_account_info(),
                    authority: mint_authority.to_account_info()
                },
            ),
            mint_fee
        );

        // create mint sign
        current_token_id.val += 1;
        let mint_sign_info = MintSignInfo {
            id: current_token_id.val,
            user_address: mint,
            admin_confirm: false,
            token_id: -1
        }
        mint_signs.map[current_token_id.val] = mint_sign_info
        emit!(MintSignCreated {mint_sign_id: current_token_id.val});
    }

    pub fn approve_mint_nft(ctx: Context<ApproveMintNft>, sign_id: u64, token_id: u64) -> Result<()> {
        // setup
        let mint_signs = &mut ctx.accounts.mint_signs;
        let target_user = mint_signs[sign_id].user_address;
        let token_uri = format!("{}{}.json", _TOKEN_BASE_URI, token_id);

        // mint
        let cpi_accounts = MintTo {
            mint: ctx.accounts.mint.to_account_info(),
            to: ctx.accounts.token_account.to_account_info(),
            authority: ctx.accounts.payer.to_account_info()
        }
        let cpi_program = ctx.accounts.token_program.to_account_info();
        let cpi_ctx = CpiContext::new(cpi_program, cpi_accounts);
        token::mint_to(cpi_ctx, 1)?;
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init, payer = payer, space = 16 + 32)]
    pub fee: Account<'info, Fee>
    #[account(mut)]
    pub current_token_id: Account<'info, CurrentTokenId>,
    #[account(mut)]
    pub mint_signs: Account<'info, MintSigns>
}

#[derive(Accounts)]
pub struct SetFee<'info> {
    #[account(mut)]
    pub fee: Account<'info, Fee>
}

#[derive(Accounts)]
pub struct MintNFT<'info> {
    #[account(mut)]
    pub mint_authority: Signer<'info>,
    /// CHECK: This is not dangerous because we don't read or write from this account
    #[account(mut)]
    pub mint: UncheckedAccount<'info>,
    // #[account(mut)]
    pub token_program: Program<'info, Token>,
    /// CHECK: This is not dangerous because we don't read or write from this account
    #[account(mut)]
    pub metadata: UncheckedAccount<'info>,
    /// CHECK: This is not dangerous because we don't read or write from this account
    #[account(mut)]
    pub token_account: UncheckedAccount<'info>,
    /// CHECK: This is not dangerous because we don't read or write from this account
    pub token_metadata_program: UncheckedAccount<'info>,
    /// CHECK: This is not dangerous because we don't read or write from this account
    #[account(mut)]
    pub payer: AccountInfo<'info>,
    pub system_program: Program<'info, System>,
    /// CHECK: This is not dangerous because we don't read or write from this account
    pub rent: AccountInfo<'info>,
    /// CHECK: This is not dangerous because we don't read or write from this account
    #[account(mut)]
    pub master_edition: UncheckedAccount<'info>,
    #[account(mut)]
    pub fee: Account<'info, Fee>
}

#[derive(Accounts)]
pub struct RequestMintNft<'info> {
    #[account(mut)]
    pub mint_authority: Signer<'info>,
    /// CHECK: This is not dangerous because we don't read or write from this account
    #[account(mut)]
    pub mint: UncheckedAccount<'info>,
    #[account(mut)]
    pub fee: Account<'info, Fee>,
    #[accmout(mut)]
    pub mint_sign_ids: Account<'info, MitSignIds>,
    #[account(mut)]
    pub mint_signs: Account<'info, MintSigns>
    /// CHECK: This is not dangerous because we don't read or write from this account
    #[account(mut)]
    token_account: UncheckedAccount<'info>,
    #[account(mut)]
    token_program: Program<'info, Token>
}

#[derive(Accounts)]
pub struct ApproveMintNft<'info> {
    #[account(mut)]
    pub mint_authority: Signer<'info>,
    /// CHECK: This is not dangerous because we don't read or write from this account
    #[account(mut)]
    pub mint: UncheckedAccount<'info>,
    #[account(mut)]
    pub payer: AccountInfo<'info>,
    /// CHECK: This is not dangerous because we don't read or write from this account
    #[account(mut)]
    token_account: UncheckedAccount<'info>,
    #[account(mut)]
    token_program: Program<'info, Token>,
    #[account(mut)]
    pub fee: Account<'info, Fee>,
    #[accmout(mut)]
    pub mint_sign_ids: Account<'info, MitSignIds>,
    #[account(mut)]
    pub mint_signs: Account<'info, MintSigns>
}

#[account]
pub struct MintSignInfo {
    pub id: u64,
    pub user_address: Pubkey,
    pub admin_confirm: bool,
    pub token_id: u64
}

#[account]
pub struct CurrentTokenId {
    pub val: u64
}

#[account]
pub struct MintSigns {
    pub map: [MintSignInfo; 26]
}

#[account]
#[derive(Default)]
pub struct Fee {
    pub mint_fee: f64,
    pub switch_fee: f64
}

#[error_code]
pub enum FeeError {
    #[msg("target not defined")]
    TargetNotDefined
}

#[error_code]
pub enum SignIdError {
    #[msg("invalid sign id")]
    InvalidSignId,
    #[msg("already signed")]
    AlreadySigned
}

#[error_code]
pub enum RequestMintNftError [
    #[msg("max sign count exceeded")]
    MaxSignCountExceeded,
    #[msg("not enough fee")]
    NotEnoughFee
]

#[event]
pub struct MintSignCreated {
    pub mint_sign_id: u64
}
