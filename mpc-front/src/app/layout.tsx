import type { Metadata } from "next";

import "./globals.css";



import { DesktopHeader, MobileHeader } from "@/components/Header";
import { Inter } from 'next/font/google';
import localFont from 'next/font/local';

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
});
export const metadata: Metadata = {
  title: "Midlands Perfomance Club",

};

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
    <html lang="en" className={`${inter.variable} ${goodTimes.className} h-full bg-white` } >
    <head>
         <meta http-equiv="Content-Security-Policy" content="default-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://checkout.stripe.com; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://js.stripe.com https://checkout.stripe.com; frame-src https://js.stripe.com https://checkout.stripe.com https://hooks.stripe.com; connect-src 'self' https://mp-club-production.up.railway.app https://api.stripe.com https://checkout.stripe.com https://m.stripe.com; img-src 'self' data: https: https://*.stripe.com; font-src 'self' https://fonts.gstatic.com data:;"></meta>
    </head>
      <body className="font-inter antialiased flex flex-col min-h-screen">
        <MobileHeader />
        <DesktopHeader />
        <main className="  inset-0 bg-[linear-gradient(to_bottom,#10719B,#000000bf)] font-inter flex-grow min-h-[calc(100vh-var(--header-height)-var(--footer-height))]">  {children} </main>
        {/* <DesktopFooter />
        <MobileFooter /> */}
      </body>
    </html>
  );
}
