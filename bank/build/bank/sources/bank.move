/// Module: bank
module bank::bank {
    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    const ENotEnough: u64 = 0;
    const EInvalidAmount: u64 = 1;

    // 银行账户结构体
    public  struct BankAccount has key, store {
        id: UID,
        balance:  Balance<SUI>,
    }

    fun new(ctx: &mut TxContext): BankAccount {
        let initial_balance = balance::zero<SUI>();
        BankAccount {
            id: object::new(ctx),
            balance: initial_balance,
        }
    }
    // 存钱

    public fun deposit(
        amount: u64, payment: &mut Coin<SUI>, ctx: &mut TxContext
    ) {
        assert!(coin::value(payment) >= amount, ENotEnough);

        let coin_balance = coin::balance_mut(payment);
        let paid = balance::split(coin_balance, amount);
        let mut account = new(ctx);
        balance::join(&mut account.balance, paid);
        transfer::transfer(account, tx_context::sender(ctx))
    }
    // 取钱
    public fun withdraw(account: &mut BankAccount, amount: u64, ctx: &mut TxContext) {

        assert!(amount > 0, EInvalidAmount); // 检查金额是否有效
        assert!(balance::value(&account.balance) >= amount, ENotEnough); // 检查余额是否足够
        // 从账户余额中提取取款金额
        let taken_amount = coin::take(&mut account.balance, amount, ctx);
        // 将取款金额转移给交易发送者
        transfer::public_transfer(taken_amount, tx_context::sender(ctx));
    }

    // 获取账户余额
    public fun get_balance(account: &BankAccount): u64 {
        balance::value(&account.balance)
    }
}