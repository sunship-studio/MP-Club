import BuyButton from '@/components/online-coaching/BuyButton';
import StepsTimeline from '@/components/online-coaching/StepsTimeline';
import WhatsIncluded from '@/components/online-coaching/WhatsIncluded';

const OnlineCoaching = () => {
  return (
    <div className="max-w-7xl mx-auto px-8 md:px-16 py-12">
      {/* Hero Section */}
      <div className="text-center mb-12">
        <h1 className="text-4xl md:text-5xl font-bold mb-4 text-white">
          Online Coaching 📲
        </h1>
        <p className="text-lg md:text-xl text-gray-200 max-w-3xl mx-auto">
          Unlock personalized coaching, exclusive content, custom meal programs
          and more.{' '}
          <span className="font-bold text-white">
            Start your transformation today!
          </span>
        </p>
      </div>

      {/* How It Works Section */}
      <div className="mb-16">
        <h2 className="text-3xl font-bold text-center mb-8 text-white">
          How It Works
        </h2>
        <StepsTimeline />
      </div>

      {/* Main Content Grid */}
      <div className="grid md:grid-cols-3 gap-8 mb-16">
        {/* What's Included Section - Takes 2 columns */}
        <div className="md:col-span-2">
          <WhatsIncluded />
        </div>

        {/* Pricing Card - Takes 1 column */}
        <div className="md:col-span-1">
          <BuyButton />
        </div>
      </div>

      {/* Benefits Section */}
      <div className="grid md:grid-cols-3 gap-6">
        <div className="bg-white/10 backdrop-blur rounded-lg p-6 text-center">
          <div className="text-4xl mb-3">💪</div>
          <h3 className="font-semibold text-lg mb-2 text-white">
            Expert Guidance
          </h3>
          <p className="text-gray-200 text-sm">
            Get personalized coaching from certified fitness professionals
          </p>
        </div>
        <div className="bg-white/10 backdrop-blur rounded-lg p-6 text-center">
          <div className="text-4xl mb-3">📊</div>
          <h3 className="font-semibold text-lg mb-2 text-white">
            Track Progress
          </h3>
          <p className="text-gray-200 text-sm">
            Monitor your transformation with detailed analytics and insights
          </p>
        </div>
        <div className="bg-white/10 backdrop-blur rounded-lg p-6 text-center">
          <div className="text-4xl mb-3">🎯</div>
          <h3 className="font-semibold text-lg mb-2 text-white">
            Achieve Goals
          </h3>
          <p className="text-gray-200 text-sm">
            Custom plans designed to help you reach your fitness targets
          </p>
        </div>
      </div>
    </div>
  );
};

export default OnlineCoaching;
