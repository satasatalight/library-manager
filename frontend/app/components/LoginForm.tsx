import React, { useState } from "react";
import axios from "axios";

function LoginForm() {
  const [loginEmail, setLoginEmail] = useState("");
  const [loginPassword, setLoginPassword] = useState("");
  const [message, setMessage] = useState("");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [invalidEmail, setInvalidEmail] = useState(false);

  function handleSetLoginEmail(e: React.ChangeEvent<HTMLInputElement>): void {
    setLoginEmail(e.target.value);
    setInvalidEmail(false);
    setMessage("");
  }

  function handleSetPassword(e: React.ChangeEvent<HTMLInputElement>): void {
    setLoginPassword(e.target.value);
  }

  async function doLogin(
    event: React.SubmitEvent<HTMLFormElement>,
  ): Promise<void> {
    event.preventDefault();

    if (isSubmitting) {
      return;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    if (!emailRegex.test(loginEmail)) {
      setInvalidEmail(true);
      setMessage("Invalid email format.");
      return;
    }

    setInvalidEmail(false);

    if (!loginPassword) {
      setMessage("Please enter your password.");
      return;
    }

    setMessage("");
    setIsSubmitting(true);

    try {
      const response = await axios.post(
        "https://library-manager-ashy.vercel.app/users/login",
        {
          email: loginEmail,
          password: loginPassword,
        },
      );

      const res = response.data;

      if (res.status === "success" && typeof res.token === "string") {
        sessionStorage.setItem("token", res.token);
        setMessage("Login successful!");
      } else {
        setMessage(res.reason || "Login failed.");
      }
    } catch (error) {
      if (axios.isAxiosError(error)) {
        setMessage(
          error.response?.data?.reason || "Unable to connect to the server.",
        );
      } else {
        setMessage("Unable to connect to the server.");
      }

      console.error(error);
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <form
      className="d-flex flex-column align-items-center mt-5"
      onSubmit={doLogin}
      noValidate
    >
      <h2 className="mb-4">Login</h2>

      <input
        type="email"
        placeholder="Email"
        className={`form-control w-75 mb-4 ${invalidEmail ? "is-invalid" : ""}`}
        value={loginEmail}
        onChange={handleSetLoginEmail}
        required
      />

      <input
        type="password"
        placeholder="Password"
        className="form-control w-75 mb-4"
        value={loginPassword}
        onChange={handleSetPassword}
        required
      />

      <button
        type="submit"
        className="btn btn-accent px-5"
        disabled={isSubmitting}
      >
        {isSubmitting ? "Logging In..." : "Login"}
      </button>

      {message && (
        <p
          className={`mt-3 text-center ${
            message === "Login successful!" ? "text-success" : "text-danger"
          }`}
        >
          {message}
        </p>
      )}
    </form>
  );
}

export default LoginForm;
