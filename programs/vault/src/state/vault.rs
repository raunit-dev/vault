use anchor_lang::prelude::*;

#[account]
pub struct VaultState {
    pub vault_bump: u8,
    pub state_bump: u8,
}
