const ErrorText = ({ error }: { error: string }) => {
    return (
        error &&
        <div className="text-red-500 text-sm font-semibold">
        {error}
        </div>
    );
    }


export default ErrorText;