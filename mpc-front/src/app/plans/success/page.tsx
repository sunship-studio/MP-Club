const PlansSuccess = () => {
  return (
    <div className="flex flex-col items-center justify-center w-full h-full mt-12">
      <h1 className="text-4xl font-bold text-center">
        You purchased plan successfully!
      </h1>

      <p className="mt-4 text-lg md:text-xl font-semibold text-center mb-4 px-4">
        Thank you for your purchase!
        <br />
        You will receive a confirmation email shortly with downloadable plan.
        <br />
        If you have any questions or need assistance, feel free to reach out.
      </p>
      <img
        src="/assets/waiting-list/envelope.png"
        alt="envelope"
        className=""
      />
    </div>
  );
};

export default PlansSuccess;
