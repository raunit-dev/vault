use anchor_lang::prelude::*;

#[account]
pub struct VaultState {
    pub state_bump: u8,
    pub vault_bump: u8
}
