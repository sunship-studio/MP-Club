const WhatsIncludedItem = ({ icon, text }: { icon: string; text: string }) => {
  return (
    <div className="flex flex-row items-center">
      <div className="rounded-full w-9 h-9 md:w-12 md:h-12 bg-white items-center justify-center shadow-sm shadow-white/50 flex">
        <img
          src={`/assets/online-coaching/${icon}.png`}
          alt={text}
          className="w-5.5 h-5.5 md:w-6.5 md:h-6.5"
        />
      </div>
      <p className="text-left text-xl ml-2 font-bold">{text}</p>
    </div>
  );
};

const WhatsIncluded = () => {
  const items = [
    { icon: "1", text: "Weekly Check-Ins" },
    { icon: "2", text: "Progress Tracking" },
    { icon: "3", text: "Video Feedback" },
    { icon: "4", text: "Custom workouts" },
    { icon: "5", text: "Nutrition plans" },
  ];
  return (
    <div className="flex flex-col items-start justify-start w-full ">
      <h2 className="text-left font-bold text-2xl mb-2">What's Included:</h2>
      <div className="flex flex-col w-full space-y-3 md:hidden">
        {items.map((item, index) => (
          <WhatsIncludedItem key={index} icon={item.icon} text={item.text} />
        ))}
      </div>
      {/* Desktop version row with colum 3/2*/}
      <div className="hidden md:flex flex-row w-full space-x-8 mt-4">
            <div className="flex flex-col w-full space-y-3">
                {items.slice(0, 3).map((item, index) => (
                    <WhatsIncludedItem key={index} icon={item.icon} text={item.text} />
                ))}
            </div>
            <div className="flex flex-col w-full space-y-3">
                {items.slice(3).map((item, index) => (
                    <WhatsIncludedItem key={index} icon={item.icon} text={item.text} />
                ))} 
            </div>
      </div>
    </div>
  );
};

export default WhatsIncluded;
