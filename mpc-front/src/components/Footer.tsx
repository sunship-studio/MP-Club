const _footerText = "© 2025 Midlands Performance Club. All rights reserved"

const DesktopFooter = () => (

    <footer className="sticky py-8 hidden md:block items-start bg-red-800">
        <div>  <p>{_footerText}</p></div>

    </footer>

)

const MobileFooter = () => (
    <footer className="py-8 md:hidden"> </footer>
)



export { DesktopFooter, MobileFooter }