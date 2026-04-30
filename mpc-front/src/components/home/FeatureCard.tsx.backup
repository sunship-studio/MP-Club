import Image from 'next/image';

const FeatureCard = ({ title, description, image, row = true }: { image: string, description: string, title: string, row?: boolean }) =>
(
    <div className={`flex flex-col bg-white md:p-6 ${row ? '' : 'mx-auto'} md:mx-0 p-4 rounded-lg shadow-lg text-gray-900 max-w-sm md:h-65 space-y-2 items-start`}>
        <div className="flex justify-center">
            <img src={`${image}`} className='w-20 md:w-23' />
        </div>
        <h1 className={`lg:text-xl font-bold mb-2 text-left ${row ? 'text-md' : 'text-md'}`}>{title}</h1>
        <p className={`font-normal  text-xs lg:text-sm text-left text-[#374151] ${row ? "text-xs" : ""}`}>{description}</p>
        <div className='lg:flex-grow hidden' ></div>
        <div className='hidden lg:flex flex-row items-center'>
            <p className='text-[#118CC3] font-medium text-sm'>Explore</p> <img src="/assets/chevron-right.png" alt="buy-membership" className='w-6' />
        </div>
    </div>
);


export default FeatureCard;