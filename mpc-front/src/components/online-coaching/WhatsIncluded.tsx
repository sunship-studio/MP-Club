const WhatsIncludedItem = ({ icon, text }: { icon: string; text: string }) => {
  return (
    <div className="flex items-center p-0 bg-white/5 rounded-lg hover:bg-white/10 transition-all border border-white/10">
      <div className="rounded-full w-12 h-12 bg-[#0B79AB] items-center justify-center shadow-lg flex shrink-0">
        <img
          src={`/assets/online-coaching/${icon}.png`}
          alt={text}
          className="w-6 h-6"
        />
      </div>
      <p className="text-left text-lg ml-4 font-semibold text-black">{text}</p>
    </div>
  );
};

const WhatsIncluded = () => {
  const items = [
    { icon: '5', text: 'Personal Mobile App' },
    { icon: '1', text: 'Check-Ins' },
    { icon: '2', text: 'Progress Tracking' },
    { icon: '3', text: 'Video Tutorials' },
    { icon: '4', text: 'Custom Training Plan' },
  ];

  return (
    <div className="bg-white rounded-lg shadow-xl p-8 md:p-8 h-full">
      <h2 className="text-2xl md:text-3xl font-bold mb-6 text-black">
        What's Included
      </h2>
      <div className="grid grid-cols-1 gap-3 text-black">
        {items.map((item, index) => (
          <WhatsIncludedItem key={index} icon={item.icon} text={item.text} />
        ))}
      </div>
    </div>
  );
};

export default WhatsIncluded;
