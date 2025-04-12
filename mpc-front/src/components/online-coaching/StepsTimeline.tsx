const StepsTimeline = () => {
  const steps = [
    {
      image: "/assets/online-coaching/steps/1.png",
      title: "Sign Up",
      description:
        "Subscribe and provide your details to get started on your personalized journey.",
    },
    {
      image: "/assets/online-coaching/steps/2.png",
      title: "Receive workouts",
      description:
        "Get a tailored Excel sheet with detailed sets, reps, and instructions for every exercise.",
    },
    {
      image: "/assets/online-coaching/steps/3.png",
      title: "Nutrition",
      description:
        "Follow a custom meal plan designed to meet your goals and keep you fueled.",
    },
    {
      image: "/assets/online-coaching/steps/4.png",
      title: "Get Feedback & Adjustments",
      description:
        "Receive ongoing support and program adjustments based on your progress.",
    },
    {
      image: "/assets/online-coaching/steps/5.png",
      title: "Train",
      description:
        "Put it all into practice, track your progress, and watch your transformation unfold.",
    },
  ];
  return (
    <div className="text-white p-2 md:mt-4 w-full">
      {/* Make this container full width and use space-between */}
      <div className="max-w-2xl mx-auto md:max-w-none md:w-full md:flex md:flex-row md:justify-between md:px-8">
        {steps.map((step, index) => (
          <div
            key={index}
            className="flex mb-2 md:mb-0 md:flex-col md:items-center md:flex-1 relative"
          >
            {/* Icon */}
            <div className="relative flex flex-col items-center mr-4 md:mr-0 md:mb-2" >
              <div className="rounded-full w-12 h-12 md:w-18 md:h-18  bg-white items-center justify-center shadow-md shadow-white/50 flex p-2 z-10">
                <img
                  src={step.image}
                  alt={`Step ${index + 1}`}
                  className="w-8 h-8"
                />
              </div>
              {/* Vertical dotted line for mobile */}
              {index !== steps.length - 1 && (
                <div className="relative h-full mt-1 md:hidden">
                  <div className="hidden md:block absolute top-6 left-1/2 w-full h-0.5 z-0">
                    <div className="w-full h-full flex flex-row justify-around">
                      {Array.from({ length: 12 }).map((_, i) => (
                        <div
                          key={i}
                          className="w-0.5 h-0.5 rounded-full bg-blue-300 opacity-60"
                        />
                      ))}
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Content */}
            <div className="pt-1 md:text-center md:max-w-[200px]">
              <h3 className="text-xl font-bold mb-1">{step.title}</h3>
              <p className="text-blue-100 opacity-90 mb-5">
                {step.description}
              </p>
            </div>

            {/* Horizontal line for md screens */}
            {index !== steps.length - 1 && (
              <div className="hidden md:block absolute top-10 right-0 w-full h-0.5 z-0 translate-x-1/2">
                <div className="w-full h-full flex flex-row justify-around">
                    {Array.from({ length: 12 }).map((_, i) => (
                        <div
                        key={i}
                        className="w-0.5 h-0.5 rounded-full bg-blue-300 opacity-60"
                        />
                    ))}
                </div>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};

export default StepsTimeline;
