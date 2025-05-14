'use client'
import apiService from "@/services/api.service";
import { useSearchParams } from "next/navigation";
import { useEffect } from "react";

const CancelOnlineCoaching = () => {
  const searchParams = useSearchParams();

  useEffect(() => {
    const token = searchParams.get("token");

    if (!token) {
      return;
    }

    // Function to process the cancellation
    const processCancellation = async () => {
      try {
        apiService.post<{}>("/online-coaching/confirm_cancel", {
          token,
        });
      } catch (error) {
        console.error("Error cancelling subscription:", error);
      }
    };

    // Process the cancellation when the component mounts
    processCancellation();
  }, [searchParams]);
  return (
    <div className="flex flex-col items-center justify-center mt-10">
      <h1 className="text-4xl font-bold mb-4 text-center">Cancel Online Coaching</h1>
      <p className="text-lg text-center">
        Your online coaching has been successfully canceled.
      </p>
    </div>
  );
};

export default CancelOnlineCoaching;
