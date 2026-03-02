"use client";

import BorrowForm from "@/components/BorrowForm";
import ConnectWallet from "@/components/ConnectWallet";
import DepositForm from "@/components/DepositForm";
import HealthFactor from "@/components/HealthFactor";



export default function Dashboard() {
  return (
    <div className="min-h-screen p-10">
      <h1 className="text-4xl font-bold mb-8 text-blue-400">
        Mini Aave Dashboard
      </h1>

        <ConnectWallet/>
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <DepositForm />
        <BorrowForm />
        <HealthFactor />
      </div>
    </div>
  );
}