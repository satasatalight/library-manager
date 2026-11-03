import { useState } from "react";
import { useNavigate } from "react-router";
import LoginForm from "../components/LoginForm";
import ResetForm from "../components/ResetForm";
import NewPasswordForm from "../components/NewPasswordForm";
import RegisterForm from "../components/RegisterForm";
import VerifyForm from "../components/VerifyForm";

function Login() {
  const navigate = useNavigate();

  function showLoginForm(): void {
    setEntryFieldComponent(
      <LoginForm onLoginSuccess={() => navigate("/books")} />,
    );
  }

  const [entryFieldComponent, setEntryFieldComponent] = useState(
    <LoginForm onLoginSuccess={() => navigate("/books")} />,
  );

  function handleResetRequested(): void {
    setEntryFieldComponent(
      <NewPasswordForm onPasswordResetSuccess={handlePasswordResetSuccess} />,
    );
  }

  function handlePasswordResetSuccess(): void {
    showLoginForm();
  }

  function handleRegisterSuccess(email: string): void {
    setEntryFieldComponent(
      <VerifyForm email={email} onVerifySuccess={handleVerifySuccess} />,
    );
  }

  function handleVerifySuccess(): void {
    showLoginForm();
  }

  return (
    <div className="vh-100 w-100 bg-base">
      <div className="main container border-start border-end shadow-lg mx-auto px-5 pt-5 h-100 w-75">
        <h1 className="fs-head font-kurale text-center">LitLog</h1>

        <div className="mt-4">
          {entryFieldComponent}
          <br />

          <a
            href="#"
            onClick={(e) => {
              e.preventDefault();
              setEntryFieldComponent(
                <RegisterForm onRegisterSuccess={handleRegisterSuccess} />,
              );
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
