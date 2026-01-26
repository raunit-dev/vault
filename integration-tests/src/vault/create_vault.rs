use litesvm::LiteSVM;
use solana_sdk::{account::ReadableAccount, signature::Keypair, signer::Signer};
use vault_client::{sdk::program_id, Pubkey};

use crate::vault::{
    self, create_vault,
    helper_functions::{create_mint, create_vault},
};

use vault_client::VaultConfig;

#[test]
fn test_initialize() {
    let mut svm = LiteSVM::new();

    let program_bytes = include_bytes!("../../../target/deploy/vault.so");
    svm.add_program(program_id(), program_bytes);
    let authority = Keypair::new();
    let payer = Keypair::new();
    let mint_authority = Keypair::new();
    let asset_mint = Keypair::new();
    let share_mint = Keypair::new();
    svm.airdrop(&authority.pubkey(), 1_000_000_000).unwrap();
    svm.airdrop(&payer.pubkey(), 1_000_000_000).unwrap();
    svm.airdrop(&mint_authority.pubkey(), 1_000_000_000)
        .unwrap();

    create_mint(&mut svm, &mint_authority, &asset_mint);
    create_mint(&mut svm, &mint_authority, &share_mint);
    let (reserve_pubkey, _) = Pubkey::find_program_address(
        &[
            b"reserve",
            asset_mint.pubkey().as_ref(),
            share_mint.pubkey().as_ref(),
        ],
        &vault_client::sdk::program_id(),
    );
    let (vault_pubkey, _) = Pubkey::find_program_address(
        &[
            b"vault",
            asset_mint.pubkey().as_ref(),
            share_mint.pubkey().as_ref(),
        ],
        &vault_client::sdk::program_id(),
    );
    create_vault(
        &mut svm,
        &authority,
        payer,
        asset_mint.pubkey(),
        share_mint.pubkey(),
        reserve_pubkey,
        vault_pubkey,
    );

    // Verify vault was created
    let vault_account = svm
        .get_account(&vault_pubkey)
        .expect("Vault account should exist");
    assert!(!vault_account.data.is_empty(), "Vault should have data");

    let vault_config = VaultConfig::from_bytes(vault_account.data()).unwrap();
    assert_eq!(vault_config.authority, authority.pubkey());
    assert_eq!(vault_config.asset_mint_address, asset_mint.pubkey());
    assert_eq!(vault_config.share_mint_address, share_mint.pubkey());
    assert_eq!(vault_config.deposit_fees, None);
    assert_eq!(vault_config.withdraw_fees, None);
    assert_eq!(vault_config.initial_price, 0);
    assert_eq!(vault_config.paused, true);
    assert_eq!(vault_config.total_asset_balance, 0);
    assert_eq!(vault_config.vault_asset_cap, None);
    assert_eq!(vault_config.vault_token_account, reserve_pubkey);
}
