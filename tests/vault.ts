import { Program, AnchorProvider, Idl, BN } from '@coral-xyz/anchor';
import { Keypair, PublicKey, SystemProgram, LAMPORTS_PER_SOL, Connection } from '@solana/web3.js';
import vaultIdl from '../target/idl/vault.json'; // Path to your Vault IDL

const VAULT_PROGRAM_ID = new PublicKey('HGw8u4hSsrvJPkNL9FhwuTb6SR6YYLjESFATAyQAYRZN');

// Mocha test setup
describe('Vault Program', () => {
  let provider: AnchorProvider;
  let program: Program;
  let user: Keypair;
  let connection: Connection;

  before(async () => {
    connection = new Connection('http://127.0.0.1:8899', 'confirmed'); // Use 127.0.0.1 for local validator
    provider = AnchorProvider.local('http://127.0.0.1:8899'); // Local Solana connection
    program = new Program(vaultIdl as Idl, VAULT_PROGRAM_ID, provider);

    // Generate a new user
    user = Keypair.generate();

    // Airdrop SOL to the user
    const airdropSignature = await connection.requestAirdrop(user.publicKey, 2 * LAMPORTS_PER_SOL);
    await connection.Transaction(airdropSignature, 'confirmed');
  });

  it('should initialize vault state', async () => {
    // Derive PDAs
    const [statePDA] = PublicKey.findProgramAddressSync(
      [Buffer.from('state'), user.publicKey.toBuffer()],
      VAULT_PROGRAM_ID
    );

    const [vaultPDA] = PublicKey.findProgramAddressSync(
      [Buffer.from('vault'), statePDA.toBuffer()],
      VAULT_PROGRAM_ID
    );

    // Initialize vault
    await program.methods
      .initialize()
      .accounts({
        user: user.publicKey,
        state: statePDA,
        vault: vaultPDA,
        systemProgram: SystemProgram.programId,
      })
      .signers([user])
      .rpc({ commitment: 'confirmed' });

    // Verify state account exists
    const stateAccount = await program.account.VaultState.fetch(statePDA);
    console.log('Vault Initialized with state bump:', stateAccount.stateBump, 'vault bump:', stateAccount.vaultBump);
  });

  it('should deposit funds into vault', async () => {
    // Derive PDAs
    const [statePDA] = PublicKey.findProgramAddressSync(
      [Buffer.from('state'), user.publicKey.toBuffer()],
      VAULT_PROGRAM_ID
    );

    const [vaultPDA] = PublicKey.findProgramAddressSync(
      [Buffer.from('vault'), statePDA.toBuffer()],
      VAULT_PROGRAM_ID
    );

    // Get initial balances
    const initialUserBalance = await connection.getBalance(user.publicKey);
    const initialVaultBalance = await connection.getBalance(vaultPDA);

    // Deposit funds into vault
    const depositAmount = new BN(0.1 * LAMPORTS_PER_SOL);
    await program.methods
      .deposit(depositAmount)
      .accounts({
        user: user.publicKey,
        vaultState: statePDA,
        vault: vaultPDA,
        systemProgram: SystemProgram.programId,
      })
      .signers([user])
      .rpc({ commitment: 'confirmed' });

    // Get final balances
    const finalUserBalance = await connection.getBalance(user.publicKey);
    const finalVaultBalance = await connection.getBalance(vaultPDA);

    // Verify balance changes (accounting for transaction fees)
    console.log('Deposit successful');
    console.log('User balance change:', initialUserBalance - finalUserBalance, 'lamports');
    console.log('Vault balance change:', finalVaultBalance - initialVaultBalance, 'lamports');
  });

  it('should close the vault account', async () => {
    // Derive PDAs
    const [statePDA] = PublicKey.findProgramAddressSync(
      [Buffer.from('state'), user.publicKey.toBuffer()],
      VAULT_PROGRAM_ID
    );

    const [vaultPDA] = PublicKey.findProgramAddressSync(
      [Buffer.from('vault'), statePDA.toBuffer()],
      VAULT_PROGRAM_ID
    );

    // Get initial user balance
    const initialUserBalance = await connection.getBalance(user.publicKey);

    // Close account
    await program.methods
      .closeaccount()
      .accounts({
        user: user.publicKey,
        vaultState: statePDA,
        vault: vaultPDA,
        systemProgram: SystemProgram.programId,
      })
      .signers([user])
      .rpc({ commitment: 'confirmed' });

    // Verify vault account is closed
    const vaultAccount = await connection.getAccountInfo(vaultPDA);
    if (vaultAccount) {
      throw new Error('Vault account was not closed');
    }

    // Verify user received funds (accounting for transaction fees)
    const finalUserBalance = await connection.getBalance(user.publicKey);
    console.log('Vault account closed');
    console.log('User balance change:', finalUserBalance - initialUserBalance, 'lamports');
  });

  after(async () => {
    // Clean up if needed
  });
});