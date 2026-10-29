import { useState } from "react";

function Login() {
  const [entryFieldComponent, setEntryFieldComponent] = useState(
    <>Put the Login Component Here</>,
  );

  return (
    <div className="vh-100 w-100 bg-base">
      <div className="main container border-start border-end shadow-lg mx-auto px-5 pt-5 h-100 w-75 ">
        <h1 className="fs-head font-kurale">LitLog</h1>
        <div className="mt-4">
          {entryFieldComponent}
          <br />
          <a
            href="#"
            onClick={() =>
              setEntryFieldComponent(<>Put the Sign Up Component here</>)
            }
            className="link-accent"
          >
            Don't Have an account? Sign Up
          </a>
          <br />
          <a
            href="#"
            onClick={() =>
              setEntryFieldComponent(
                <>Put the Forgot Password Component here</>,
              )
            }
            className="link-accent"
          >
            Forgot Password?
          </a>
        </div>
      </div>
    </div>
  );
}

export default Login;
