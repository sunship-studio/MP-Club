const IncludedCard = ({ title, description, imageName }: { title: string, description: string, imageName: string }) => {
    return (
    <div className="bg-white text-black rounded-lg p-6 shadow-lg font-inter w-full max-w-sm h-60 justify-between flex flex-col space-y-4">
        <h3 className="text-xl font-semibold mb-4 text-left">{title}</h3>
    </div>
  );
}