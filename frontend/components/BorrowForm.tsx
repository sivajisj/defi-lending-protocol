"use client";

import { useState } from "react";
import { useWriteContract } from "wagmi";
import LendingPoolABI from "../abis/LendingPool.json";
import { LENDING_POOL_ADDRESS } from "../config/contracts";

export default function BorrowForm() {
  const [amount, setAmount] = useState("");

  const { writeContract } = useWriteContract();

  const handleBorrow = async () => {
    writeContract({
      address: LENDING_POOL_ADDRESS,
      abi: LendingPoolABI.abi,
      functionName: "borrow",
      args: [BigInt(amount)],
    });
  };

  return (
    <div className="bg-slate-800 p-6 rounded-xl shadow-lg">
      <h2 className="text-xl mb-4">Borrow Stablecoin</h2>

      <input
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        className="w-full p-2 mb-4 bg-slate-700 rounded"
      />

      <button
        onClick={handleBorrow}
        className="bg-green-500 w-full cursor-pointer p-2 rounded"
      >
        Borrow
      </button>
    </div>
  );
}