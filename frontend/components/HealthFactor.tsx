"use client";

import { useAccount, useReadContract } from "wagmi";
import LendingPoolABI from "../abis/LendingPool.json";
import { LENDING_POOL_ADDRESS } from "../config/contracts";

export default function HealthFactor() {
  const { address } = useAccount();

  const { data } = useReadContract({
    address: LENDING_POOL_ADDRESS,
    abi: LendingPoolABI.abi,
    functionName: "getHealthFactor",
    args: [address],
  });

  return (
    <div className="bg-slate-800 p-6 rounded-xl">
      <h2 className="text-xl mb-4">Health Factor</h2>
      <p className="text-2xl text-yellow-400">
        {data?.toString() ?? "--"}
      </p>
    </div>
  );
}