import BuyButton from "@/components/online-coaching/BuyButton";
import StepsTimeline from "@/components/online-coaching/StepsTimeline";
import WhatsIncluded from "@/components/online-coaching/WhatsIncluded";

const OnlineCoaching = () => {
  return (
    <div className="flex flex-col items-center justify-start px-5 md:w-full">
      <h1 className="text-3xl font-bold mt-6">Online Coaching</h1>
      <span className="md:hidden text-lg font-medium text-center mb-3">
        Unlock personalized coaching, exclusive content, custom meal programs
        and more. <br />
        <p className="font-bold">Start your transformation today!</p>
      </span>
      <div className="flex flex-col md:hidden space-y-4">
        {" "}
        <WhatsIncluded />
        <BuyButton />
        <StepsTimeline />
      </div>
      <div className=" flex-col w-full p-8 hidden md:flex">
        <StepsTimeline />
        <div className="hidden md:flex flex-row justify-between items-center w-full mt-4">
          <div className="w-2/3">
            <WhatsIncluded />
          </div>
          <div className="w-1/3 flex flex-col items-center justify-center">
            <BuyButton />
          </div>
        </div>
      </div>
    </div>
  );
};

export default OnlineCoaching;
