# COMP6452-19T1

COMP6452 Software Architecture for Blockchain Applications 2019T1

Lecture in charge: Ingo Weber

## Copyright and Credits

All course slides, materials and a book come from the lecturers. No sharing or commercial use before getting agreement from them. I will take no responsibility for such misuse.

## Assignments

1. Solidity programming - [A voting smart contract](./Assignment_1/contracts/message.sol).

2. Architecture diagram, ATAM.

## Review

1. **两代区块链**: 加密货币 Cryptocurrency, 智能合约 Smart Contract. 对比: 

    加密货币只是交易和转账 Transaction and Financial transfer
    
    智能合约可以部署并执行自定义代码 User-defined code, 商业决策 Enact business decision, 存储和管理财产 Hold and manage asset.

2. **加密货币两个角色**: 

    User 可以创建交易 Create transaction, 签名广播 Sign and Announcement

    Miner 可以收到交易 Receive transaction, 把交易加入区块 Include in block, 尝试创建新区块 Append new block to the data structure

3. **区块链定义**:

    区块链是使用分布式账簿 Distrubuted Ledger 的一种架构, 只能增量存储 Append-Only

    区块链类似链表结构 Linked-list, 在区块内存储交易信息 Sets of transactions

    区块链系统 BC System: 包含区块链网络结点 BC network nodes, 区块链数据结构 BC data structure (各结点拥有账簿的备份), 区块链网络协议 BC network protocols (定义权利, 验证方法, 共识机制等)

    公共区块链 Public BC: 各节点自由进出无需其他结点同意, 各节点可验证新的交易和新生成区块, 还包括激励机制 Incentive mechanism

    区块链平台 BC Platform: 客户端, 用于操作BC

4. **区块链的基本属性 Fundamental Properties**:

    交易一旦提交无法修改 Immutability from committed transaction
    
    通过加密工具保证消息完整性 Integrity from cryptographic tool
    
    通过公开访问保证透明性 Transparency from public access
    
    通过共识机制和算力/财富衡量保证公平性 Equal rights from consensus weighted by the compute power or stake owned by the miner

5. **区块链的局限性 Limitations**:

    数据隐私 Data Privacy: 没有特权用户 Privileged User 可受到特殊保障.

    可扩展性 Scalability: 区块链上的信息 Data on BC, 交易处理速率 Transaction processing rate, 数据传输时延 Data transmission latency 等不易扩展.

6. **可互换/不可互换的 Token**: Fungible token 就比如1元硬币, 可以互换, Non-Fungible token 就比如商标, 独一无二, 不可互换

7. **交易流程**:

    Create: 用户创建交易, 指定金额和接收方地址.

    Sign by owner: 创建者用私钥数字签名, 并用接收方公钥创建脚本 Script, 此脚本的 Locking 部分只有接收方可以解开, Unlocking 部分对各结点开放. 各结点虽不能解开, 但可以通过计算这两部分, 校验此交易有效性.

    Validate: 自身验证此交易的有效性(比如遍历 UTXO, 检查是否有足够金额支付).

    Propagate: 交易创建完成, 向全网广播(消耗 Transaction Fee, ETH 称为 Gas).

    Verify and Record into BC: 各结点校验此交易的有效性, 一经多数确认, 矿工将此笔交易添加到区块链中(优先添加Transaction Fee高的交易).

    Confirm: 用户看到交易存在于最长的区块链分支中，或存在于之后连续5个新区块中(六次确认), 即确认成功.

8. **交易广播 Announcement**: 每笔交易都需要向比特币其他结点广播, 矿工结点找到区块 Hash puzzle 后也需要向全网广播.

9. **Nakamoto Consensus (Bitcoin)**: 同时挖到矿的共识机制, 用于 Bitcoin.

    可能有两个或多个矿工同时解开 Hash puzzle 并广播, 因为广播有延迟, 此时会有多批人在不同的分支链上工作. 
    
    但是一旦A分支链长度不是最长的(比如收到最长链B的广播), 那么B链成为主链 Main Chain. A分支的工作立即停止, 所有A分支上的交易转给B链保存, 矿工随之转移到B链上工作.

10. **孤块 Orphaned Blocks (Bitcoin)/ 旧块 Stale Block (Bitcoin)**: 不在主链上的有效块称为孤块. 参阅 [Orphaned Blocks](https://www.blockchain.com/btc/orphaned-blocks). 旧块是孤块的后继者, 参阅 [Orphan, Stale & Uncle Blocks in Bitcoin and Ethereum](https://2miners.com/blog/orphan-stale-uncle-blocks-in-bitcoin-and-ethereum/)

    即当同时挖到矿情形存在时, 非主链分支的第一区块称为孤块, 随后均称旧块.

    有效块是指该块已经由矿工生成并经其他结点确认, 但是由于广播时延等因素, 该块之后被确认为非主链上的块.

    Bitcoin 中, 在孤块和旧块上的工作均得不到任何奖励.

11. **孤交易 Orphaned Transaction (Bitcoin)**: 由于交易的广播延迟和低手续费延迟, 某交易可能比其引用的交易(父交易)提前确认并到达矿工处, 称为孤交易.

    矿工可选择将其放入交易池 Mempool 等待其父交易到达, 并设定等待时间, 超过此时间的交易予以丢弃(交易失败).

12. **UTXO (Bitcoin)**: 记账模式, 一个地址可以链接多个 UTXO, UTXO 记录了转入 Input/ 转出 Output 的金额和对象, BTC 交易前需要遍历其名下的所有 UTXO 以确认是否有足够资金完成交易.

13. **GHOST protocol (Ethereum)**: 同时挖到矿的共识机制, 用于 Ethereum.

    相比 BTC 把最长链视为主链, 以太坊使用 GHOST 协议允许不同分支的存在, 并将最繁荣的分支作为主链. 参阅 [GHOST协议分析](https://www.jianshu.com/p/135517b05986)

    在非主链上的有效区块称为**叔块 Uncle Block**, 在第一叔块上的工作可得到约87.5%的标准块奖励, 随后逐渐减至12.5%, 以促使矿工尽快投入到主链上工作.

14. **工作量证明 Proof of Work**: 通过解一个足够难度的哈希密码图证明算力, 第一个解开密码图的矿工获得该区块的写入权, 并获得一定数额的奖励. Bitcoin 和 Ethereum 都是这个方法.

15. **权益证明 Proof of Stake**: 矿工通过押注(冻结)一部分财富获得权益证明. 系统随机选择冻结财富较多的矿工获得该区块的写入权, 冻结的财富越多, 则被选中的概率越高.

16. **代理权益证明 Delegated Proof of Stake**: 权益证明的另一种形式, 各矿工按财富获得票数, 可以将票数投给其他矿工, 或者投给自己, 最终票数最多者获得该区块的写入权. 公平性: 如果这个矿工不能在规定时间生成区块, 则不会再给他投票.

17. **去中心化应用 Decentralized APPs (dapps)**: 主要功能通过 Smart Contract 实现, 后端在去中心化环境 Decentralized Environment 中部署, 执行, 前端部署于中心化的服务器上, 通过 API 交互.

## WARNING

This course has high failure rate (almost 25% in this term) and boring content. Think twice to enrol.
