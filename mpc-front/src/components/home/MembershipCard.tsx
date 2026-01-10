'use client';
import { useRouter } from 'next/navigation';

const MembershipCard = ({
  title,
  points,
  option,
}: {
  title: string;
  points: string[];
  option: number;
}) => {
  const router = useRouter();

  const getCardStyles = () => {
    if (option === 0) return 'bg-[#0B79AB] text-white border-[#0B79AB]';
    if (option === 2) return 'bg-[#141414] text-white border-[#141414]';
    return 'bg-white text-black border-gray-200';
  };

  const getButtonStyles = () => {
    if (option === 0)
      return 'bg-white text-[#0B79AB] hover:bg-gray-100 shadow-lg';
    if (option === 2)
      return 'bg-[#0B79AB] text-white hover:bg-[#0b78ab9e] shadow-lg';
    return 'bg-[#0B79AB] text-white hover:bg-[#0b78ab9e] shadow-lg';
  };

  const handleClick = () => {
    if (option === 0) {
      router.push('/waiting-list');
    } else if (option === 1) {
      router.push('/online-coaching');
    } else if (option === 2) {
      router.push('/group-classes');
    }
  };

  return (
    <div
      className={`${getCardStyles()} rounded-2xl p-8 shadow-xl border-2
                  transition-all duration-300 hover:scale-105 hover:shadow-2xl
                  flex flex-col h-full min-h-[400px]`}
    >
      {/* Header */}
      <div className="mb-6">
        <h3 className="text-2xl font-bold mb-2">{title}</h3>
        <div
          className={`h-1 w-16 rounded-full ${
            option === 0
              ? 'bg-white'
              : option === 2
                ? 'bg-[#0B79AB]'
                : 'bg-[#0B79AB]'
          }`}
        ></div>
      </div>

      {/* Features List */}
      <ul className="space-y-3 mb-8 flex-grow">
        {points.map((point, idx) => (
          <li key={idx} className="flex items-start gap-3">
            <svg
              className={`w-5 h-5 mt-0.5 shrink-0 ${
                option === 0
                  ? 'text-white'
                  : option === 2
                    ? 'text-[#0B79AB]'
                    : 'text-[#0B79AB]'
              }`}
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path
                fillRule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
                clipRule="evenodd"
              />
            </svg>
            <span className="text-sm leading-relaxed">{point}</span>
          </li>
        ))}
      </ul>

      {/* CTA Button */}
      <button
        className={`${getButtonStyles()} w-full py-4 rounded-lg font-bold text-base
                   transition-all duration-200 transform hover:scale-105 active:scale-100`}
        onClick={handleClick}
      >
        {option === 2 ? 'Book Now' : 'Get Started'} →
      </button>

      {/* Learn More Link */}
      <a
        onClick={() => {
          if (option === 0) {
            router.push('/waiting-list');
          } else if (option === 2) {
            router.push('/group-classes');
          } else router.push('/online-coaching');
        }}
        className={`text-center mt-4 text-sm font-semibold hover:underline ${
          option === 0 || option === 2 ? 'text-gray-300' : 'text-gray-600'
        }`}
      >
        Learn more
      </a>
    </div>
  );
};

export default MembershipCard;
