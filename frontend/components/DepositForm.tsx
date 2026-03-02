"use client";

import { useState } from "react";
import { useWriteContract } from "wagmi";
import LendingPoolABI from "../abis/LendingPool.json";
import { LENDING_POOL_ADDRESS } from "../config/contracts";

export default function DepositForm() {
  const [amount, setAmount] = useState("");

  const { writeContract } = useWriteContract();

  const handleDeposit = async () => {
    writeContract({
      address: LENDING_POOL_ADDRESS,
      abi: LendingPoolABI.abi,
      functionName: "deposit",
      args: [BigInt(amount)],
    });
  };

  return (
    <div className="bg-slate-800 p-6 rounded-xl shadow-lg">
      <h2 className="text-xl mb-4">Deposit Collateral</h2>

      <input
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        className="w-full p-2 mb-4 bg-slate-700 rounded "
      />

      <button
        onClick={handleDeposit}
        className="bg-blue-500 w-full p-2 cursor-pointer rounded"
      >
        Deposit
      </button>
    </div>
  );
}