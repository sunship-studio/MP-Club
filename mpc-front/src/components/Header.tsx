"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import logo from "../assets/logo.png";
import Image from "next/image";
import Link from "next/link";
const MobileHeader = () => {
  const router = useRouter();
  const [isOpen, setIsOpen] = useState(false);
  const handleMenuClick = () => {
    setIsOpen(!isOpen);
  };
  return (
    <>
      <div className="sticky top-0 z-50 md:hidden">
        <div className="flex flex-row justify-between items-center p-4 bg-white text-white h-20">
          <div className="h-full flex items-center">
            <div className="relative h-18 aspect-[2/1]">
              <Image
                onClick={() => router.push("/")}
                src="/assets/logo.png"
                alt="Logo"
                fill
                className="object-contain"
                priority
              />
            </div>
          </div>

          <button onClick={handleMenuClick} className="">
            <Image
              src={!isOpen ? "/assets/menu.png" : "/assets/close.png"}
              alt="menu"
              height={30}
              width={30}
              style={{ objectFit: "contain" }}
            />
          </button>
        </div>

        <div
          className={`bg-white overflow-hidden transition-all duration-300 ease-in-out ${
            isOpen ? "max-h-screen py-4" : "max-h-0"
          }`}
        >
          <nav className="flex flex-col space-y-6 px-4">
            <Link
              href="/"
              className="text-gray-800 py-2"
              onClick={() => setIsOpen(false)}
            >
              HOME
            </Link>
            <Link
              href="/waiting-list"
              className="text-gray-800 py-2"
              onClick={() => setIsOpen(false)}
            >
              WAITING LIST
            </Link>
            <Link
              href="/plans"
              className="text-gray-800 py-2"
              onClick={() => setIsOpen(false)}
            >
              PLANS
            </Link>
            <Link
              href="#"
              className="text-gray-800 py-2"
              onClick={() => setIsOpen(false)}
            >
              FORUM
            </Link>
            <Link href="/cancel" className="text-gray-800 py-2">
              <img
                src="/assets/profile_1.png"
                alt="profile"
                height={24}
                width={24}
              />
            </Link>
          </nav>
        </div>
      </div>
    </>
  );
};

const DesktopHeader = () => {
  const router = useRouter();
  return (
    <div className="bg-gray-100 overflow-hidden hidden md:block">
      {/* Top Logo Box */}
      <div className="py-0 flex justify-center">
        <div className="relative h-32 aspect-[2/1]">
          {" "}
          {/* adjust aspect ratio */}
          <Image
            onClick={() => router.push("/")}
            src="/assets/logo.png"
            alt="Logo"
            fill
            className="object-contain"
            priority
          />
        </div>
      </div>
      {/* Black Nav Bar */}
      <div className="bg-black text-white px-6 py-3 flex items-center justify-center gap-6">
        {/* Left nav links */}
        <nav className="flex gap-6 text-sm font-goodtimes tracking-wide">
          <a href="/" className="hover:text-gray-400">
            HOME
          </a>
          <a href="/waiting-list" className="hover:text-gray-400">
            WAITING LIST
          </a>
          <a href="/plans" className="hover:text-gray-400">
            PLANS
          </a>
          <a href="" className="hover:text-gray-400">
            FORUM
          </a>
          <a href="/cancel" className="hover:text-gray-400">
            <Image
              src="/assets/profile.png"
              alt="menu"
              height={18}
              width={18}
              style={{ objectFit: "contain" }}
            />
          </a>
        </nav>
      </div>
    </div>
  );
};

export { MobileHeader, DesktopHeader };
