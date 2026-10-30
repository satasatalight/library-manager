import { useState } from "react";
import LoginForm from "../components/LoginForm";
import ResetForm from "../components/ResetForm";
import NewPasswordForm from "../components/NewPasswordForm";

function Login() {
  const [entryFieldComponent, setEntryFieldComponent] = useState(<LoginForm />);

  function handleResetRequested(): void {
    setEntryFieldComponent(
      <NewPasswordForm onPasswordResetSuccess={handlePasswordResetSuccess} />,
    );
  }

  function handlePasswordResetSuccess(): void {
    setEntryFieldComponent(<LoginForm />);
  }

  return (
    <div className="vh-100 w-100 bg-base">
      <div className="main container border-start border-end shadow-lg mx-auto px-5 pt-5 h-100 w-75 ">
        <h1 className="fs-head font-kurale text-center">LitLog</h1>
        <div className="mt-4">
          {entryFieldComponent}
          <br />
          <a
            href="#"
            onClick={(e) => {
              e.preventDefault();
              setEntryFieldComponent(<>Put the Sign Up Component here</>);
            }}
            className="link-accent"
          >
            Don't Have an account? Sign Up
          </a>
          <br />
          <a
            href="#"
            onClick={(e) => {
              e.preventDefault();
              setEntryFieldComponent(
                <ResetForm onResetRequested={handleResetRequested} />,
              );
            }}
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
