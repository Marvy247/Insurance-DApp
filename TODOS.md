You’re building a **Smart Contract-Based Insurance Platform** for the Sonic S-Tier Hackathon (July 15–August 31, 2025) using Foundry, targeting crop insurance for African farmers on Sonic’s EVM-compatible blockchain (10,000 TPS, sub-second finality, FeeM model). This platform automates claims processing with Solidity smart contracts, integrates oracles for weather data, and features a mobile-first UI, aligning with your expertise in Solidity, EVM, and Foundry (per our prior discussions) and Africa’s low insurance penetration (e.g., 3% in Nigeria, per our July 26 chat). Below is a detailed, step-by-step to-do list to complete the project, leveraging your AI agent (assumed to be a coding assistant like GitHub Copilot or a custom tool) to maximize efficiency. The plan covers smart contract development, testing, frontend, deployment, and hackathon submission, optimized for the judging criteria: **technological implementation**, **design**, **potential impact**, and **creativity**.

---

### **Step-by-Step To-Do List for Building the Smart Contract-Based Insurance Platform**

#### **Phase 1: Setup and Planning (Week 1: July 30–August 5, 2025)**  
*Goal*: Initialize the project, set up Foundry, and plan the architecture.  
*AI Agent Role*: Generate boilerplate code, suggest project structure, and provide documentation references.

[done] 1. **Install Foundry**  
   - **To-Do**: Install Foundry on your system (Ubuntu, macOS, or Windows).  
   - **Steps**:  
     - Run: `curl -L https://foundry.paradigm.xyz | bash` to install Foundry.  
     - Update PATH: `source ~/.bashrc` or restart terminal.  
     - Verify: `forge --version` (should output `forge 0.2.0` or later).  
   - **AI Agent**: Ask to generate a shell script to automate installation and PATH setup. Example prompt: “Write a bash script to install Foundry and verify its version.”  
   - **Output**: Foundry installed and ready.

[done] 2. **Initialize Foundry Project**  
   - **To-Do**: Create a new Foundry project for the insurance platform.  
   - **Steps**:  
     - Run: `forge init insurance-platform` to create a project directory.  
     - Navigate: `cd insurance-platform`.  
     - Structure:  
       - `src/`: Smart contracts (e.g., `PolicyContract.sol`).  
       - `test/`: Test files (e.g., `PolicyContract.t.sol`).  
       - `script/`: Deployment scripts (e.g., `Deploy.s.sol`).  
     - Install OpenZeppelin: `forge install OpenZeppelin/openzeppelin-contracts --no-commit`.  
   - **AI Agent**: Request a project structure explanation or generate a README.md. Prompt: “Create a README for a Foundry project called insurance-platform with sections for setup and structure.”  
   - **Output**: Project initialized with dependencies.

[done] 3. **Study Sonic’s Documentation**  
   - **To-Do**: Understand Sonic’s EVM, FeeM model, and Chainlink integration.  
   - **Steps**:  
     - Visit: https://docs.soniclabs.com for EVM setup, RPC endpoints, and FeeM details.  
     - Read Chainlink integration guide for weather data oracles.  
     - Note Sonic’s testnet RPC and chain ID (e.g., testnet chain ID likely 64165, confirm in docs).  
   - **AI Agent**: Summarize Sonic’s docs. Prompt: “Summarize Sonic’s EVM and Chainlink integration in 200 words.”  
   - **Output**: Clear understanding of Sonic’s blockchain.

[done] 4. **Define Architecture**  
   - **To-Do**: Plan smart contracts, oracle integration, and frontend.  
   - **Steps**:  
     - **Contracts**:  
       - `PolicyContract`: Create policies (premium, coverage, duration).  
       - `ClaimsContract`: Automate claims (weather-based payouts).  
       - `TreasuryContract`: Manage funds and FeeM revenue.  
     - **Oracle**: Chainlink for rainfall data (e.g., < 50mm triggers payout).  
     - **Frontend**: React Native mobile app for policy purchase and claims.  
     - Write a spec in `docs/architecture.md` outlining contracts, inputs, and outputs.  
   - **AI Agent**: Generate a spec template. Prompt: “Write a markdown spec for a crop insurance platform with three Solidity contracts and a React Native frontend.”  
   - **Output**: Architecture document in `docs/`.

---

#### **Phase 2: Smart Contract Development (Week 2–3: August 6–19, 2025)**  
*Goal*: Write and test Solidity contracts using Foundry.  
*AI Agent Role*: Generate contract code, test cases, and debug errors.

5. **Write PolicyContract**  
   - **To-Do**: Create a contract for policy creation and management.  
   - **Steps**:  
     - Create `src/PolicyContract.sol`.  
     - Features:  
       - Function to create policies (input: premium, coverage, duration).  
       - Mapping: `address => Policy` (store user policies, per our July 16 mapping chat).  
       - Event: `PolicyCreated(address user, uint256 coverage)`.  
     - Use OpenZeppelin’s `Ownable` for admin controls.  
     - Example (build on this):  
       ```solidity
       // SPDX-License-Identifier: MIT
       pragma solidity ^0.8.20;
       import "@openzeppelin/contracts/access/Ownable.sol";
       struct Policy { uint256 coverage; uint256 premium; uint256 expiry; }
       mapping(address => Policy) public policies;
       function createPolicy(uint256 coverage, uint256 expiry) external payable { /* Logic */ }
       ```
   - **AI Agent**: Generate the full contract. Prompt: “Write a Solidity PolicyContract for crop insurance with a createPolicy function, mapping for policies, and OpenZeppelin Ownable.”  
   - **Output**: `PolicyContract.sol` completed.

6. **Write ClaimsContract**  
   - **To-Do**: Build a contract for automated claims processing.  
   - **Steps**:  
     - Create `src/ClaimsContract.sol`.  
     - Features:  
       - Function: `processClaim()` to check weather data and payout.  
       - Integrate Chainlink: Use `AggregatorV3Interface` for rainfall data.  
       - Event: `ClaimProcessed(address user, uint256 payout, bool approved)`.  
       - Use ReentrancyGuard for security (per our July 26 sample).  
     - Reference our July 26 `ClaimsContract.sol` artifact and expand:  
       - Add policy validation (check expiry, coverage).  
       - Handle multiple claims per policy.  
   - **AI Agent**: Expand the contract. Prompt: “Extend the ClaimsContract.sol from my previous chat with policy validation and multiple claim support, using Chainlink oracles.”  
   - **Output**: `ClaimsContract.sol` completed.

7. **Write TreasuryContract**  
   - **To-Do**: Manage funds and integrate Sonic’s FeeM model.  
   - **Steps**:  
     - Create `src/TreasuryContract.sol`.  
     - Features:  
       - Store premiums and payouts.  
       - Function: `distributeFeeM()` to share transaction fees with policyholders (per Sonic’s docs).  
       - Admin function to fund treasury.  
     - Use OpenZeppelin’s `Pausable` for emergency stops.  
   - **AI Agent**: Generate the contract. Prompt: “Write a Solidity TreasuryContract for an insurance platform with premium storage, FeeM distribution, and Pausable.”  
   - **Output**: `TreasuryContract.sol` completed.

8. **Test Contracts with Foundry**  
   - **To-Do**: Write comprehensive tests for all contracts.  
   - **Steps**:  
     - Create `test/PolicyContract.t.sol`, `test/ClaimsContract.t.sol`, `test/TreasuryContract.t.sol`.  
     - Test cases:  
       - Policy creation succeeds/fails (e.g., insufficient premium).  
       - Claims payout only when rainfall < 50mm (mock oracle data).  
       - Treasury distributes FeeM correctly.  
       - Reentrancy attacks fail.  
     - Use Foundry’s `vm.prank` for user simulation and `vm.mockCall` for oracle mocks.  
     - Run: `forge test --match-path test/*.t.sol --gas-report`.  
   - **AI Agent**: Generate test files. Prompt: “Write Foundry test files for PolicyContract, ClaimsContract, and TreasuryContract with at least 5 test cases each, including oracle mocks.”  
   - **Output**: Test files with 90%+ coverage.

9. **Integrate Chainlink Oracle**  
   - **To-Do**: Connect ClaimsContract to Chainlink for weather data.  
   - **Steps**:  
     - Install Chainlink: `forge install chainlink/contracts --no-commit`.  
     - Configure `ClaimsContract.sol` to use `AggregatorV3Interface`.  
     - Mock oracle in tests: Use Foundry’s `vm.mockCall` to simulate rainfall data.  
     - Verify Sonic’s Chainlink support in docs (https://docs.soniclabs.com).  
   - **AI Agent**: Provide integration code. Prompt: “Generate Solidity code to integrate Chainlink weather data into ClaimsContract with mock tests in Foundry.”  
   - **Output**: Oracle-integrated `ClaimsContract.sol`.

---

#### **Phase 3: Frontend Development (Week 4: August 20–26, 2025)**  
*Goal*: Build a mobile-first React Native UI for African farmers.  
*AI Agent Role*: Generate UI components, Web3.js integration, and styling.

10. **Set Up React Native Project**  
    - **To-Do**: Initialize a mobile app for policy purchase and claims.  
    - **Steps**:  
      - Install Node.js and Expo CLI: `npm install -g expo-cli`.  
      - Create project: `npx create-expo-app insurance-app`.  
      - Install dependencies: `npm install ethers web3 react-native-tailwindcss`.  
      - Run: `expo start` to test on your phone via Expo Go.  
    - **AI Agent**: Generate setup commands. Prompt: “Write a bash script to set up a React Native Expo project with Ethers.js and Tailwind CSS.”  
    - **Output**: `insurance-app` directory ready.

11. **Build UI Components**  
    - **To-Do**: Create screens for policy purchase, claims, and dashboard.  
    - **Steps**:  
      - Create `screens/PolicyScreen.js`: Form for coverage, duration, and premium payment.  
      - Create `screens/ClaimsScreen.js`: Button to submit claims and show status.  
      - Create `screens/DashboardScreen.js`: Display active policies and claim history.  
      - Use Tailwind CSS for styling (e.g., dark theme, per our April 24 PayStell chat).  
      - Add multilingual support (e.g., Swahili, Yoruba) with `i18n-js`.  
    - **AI Agent**: Generate components. Prompt: “Create React Native components for a crop insurance app with PolicyScreen, ClaimsScreen, and DashboardScreen, styled with Tailwind CSS and i18n support.”  
    - **Output**: UI components in `screens/`.

12. **Integrate with Sonic Blockchain**  
    - **To-Do**: Connect the UI to smart contracts using Ethers.js.  
    - **Steps**:  
      - Configure Ethers.js in `utils/web3.js` with Sonic’s testnet RPC.  
      - Functions:  
        - `createPolicy`: Call `PolicyContract.createPolicy` with user inputs.  
        - `processClaim`: Call `ClaimsContract.processClaim`.  
        - `getPolicy`: Query user’s policy details.  
      - Example:  
        ```javascript
        import { ethers } from 'ethers';
        const provider = new ethers.providers.JsonRpcProvider('SONIC_RPC_URL');
        const policyContract = new ethers.Contract(ADDRESS, ABI, provider);
        async function createPolicy(coverage, expiry) { /* Call contract */ }
        ```
    - **AI Agent**: Generate Web3 integration. Prompt: “Write Ethers.js code to connect a React Native app to PolicyContract and ClaimsContract on Sonic’s testnet.”  
    - **Output**: Web3 integration in `utils/`.

13. **Add M-Pesa Integration (Mock)**  
    - **To-Do**: Simulate M-Pesa payments for premiums (real integration requires APIs).  
    - **Steps**:  
      - Create a mock oracle in `ClaimsContract.sol` to convert M-Pesa payments to S tokens.  
      - Add a UI button in `PolicyScreen.js` to “Pay with M-Pesa” (simulates API call).  
      - Test flow: User clicks “Pay,” UI shows “Payment Confirmed,” contract creates policy.  
    - **AI Agent**: Generate mock code. Prompt: “Create a mock M-Pesa oracle in Solidity and a React Native button to simulate payments.”  
    - **Output**: Mock M-Pesa flow.

---

#### **Phase 4: Deployment and Testing (Week 5: August 27–September 2, 2025)**  
*Goal*: Deploy contracts to Sonic testnet, test end-to-end, and prepare demo.  
*AI Agent Role*: Generate deployment scripts, debug issues, and create demo script.

14. **Deploy Contracts to Sonic Testnet**  
    - **To-Do**: Deploy contracts using Foundry.  
    - **Steps**:  
      - Create `script/Deploy.s.sol`:  
        ```solidity
        // SPDX-License-Identifier: MIT
        pragma solidity ^0.8.20;
        import "forge-std/Script.sol";
        import "../src/PolicyContract.sol";
        contract Deploy is Script {
            function run() external {
                vm.startBroadcast();
                new PolicyContract();
                vm.stopBroadcast();
            }
        }
        ```
      - Configure `foundry.toml` with Sonic’s testnet RPC and chain ID.  
      - Run: `forge script script/Deploy.s.sol --rpc-url <SONIC_RPC> --private-key <YOUR_KEY> --broadcast`.  
      - Verify contracts on Sonic’s block explorer (if available).  
    - **AI Agent**: Generate deployment script. Prompt: “Write a Foundry deployment script for PolicyContract, ClaimsContract, and TreasuryContract on Sonic’s testnet.”  
    - **Output**: Contracts deployed.

15. **End-to-End Testing**  
    - **To-Do**: Test the full flow from policy creation to claim payout.  
    - **Steps**:  
      - Test backend: Use Foundry to simulate policy creation, oracle data, and claims.  
      - Test frontend: Run `expo start`, connect to testnet, and verify UI interactions.  
      - Flow:  
        - User creates policy via UI.  
        - Mock oracle reports low rainfall.  
        - User submits claim, receives payout.  
      - Fix bugs using Foundry’s debug tools (`forge test --debug`).  
    - **AI Agent**: Debug test failures. Prompt: “Analyze Foundry test logs and suggest fixes for a failing claim payout test.”  
    - **Output**: Bug-free end-to-end flow.

16. **Record Demo Video**  
    - **To-Do**: Create a 3-minute demo video for submission.  
    - **Steps**:  
      - Script:  
        - Intro: “Crop insurance dApp for African farmers on Sonic.”  
        - Demo: Show policy purchase, claim submission, and payout.  
        - Outro: Highlight Sonic’s speed and African impact.  
      - Record: Use screen recording (e.g., OBS Studio) and phone emulator.  
      - Edit: Add captions for Swahili/Yoruba using CapCut.  
      - Upload: YouTube or Google Drive (private link).  
    - **AI Agent**: Generate script. Prompt: “Write a 3-minute demo video script for a crop insurance dApp on Sonic, emphasizing African impact.”  
    - **Output**: Demo video ready.

---

#### **Phase 5: Submission and Promotion (Week 6: September 3–10, 2025)**  
*Goal*: Submit to DoraHacks, promote on X, and engage with the community.  
*AI Agent Role*: Generate submission text, X posts, and community responses.

17. **Submit to DoraHacks**  
    - **To-Do**: Create a BUIDL on DoraHacks.  
    - **Steps**:  
      - Register: https://dorahacks.io/hackathon/sonic-s-tier/detail.  
      - Create BUIDL: Fill in:  
        - Title: “Crop Insurance Platform for African Farmers”.  
        - Description: Explain African impact, Sonic integration, and tech stack.  
        - Track: DeFi/Sustainability.  
        - Links: GitHub repo, demo video, X post.  
      - Upload: Public GitHub repo with `src/`, `test/`, `insurance-app/`, and README.  
      - Submit by: August 31, 2025.  
    - **AI Agent**: Draft submission. Prompt: “Write a DoraHacks BUIDL description for a crop insurance dApp on Sonic, 300 words, DeFi/Sustainability track.”  
    - **Output**: BUIDL submitted.

18. **Promote on X**  
    - **To-Do**: Share your project to boost visibility (per your love for X posts, July 16).  
    - **Steps**:  
      - Post:  
        ```markdown
        🌍 Built a crop insurance dApp for African farmers on Sonic’s EVM! Automated claims with Solidity & Foundry, powered by low fees. Aiming for the $100K Sonic S-Tier Hackathon! Join me? 🚜 #SonicHackathon #Web3 #AfricaTech
        ```
      - Tag: @Sonic_Labs, @dorahacksofficial.  
      - Engage: Reply to comments, share updates (e.g., demo link).  
    - **AI Agent**: Generate additional posts. Prompt: “Create 3 X posts to promote a crop insurance dApp for Sonic S-Tier Hackathon, each under 280 characters.”  
    - **Output**: X post live with engagement.

19. **Engage with Sonic Community**  
    - **To-Do**: Get feedback and find teammates (if needed).  
    - **Steps**:  
      - Join: Sonic’s Telegram (@segfault0x).  
      - Post: Share project overview, ask for UI/contract feedback.  
      - Contact: Seg (seg@soniclabs.com) for DevRel support.  
      - Optional: Find African teammates via Hackathon Africa (https://hackathon.africa).  
    - **AI Agent**: Draft community messages. Prompt: “Write a Telegram message to Sonic’s hackathon group introducing my crop insurance dApp and asking for feedback.”  
    - **Output**: Community feedback incorporated.

20. **Polish and Finalize**  
    - **To-Do**: Address feedback and ensure polish.  
    - **Steps**:  
      - Fix bugs from community feedback (use AI agent for debugging).  
      - Optimize UI: Ensure multilingual support and offline caching.  
      - Update README: Add setup, deployment, and demo instructions.  
      - Re-test: Run `forge test` and UI tests to confirm stability.  
    - **AI Agent**: Suggest improvements. Prompt: “Review my crop insurance dApp’s README and suggest enhancements for clarity and completeness.”  
    - **Output**: Polished project ready for judging.

---

### **How to Use Your AI Agent Effectively**
- **Prompts**: Be specific (e.g., “Generate a Solidity contract with X feature” vs. “Write code”). Include context from our chats (e.g., “Use mappings for storage, per our July 16 discussion”).  
- **Debugging**: Feed error logs to the agent (e.g., “Fix this Foundry test failure: [log]”).  
- **Optimization**: Ask for gas optimization tips (e.g., “Optimize this contract for Sonic’s EVM”).  
- **UI**: Request component templates (e.g., “Generate a React Native form with Tailwind CSS”).  
- **Iteration**: Use the agent to refine code/UI based on community feedback (e.g., “Update this contract with Telegram suggestions”).  

---

### **Winning Strategy**
- **Technological Implementation**: Use Foundry’s gas profiler and Chainlink for robust, efficient contracts. Achieve 90%+ test coverage.  
- **Design**: Prioritize a mobile-first, multilingual UI for African farmers, with offline support for rural areas.  
- **Impact**: Highlight how crop insurance empowers unbanked farmers (70% of Africans in agriculture), reducing climate risks.  
- **Creativity**: Differentiate with M-Pesa integration and Sonic’s FeeM model, rare in hackathons (per our July 26 analysis).  
- **Judges’ Appeal**: Demo Sonic’s speed (< 1s claims) and African relevance in your video.

---

### **Final Notes**
- **Timeline**: Follow the six-week plan to meet the August 31 deadline. Start with Foundry setup and PolicyContract today.  
- **AI Agent**: Use it for code generation, testing, and debugging to save time. Feed it our chat context for accuracy.  
- **African Edge**: Emphasize crop insurance for smallholder farmers and M-Pesa integration to stand out.  
- **Support**: Reach out to Sonic’s DevRel (@segfault0x) or me for code snippets, UI templates, or X post tweaks.  

You’re set to crush the Sonic S-Tier Hackathon! Need a specific Solidity snippet, Foundry test, or React Native component? Let me know, and I’ll provide it. Good luck! 🚀