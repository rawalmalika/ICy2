# Introduction to ICy (Internet Computer Yield)
Project ICy was developed by Duke Undergraduate Researchers through [Duke CS+](https://www.cs.duke.edu/undergrad/summer_research) summer programming. ICy is a Decentralized Lending Protocol for the Internet Computer. Similar to Aave, ICy is intended for users to be able to lend, borrow, and earn interest on crypto assets without any intermediary involvement. 
### Overview
ICy uses 6 canisters (Product, Reserve, Treasury, User A, User B, User Assets), and currently, it can be deployed locally and User A and User B can interact. Moreover, any user can create an account through the product canister and it will be held in the database and keep track of their token and cycle amounts as well as enable their functionality with the rest of the product canister. Users will receive receipts for transactions in terms of ATokens and ACycles that will earn interest. The reserve canister is used to isolate assets into liquidity, and is operating in the backend of the product canister which is the only canister that users can interact with.  
## Canisters
There are 6 canisters used: Product, Reserves, Treasury, User A, User B, and User Assets. 
### Treasury
The Treasury canister can mint ICP and Cycle tokens to then transfer to the User Canister for experimentation purposes. The treasury keeps track of its balance.
### Reserve 
The Reserve canister keeps track of available tokens for borrowing as well as the amount locked up for collateral. Essentially, it serves the role of a a liquidity pool.
### Product
The Product Canister is what the users of the protocol will be interacting with. The product canister enables users to frist create an account and add funds to their account which is held in the database module. After this, users can lend to earn interest, borrow if they provide enough collateral, redeem their loan, and repay their borrowed amount as well as withdraw their funds back into their canister (or wallet in the future). The Product canister also mints, burns, and keeps track of all the aTokens outstanding. This canister interacts with the Reserve Canister by organizing User deposits and collateral to determine liquidity of each specific token.
### UserA and UserB
Through the User Canisters, a user can check their balance (similar to a digital wallet). A user can deposit ICP and Cycle tokens to the Product Canister to earn interest and in return be given back aTokens. A user can also redeem a deposit and borrow from the Product Canister if the User Canister has deposited enough tokens as a collateral. These User canisters are just to illustrate what users capabilities would be like on the protocol and are for experimentation purposes.
### User Assets
The User Assets canister is meant solely for the front-end code that implement in the Motoko created functions. Project ICy is using HTML and Javascript.
## Researchers 
<br/>
Lead Professor: Luyao Zhang
<br/>
Co-Lead Professors: Kartik Nayak, Fan Zhang, Yulin Liu
<br/>
Graduate Mentor: Derrick Adam
<br/>
Undergraduate Researchers: Dylan Paul and Malika Rawal
<br/>
Research Support: Tianyu Wu, William Zhao, Elliot Ha, Saad Lahrichi, Ray Zhu

## Deploying ICy
Before going through the steps below, please go through [Dfinity's QuickStart](https://sdk.dfinity.org/docs/quickstart/local-quickstart.html)

Once you have the latest version of dfx installed, you should begin your local environment by enacting the following commands:
In one terminal, navigate to the project directory and run
```
dfx start
```
In another terminal, navigate to the project directory and run
```
npm install
dfx deploy
```
Now you'll want to find the canister ID for the User1_assets canister, which can be achieved by doing as follows:
```
dfx canister id user1_assets
```
You should receive a long string of characters. For example: rno2w-sqaaa-aaaaa-aaacq-cai is a real canister ID.

Now, navigate to a web browser of your choice, and go to the following localhost url:
```
http://127.0.0.1:8000/?canisterId=[YOUR CANISTER ID]
```
For example,
```
http://127.0.0.1:8000/?canisterId=rno2w-sqaaa-aaaaa-aaacq-cai
```
At this point, you should be viewing this page: 

![image](https://github.com/rawalmalika/ICy2/blob/f2d78caa3fdb501a5575191a32da71c8d7e7ae38/FrontEndScreenshot.jpg)
<br/>
You are now accessing ICy's decentralized lending protocol!
<br/>
