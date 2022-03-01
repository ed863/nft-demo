### 总结

此库为登链社区小白沙赛四组作品，实现了一个简单的本地测试链 NFT 交易市场。通过创建，卖出，买入等功能实现了一个简单的闭环。涉及到了 solidity，hardhat，vue，elementUI 等技术栈。

### 启动

1，安装依赖：  
yarn install （如遇报错，可尝试 npm install）

2，启动本地测试链：  
npx hardhat node

3，编译并部署合约到本地测试链：  
npx hardhat run scripts/deploy.js --network localhost

4，启动页面：  
yarn serve
