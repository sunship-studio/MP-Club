import WhatsIncluded from "@/components/online-coaching/WhatsIncluded";

const OnlineCoaching = () => {
    return (
        <div className="flex flex-col items-center justify-start px-5">
            <h1 className="text-3xl font-extrabold mt-6">Online Coaching</h1>
            <p className="text-xl mt-4 font-medium text-center">Unlock personalized coaching, exclusive content, custom meal programs and more. <br /><p className="font-bold">Start your transformation today!</p></p>
            <WhatsIncluded />
        </div>
    );
}

export default OnlineCoaching;