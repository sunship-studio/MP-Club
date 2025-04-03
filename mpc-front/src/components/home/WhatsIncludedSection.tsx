import FeatureCard from "./FeatureCard";

const WhatsIncludedSection = () => {
    const features = [
        {
            image: "/assets/home/main_1.png",
            title: "Personalized workouts & nutrition plans",
            description: "Tailored training and diet strategies designed to fit your goals, lifestyle, and body type for optimal results."
        },
        {
            image: "/assets/home/main_2.png",
            title: "In-gym guidance & technique corrections",
            description: "In-depth coaching sessions focused on technique, strength progression, and maximizing your training efficiency."
        },
        {
            image: "/assets/home/main_3.png",
            title: "Performance tracking & injury prevention",
            description: "Smart programming and recovery protocols to keep you strong, mobile, and injury-free."
        },

    ]
    const online_features = [
        {
            image: "/assets/home/main_4.png",
            title: "Custom workouts you can do anywhere",
            description: "Structured training plans designed for your home, gym, or travel setup."
        },
        {
            image: "/assets/home/main_5.png",
            title: "Weekly Check-Ins & Progress Tracking",
            description: "Stay accountable with regular updates, program adjustments, and expert guidance."
        },
        {
            image: "/assets/home/main_6.png",
            title: "Video Feedback on Form & Technique",
            description: "Submit your lifts for analysis to ensure proper execution and long-term improvement."
        },]

    return (<>
        <h1 className="text-3xl md:text-3xl font-semibold mb-8">What's included</h1>

        {/* For Mobiles */}
        <div className="md:hidden space-y-6">
            {/* Top row with two cards - for mobile and tablet only */}
            <div className="grid grid-cols-2 gap-6">
                <FeatureCard image={features[0].image} title={features[0].title} description={features[0].description} />
                <FeatureCard image={features[1].image} title={features[1].title} description={features[1].description} />
            </div>

            {/* Bottom row with single card - for mobile and tablet only */}
            <div className="flex justify-center items-center">
                <div className="w-full mx-auto max-w-2xl">
                    <FeatureCard image={features[2].image} title={features[2].title} description={features[2].description} row={false} />
                </div>
            </div>
            <h2 className="text-2xl font-semibold">Online coaching</h2>
            {/* Top row with two cards - for mobile and tablet only */}
            <div className="grid grid-cols-2 gap-6">
                <FeatureCard image={online_features[0].image} title={online_features[0].title} description={online_features[0].description} />
                <FeatureCard image={online_features[1].image} title={online_features[1].title} description={online_features[1].description} />
            </div>

            {/* Bottom row with single card - for mobile and tablet only */}
            <div className="flex justify-center items-center">
                <div className="w-full mx-auto max-w-2xl">
                    <FeatureCard image={online_features[2].image} title={online_features[2].title} description={online_features[2].description} row={false} />
                </div>
            </div>

        </div>
        {/* For Desktops */}
        <div className="hidden md:block space-y-6">
            <div className="grid grid-cols-3 gap-6">

                {features.map((feature, index) => (
                    <FeatureCard key={index} image={feature.image} title={feature.title} description={feature.description} />
                ))} </div>
            <h2 className="text-2xl lg:text-3xl font-semibold">Online coaching</h2>
            <div className="grid grid-cols-3 gap-6">

                {online_features.map((feature, index) => (
                    <FeatureCard key={index} image={feature.image} title={feature.title} description={feature.description} />
                ))} </div>

        </div></>)
}


export default WhatsIncludedSection