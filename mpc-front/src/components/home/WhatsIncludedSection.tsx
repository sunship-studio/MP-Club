import FeatureCard from './FeatureCard';

const WhatsIncludedSection = () => {
  const features = [
    {
      image: '/assets/home/main_1.png',
      title: '💪 Personalized workouts & nutrition plans',
      description:
        'Tailored training and diet strategies designed to fit your goals, lifestyle, and body type for optimal results.',
    },
    {
      image: '/assets/home/main_2.png',
      title: '🏋️ In-gym guidance & technique corrections',
      description:
        'In-depth coaching sessions focused on technique, strength progression, and maximizing your training efficiency.',
    },
    {
      image: '/assets/home/main_3.png',
      title: '📊 Performance tracking & injury prevention',
      description:
        'Smart programming and recovery protocols to keep you strong, mobile, and injury-free.',
    },
  ];

  const online_features = [
    {
      image: '/assets/home/main_6.png',
      title: '📱 Personalized mobile app',
      description:
        'Get a tailored mobile app where you can train based on your custom plan, contact your coach, and track progress.',
    },
    {
      image: '/assets/home/main_4.png',
      title: '🌍 Custom workouts you can do anywhere',
      description:
        'Structured training plans designed for your home, gym, or travel setup.',
    },
    {
      image: '/assets/home/main_5.png',
      title: '📈 Weekly Check-Ins & Progress Tracking',
      description:
        'Stay accountable with regular updates, program adjustments, and expert guidance.',
    },
  ];

  return (
    <section className="space-y-16">
      {/* 1-on-1 Coaching Features */}
      <div>
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold mb-4 text-white">
            What's Included
          </h2>
          <p className="text-gray-300 max-w-2xl mx-auto">
            Everything you need to achieve your fitness goals
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {features.map((feature, index) => (
            <FeatureCard
              key={index}
              image={feature.image}
              title={feature.title}
              description={feature.description}
            />
          ))}
        </div>
      </div>

      {/* Online Coaching Features */}
      <div>
        <div className="text-center mb-12">
          <h2 className="text-3xl md:text-4xl font-bold mb-4 text-white">
            Online Coaching Features
          </h2>
          <p className="text-gray-300 max-w-2xl mx-auto">
            Train anywhere with full coaching support
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {online_features.map((feature, index) => (
            <FeatureCard
              key={index}
              image={feature.image}
              title={feature.title}
              description={feature.description}
            />
          ))}
        </div>
      </div>

      {/* Call to Action */}
      <div className="bg-white/5 backdrop-blur rounded-2xl p-8 md:p-12 text-center border border-white/10">
        <h3 className="text-2xl md:text-3xl font-bold mb-4 text-white">
          Ready to Start Your Transformation?
        </h3>
        <p className="text-gray-300 mb-8 max-w-2xl mx-auto">
          Join hundreds of clients who have already transformed their lives with
          science-backed coaching
        </p>
        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <a
            href="/waiting-list"
            className="bg-[#0B79AB] text-white px-8 py-4 rounded-lg font-bold text-lg
                     hover:bg-[#0b78ab9e] transition-all transform hover:scale-105 inline-block"
          >
            Get Started Today →
          </a>
          <a
            href="/online-coaching"
            className="bg-white text-[#0B79AB] px-8 py-4 rounded-lg font-bold text-lg
                     hover:bg-gray-100 transition-all transform hover:scale-105 inline-block"
          >
            View Online Coaching
          </a>
        </div>
      </div>
    </section>
  );
};

export default WhatsIncludedSection;
