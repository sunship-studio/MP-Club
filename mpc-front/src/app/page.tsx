import MembershipCard from '@/components/home/MembershipCard';
import WhatsIncludedSection from '@/components/home/WhatsIncludedSection';

export default function Home() {
  return (
    <div className="max-w-7xl mx-auto px-8 md:px-16 py-12">
      {/* Hero Section */}
      <section className="text-center mb-16">
        <h1 className="text-4xl md:text-6xl font-bold mb-6 text-white">
          Transform Your Fitness Journey
        </h1>
        <p className="text-lg md:text-xl text-gray-200 max-w-3xl mx-auto leading-relaxed">
          Science-backed coaching tailored to your goals. Whether in-person or
          online, get custom training, nutrition plans, and expert guidance to
          achieve real results.
        </p>
      </section>

      {/* Membership Cards */}
      <section className="mb-20">
        <h2 className="text-3xl md:text-4xl font-bold text-center mb-4 text-white">
          Choose Your Path
        </h2>
        <p className="text-center text-gray-300 mb-10 max-w-2xl mx-auto">
          Select the coaching option that fits your lifestyle and goals
        </p>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <MembershipCard
            option={0}
            title="1-on-1 Coaching 🎯 "
            points={[
              'Get a coach who actually knows YOUR body',
              'Stop wasting time on cookie-cutter programs',
              'See real changes in weeks, not months',
            ]}
          />
          <MembershipCard
            option={1}
            title="Online Coaching 📱"
            points={[
              'Your coach in your pocket 24/7 📲',
              'Workouts that fit YOUR schedule & space',
              'Weekly check-ins so you never feel lost',
              'No gym? No problem. Train anywhere',
            ]}
          />
          <MembershipCard
            option={2}
            title="Group Classes 👥"
            points={[
              "Finally, workouts you'll actually enjoy 🏋️",
              'Never worked out? We got you',
              'Expert coaches who actually care',
              'Book classes that fit your life',
            ]}
          />
        </div>
      </section>

      {/* What's Included Section */}
      <WhatsIncludedSection />
    </div>
  );
}
