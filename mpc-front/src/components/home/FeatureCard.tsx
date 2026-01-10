const FeatureCard = ({
  title,
  description,
  image,
}: {
  image: string;
  description: string;
  title: string;
}) => (
  <div
    className="group bg-white rounded-2xl p-6 shadow-xl hover:shadow-2xl
               transition-all duration-300 hover:scale-105 hover:border-[#0B79AB]
               border-2 border-transparent flex flex-col h-full"
  >
    {/* Icon */}
    <div className="mb-4 flex justify-center">
      <div className="rounded-xl  px-4  group-hover:bg-[#0B79AB]/20 transition-colors">
        <img src={image} className="w-16 h-16 object-contain" alt={title} />
      </div>
    </div>

    {/* Title */}
    <h3 className="text-lg font-bold mb-3 text-gray-900 leading-tight">
      {title}
    </h3>

    {/* Description */}
    <p className="text-sm text-gray-600 leading-relaxed flex-grow">
      {description}
    </p>

    {/* Explore Link */}
    <div className="mt-4 pt-4 border-t border-gray-100">
      <div className="flex items-center gap-2 text-[#0B79AB] font-semibold text-sm group-hover:gap-3 transition-all">
        <span>Explore</span>
        <svg
          className="w-4 h-4 transform group-hover:translate-x-1 transition-transform"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M9 5l7 7-7 7"
          />
        </svg>
      </div>
    </div>
  </div>
);

export default FeatureCard;
