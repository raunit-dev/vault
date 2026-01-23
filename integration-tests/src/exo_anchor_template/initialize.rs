use exo_anchor_template_client::{
    sdk::{program_id, IntoSdkInstruction},
    InitializeBuilder,
};
use litesvm::LiteSVM;
use solana_sdk::{signature::Keypair, signer::Signer, transaction::Transaction};

#[test]
fn test_initialize() {
    let mut svm = LiteSVM::new();

    let program_bytes = include_bytes!("../../../target/deploy/exo_anchor_template.so");
    svm.add_program(program_id(), program_bytes);

    let payer = Keypair::new();
    svm.airdrop(&payer.pubkey(), 1_000_000_000).unwrap();

    let ix = InitializeBuilder::new()
        .instruction()
        .into_sdk_instruction();

    let blockhash = svm.latest_blockhash();
    let tx = Transaction::new_signed_with_payer(&[ix], Some(&payer.pubkey()), &[&payer], blockhash);

    let result = svm.send_transaction(tx);
    assert!(
        result.is_ok(),
        "Initialize transaction failed: {:?}",
        result
    );
}
