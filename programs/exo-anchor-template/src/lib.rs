use anchor_lang::prelude::*;

declare_id!("ANXYYTDoEHooFjaN8M8pDHRj87d945Bj5QvAFGcpqakw");

#[program]
pub mod exo_anchor_template {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        msg!("Greetings from: {:?}", ctx.program_id);
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize {}
