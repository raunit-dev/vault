#![allow(unexpected_cfgs)]

use anchor_lang::prelude::*;

pub mod state;
pub mod instructions;



pub use state::*;
pub use instructions::*;



declare_id!("HGw8u4hSsrvJPkNL9FhwuTb6SR6YYLjESFATAyQAYRZN");

#[program]
pub mod vault {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        ctx.accounts.initialize(&ctx.bumps)
    }

    pub fn deposit(ctx: Context<Payment>, amount: u64) -> Result<()> {
        ctx.accounts.deposit(amount)

    }

    pub fn withdraw(ctx: Context<Payment>, amount: u64) -> Result <()> {
        ctx.accounts.withdraw(amount)

    }

    pub fn closeaccount(ctx: Context<CloseAccount>) -> Result<()> {
        ctx.accounts.close()

    }
}











