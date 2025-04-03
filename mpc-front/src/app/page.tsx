import { DesktopFooter, MobileFooter } from "@/components/Footer";
import { DesktopHeader, MobileHeader } from "@/components/Header";
import FeaturedCard from "@/components/home/FeatureCard";
import MembershipCard from "@/components/home/MembershipCard";
import WhatsIncludedSection from "@/components/home/WhatsIncludedSection";
import Image from "next/image";

export default function Home() {
  return (
    <>


      <section className="max-w-6xl mx-auto px-8 md:px-16 py-8 text-center">
        <h1 className="text-3xl md:text-3xl font-semibold mb-4">Memberships</h1>
        <p className="mb-8 font-medium text-md md:text-lg">I offer science-backed coaching, whether in-person or online. Get custom training, nutrition plans, and expert guidance to reach your goals.</p>
        <div className="flex flex-col  md:flex-row justify-center gap-6 items-center mb-8">
          <MembershipCard
            option={0}
            title="Start your journey"
            points={[
              "One-on-One, personalized coaching & diet optimization.",
              "Train smarter, not harder.",
              "Science-based methods for real results.",
            ]}
          />
          <MembershipCard
            option={1}
            title="Online Coaching"
            points={[
              "Train anytime, anywhere.",
              "Customized workout & diet plans.",
              "Weekly check-ins & progress tracking.",
            ]}
          />
        </div>
        <WhatsIncludedSection />
      </section>



    </>
  );
}


