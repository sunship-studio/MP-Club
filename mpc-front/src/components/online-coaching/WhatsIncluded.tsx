const WhatsIncludedItem = ({ icon, text }: {
    icon: string;
    text: string;
}) => {
    return (
        <div className="flex flex-row items-center">
            <div className="rounded-full w-10 h-10 bg-white items-center justify-center shadow-sm shadow-white/50 flex">
                <img src={`/assets/online-coaching/${icon}.png`} alt={text} className="w-6 h-6" />

            </div>
            <p className="text-left text-xl ml-4 font-bold">{text}</p>
        </div>
    )
}

const WhatsIncluded = () => {
    const items = [
        { icon: "1", text: "Weekly Check-Ins" },
        { icon: "2", text: "Progress Tracking" },
        { icon: "3", text: "Video Feedback" },
        { icon: "4", text: "Custom workouts" },
        { icon: "5", text: "Nutrition plans" },

    ];
    return (
        <div className="flex flex-col items-start justify-start h-screen w-full mt-6">
            <h2 className="text-left font-extrabold text-2xl mb-2">What's Included:</h2>
            <div className="flex flex-col w-full space-y-3">
                {items.map((item, index) => (
                    <WhatsIncludedItem key={index} icon={item.icon} text={item.text} />
                ))}

            </div>
            
        </div>
    )
}

export default WhatsIncluded;