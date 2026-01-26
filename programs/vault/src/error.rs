use anchor_lang::prelude::*;

#[error_code]
pub enum SolanaVaultProgramError {
    #[msg("The provided signer is not allowed to execute this instruction.")]
    UnauthorizedSigner,
}
