import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensure user can create a vault",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("vault", "create-vault", [], wallet_1.address)
    ]);
    
    assertEquals(block.receipts[0].result, "(ok true)");
  },
});

Clarinet.test({
  name: "Test deposit functionality",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("vault", "create-vault", [], wallet_1.address),
      Tx.contractCall("vault", "deposit", ["u100"], wallet_1.address)
    ]);
    
    assertEquals(block.receipts[1].result, "(ok true)");
  },
});

Clarinet.test({
  name: "Test withdrawal with insufficient funds",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    const wallet_1 = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("vault", "create-vault", [], wallet_1.address),
      Tx.contractCall("vault", "withdraw", ["u100"], wallet_1.address)
    ]);
    
    assertEquals(block.receipts[1].result, "(err u103)");
  },
});
