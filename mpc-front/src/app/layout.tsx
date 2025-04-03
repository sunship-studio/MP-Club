import type { Metadata } from "next";

import "./globals.css";



import { Inter } from 'next/font/google';

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
});
export const metadata: Metadata = {
  title: "Midlands Perfomance Club",

};
import localFont from 'next/font/local';
import { DesktopHeader, MobileHeader } from "@/components/Header";

const goodTimes = localFont({
  src: '../../public/fonts/GoodTimes.otf',
  variable: '--font-goodtimes',

});
export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className={`${inter.variable} ${goodTimes.className} h-full bg-white`}>
      <body className="font-inter antialiased flex flex-col min-h-screen">
        <MobileHeader />
        <DesktopHeader />
        <main className="  inset-0 bg-[linear-gradient(to_bottom,#0E77A5,#000000bf)] font-inter flex-grow min-h-[calc(100vh-var(--header-height)-var(--footer-height))]">  {children} </main>
      </body>
    </html>
  );
}
