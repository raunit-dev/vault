use anchor_lang::prelude::*;

use crate::state::vault::VaultState;


#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(mut)]
    pub user: Signer<'info>,

    #[account(
        init,
        payer = user,
        space = 8 + 2,
        seeds = [b"state", user.key().as_ref()],
        bump
    )]
    pub state: Account<'info, VaultState>,

    #[account(
        seeds = [b"vault", user.key().as_ref()],
        bump
    )]
    pub vault: SystemAccount<'info>,

    pub system_program: Program<'info, System>,
}

impl<'info> Initialize<'info> {
    pub fn initialize(&mut self, bump: &InitializeBumps) -> Result<()> {
        self.state.set_inner(VaultState {
            state_bump: bump.state,
            vault_bump: bump.vault,
        });
        Ok(())
    }
}